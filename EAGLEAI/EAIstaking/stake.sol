// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */

interface ITdEAI is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
/**
 * @title EAIStaking
 * @dev A staking contract where users stake EAI tokens, earn rewards in EAI and USDC,
 *      and manage epochs dynamically. Implements security features like reentrancy guards
 *      and pausable mechanisms.
 */

contract EAIStaking is ReentrancyGuard, Pausable, Ownable {
   struct Epoch {
        uint256 totalStaked;   // Total amount staked in this epoch
        uint256 eaiRewards;    // Total EAI rewards allocated to this epoch
        uint256 usdcRewards;   // Total USDC rewards allocated to this epoch
    }

    struct UserInfo {
        uint256 stakedAmount; // Amount of EAI tokens staked by the user
        uint256 lastStakeTimestamp; // Timestamp of the last stake
        uint256 lastStakeEpoch; // Last epoch in which the user staked
        uint256 lastClaimEpoch;
        mapping(uint256 => bool) hasClaimedRewards; // Tracks if user claimed rewards for each epoch
        mapping(uint256 => uint256) claimedEAIRewards; // Tracks EAI rewards claimed per epoch
        mapping(uint256 => uint256) claimedUSDCRewards; // Tracks USDC rewards claimed per epoch
    }

    IERC20 public immutable eaiToken; // EAI token contract
    IERC20 public immutable usdcToken; // USDC token contract
    ITdEAI public immutable tdEAIToken; // tdEAI token contract for staking receipts

    uint256 public constant EPOCH_DURATION = 5 minutes; // Duration of each epoch
    uint256 private currentEpoch; // Tracks the current epoch number
    uint256 public epochStartTime; // Timestamp when staking started
    uint256 public lastPauseTime; // Last time the contract was paused
    uint256 public totalPauseDuration; // Total duration contract was paused
    bool public isContractActive; // Indicates if the contract is active
    uint256 public totalStakedAmount; // Total amount staked in the contract

    mapping(uint256 => Epoch) public epochs; // Mapping of epoch number to Epoch struct
    mapping(address => UserInfo) public userInfo; // Mapping of user addresses to UserInfo struct

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 indexed epoch, uint256 eaiAmount, uint256 usdcAmount);
    event RewardsClaimed(address indexed user, uint256 indexed epoch, uint256 eaiAmount, uint256 usdcAmount);
    event EpochExtended(uint256 indexed epoch, uint256 pauseDuration);
    event ContractActivated(address contractaddress, bool status);
    event EpochStarted(uint256 indexed epoch, uint256 startTime);
    event FirstStake(address indexed user, uint256 amount, uint256 timestamp);

    /**
     * @dev Constructor initializes the contract with token addresses and ownership.
     * @param _eaiToken Address of the EAI token contract
     * @param _usdcToken Address of the USDC token contract
     * @param _tdEAIToken Address of the tdEAI token contract
     */
    constructor(
        address _eaiToken,
        address _usdcToken,
        address _tdEAIToken
    ) Ownable(msg.sender) {
        eaiToken = IERC20(_eaiToken);
        usdcToken = IERC20(_usdcToken);
        tdEAIToken = ITdEAI(_tdEAIToken);
        currentEpoch = 0;
        isContractActive = false;
        totalPauseDuration = 0;
        totalStakedAmount = 0;
    }

     /**
     * @dev Modifier to ensure the contract is active before executing a function.
     */
    modifier whenContractActive() {
        require(isContractActive, "Contract is not active");
        _;
    }

    /**
    * @dev Activates the contract, allowing its functionalities to be used.
    * Can only be called by the owner.
    * Ensures the contract is not already active before activation.
    * Emits a {ContractActivated} event upon successful activation.
    */
    function activateContract() external onlyOwner {
        require(!isContractActive, "Contract is already active");
        isContractActive = true;       
        emit ContractActivated(address(this),true);
    }
    /**
    * @dev Returns the current epoch number based on the elapsed time since staking started.
    * If staking has not started or the contract is paused, it returns the current stored epoch.
    * Calculates the number of completed epochs by considering the total elapsed time,
    * excluding any paused duration.
    * 
    * @return The current epoch number.
    */
    function getCurrentEpochNumber() public view returns (uint256) {
        if (paused()) {           
            return currentEpoch + 1;
        }

        uint256 timeElapsed = block.timestamp - epochStartTime - totalPauseDuration;
        uint256 completedEpochs = timeElapsed / EPOCH_DURATION;
        return currentEpoch + completedEpochs;
    }
    /**
    * @dev Allows users to stake EAI tokens in the contract.
    * Enforces reentrancy protection and ensures the contract is active and not paused.
    * 
    * Requirements:
    * - `amount` must be greater than 0.
    * - The user must have approved the contract to spend at least `amount` EAI tokens.
    * - The user must have a sufficient EAI token balance.
    * - Staking cooldown must not be active.
    * 
    * Process:
    * 1. Transfers `amount` of EAI tokens from the user to the contract.
    * 2. If this is the first stake, it sets the `epochStartTime` and emits events.
    * 3. If the last stake was before the current epoch, it allows claiming rewards.
    * 4. If staking cooldown is active, it reverts the transaction.
    * 5. Updates the user's stake and total staked amount.
    * 6. Updates the epoch's total staked balance.
    * 7. Mints an equivalent amount of tdEAI tokens to the user.
    * 8. Emits a `Staked` event.
    * 
    * @param amount The amount of EAI tokens to stake.
    */
    function stake(uint256 amount) external nonReentrant whenNotPaused whenContractActive {
        require(amount > 0, "Cannot stake 0");

        // Ensure the contract has enough allowance to transfer tokens
        require(eaiToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance, approve contract first");

        // Ensure the user has enough balance
        require(eaiToken.balanceOf(msg.sender) >= amount, "Insufficient EAI balance");

        // Transfer tokens from user to contract
        require(eaiToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        UserInfo storage userinfo = userInfo[msg.sender];

            

        // Reward claim logic before updating stake
        
            if (block.timestamp > userinfo.lastStakeTimestamp + EPOCH_DURATION && getCurrentEpochNumber() != 0) {
                claim();
            } else if (getCurrentEpochNumber()  <= userinfo.lastStakeEpoch  && getCurrentEpochNumber() != 0 ) {
                revert("Staking cooldown period is active, please wait until the next epoch.");
            }
         

        userinfo.stakedAmount += amount;
        userinfo.lastStakeTimestamp = block.timestamp;

        if (epochStartTime == 0) {
            epochStartTime = block.timestamp;
            currentEpoch = 1;
            emit FirstStake(msg.sender, amount, block.timestamp);
            emit EpochStarted(getCurrentEpochNumber(), epochStartTime);
        }    

        totalStakedAmount += amount;
        epochs[getCurrentEpochNumber()].totalStaked = totalStakedAmount;
        userinfo.lastStakeEpoch = getCurrentEpochNumber();
        // Mint tdEAI tokens to the staker
        tdEAIToken.mint(msg.sender, amount);

        emit Staked(msg.sender, amount);
    }
    /**
    * @dev Allows users to unstake EAI tokens by burning their tdEAI tokens.
    * Ensures reentrancy protection and that the contract is active and not paused.
    * 
    * Requirements:
    * - `amount` must be greater than 0.
    * - The user must have at least `amount` tdEAI tokens.
    * - The user must have at least `amount` staked in the contract.
    * - The user must not have claimed rewards for the current epoch before unstaking.
    * 
    * Process:
    * 1. If the user has staked past the epoch duration, rewards are claimed before unstaking.
    * 2. Verifies the user’s staked balance is sufficient.
    * 3. Ensures the user has not already claimed rewards for the current epoch.
    * 4. Updates the user’s staked amount and the total staked amount.
    * 5. Burns `amount` of tdEAI tokens from the user.
    * 6. Transfers the equivalent amount of EAI tokens back to the user.
    * 7. Emits an `Unstaked` event.
    * 
    * @param amount The amount of EAI tokens to unstake.
    */
    function unstake(uint256 amount) external nonReentrant whenNotPaused whenContractActive {
        require(amount > 0, "Cannot unstake 0");
        require(tdEAIToken.balanceOf(msg.sender) >= amount, "Insufficient tdEAI balance");

        UserInfo storage user_info = userInfo[msg.sender];
        require(user_info.stakedAmount >= amount, "Insufficient staked amount");

        if (block.timestamp > user_info.lastStakeTimestamp + EPOCH_DURATION && getCurrentEpochNumber()!=0 ) {
            claim();
        }    
        
       
        uint256 epochNumber = getCurrentEpochNumber();
        Epoch storage currentEpochData = epochs[epochNumber];

        // Ensure rewards for the current epoch have not been claimed
        require(!user_info.hasClaimedRewards[epochNumber], "Cannot unstake after claiming rewards for this epoch");

        // Update user and global staking data
        user_info.stakedAmount -= amount;
      
        totalStakedAmount -= amount;
        currentEpochData.totalStaked = totalStakedAmount;

        // Burn tdEAI tokens and return EAI tokens to the user
        tdEAIToken.burn(msg.sender, amount);
        require(eaiToken.transfer(msg.sender, amount), "EAI transfer failed");

        emit Unstaked(msg.sender, amount);
    }
    /**
    * @dev Distributes rewards for the current staking epoch in either USDC or EAI.
    * Only the contract owner can call this function when the contract is active and not paused.
    *
    * Requirements:
    * - `amount` must be greater than 0.
    * - Staking must have started (`epochStartTime` must be set).
    * - There must be active stakes in the current epoch.
    * - The caller must approve the contract to transfer the specified amount of tokens.
    *
    * Process:
    * 1. Retrieves the current epoch number.
    * 2. If `isUSDC` is true, transfers `amount` USDC tokens from the caller to the contract.
    * 3. If `isUSDC` is false, transfers `amount` EAI tokens from the caller to the contract.
    * 4. Updates the reward balance for the respective token in the current epoch.
    * 5. Ensures the epoch data is up to date by calling `updateEpoch()`.
    * 6. Emits a `RewardsDistributed` event with the updated reward details.
    *
    * @param amount The amount of tokens to distribute as rewards.
    * @param isUSDC Boolean indicating whether the reward is in USDC (true) or EAI (false).
    */
    function distributeRewards(uint256 amount, bool isUSDC) external onlyOwner whenNotPaused whenContractActive {
        require(amount > 0, "Amount must be greater than 0");
        require(epochStartTime > 0, "Staking has not started");
        require(totalStakedAmount > 0, "No stakes in current epoch"); 

        uint256 epochNumber = getCurrentEpochNumber();       
        Epoch storage currentEpochData = epochs[epochNumber];

        if (isUSDC) {
            require(usdcToken.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
            currentEpochData.usdcRewards += amount;
        } else {
            require(eaiToken.transferFrom(msg.sender, address(this), amount), "EAI transfer failed");
            currentEpochData.eaiRewards += amount;
        }
        updateEpoch();  // Ensure current epoch is updated
        emit RewardsDistributed(epochNumber, isUSDC ? 0 : amount, isUSDC ? amount : 0);
    }
    /**
    * @dev Internal function to claim staking rewards from past epochs.
    * This function calculates and transfers rewards for the user based on their stake
    * across multiple epochs, ensuring that rewards are not double-claimed.
    *
    * Requirements:
    * - Staking must have started (`epochStartTime` must be set).
    * - The user must have an active stake in at least one past epoch.
    *
    * Process:
    * 1. Retrieves the user's last claimed epoch and the latest epoch.
    * 2. Iterates through all unclaimed epochs.
    * 3. Skips epochs where the user has already claimed rewards or had no stake.
    * 4. Calculates the user's share of rewards in both EAI and USDC.
    * 5. Updates the reward tracking variables and ensures rewards are marked as claimed.
    * 6. Transfers the accumulated rewards to the user.
    * 7. Updates the `lastClaimEpoch` to prevent double-claiming.
    * 8. Emits a `RewardsClaimed` event with the details of the claimed rewards.
    */
    function claim() internal {
        require(epochStartTime > 0, "Staking has not started");

        UserInfo storage user = userInfo[msg.sender];
        uint256 lastClaimedEpoch = user.lastClaimEpoch;
        uint256 latestEpoch = getCurrentEpochNumber();
        if(lastClaimedEpoch < latestEpoch){

        uint256 totalEAIRewards = 0;
        uint256 totalUSDCRewards = 0;

        for (uint256 epoch = lastClaimedEpoch + 1; epoch < latestEpoch; epoch++) {
            if (user.hasClaimedRewards[epoch]) continue; // Skip already claimed epochs

            uint256 userStake = user.stakedAmount;
            if (userStake == 0) continue; // Skip epochs where user had no stake

            Epoch storage epochData = epochs[epoch];
            if (epochData.eaiRewards == 0 && epochData.usdcRewards == 0) continue; // Skip empty reward epochs

            uint256 eaiRewards = (userStake * epochData.eaiRewards) / epochData.totalStaked;
            uint256 usdcRewards = (userStake * epochData.usdcRewards) / epochData.totalStaked;

            totalEAIRewards += eaiRewards;
            totalUSDCRewards += usdcRewards;

            user.hasClaimedRewards[epoch] = true;
            user.claimedEAIRewards[epoch] = eaiRewards;
            user.claimedUSDCRewards[epoch] = usdcRewards;
        }

        if(totalEAIRewards > 0 || totalUSDCRewards > 0){

            if (totalEAIRewards > 0) {
                require(eaiToken.transfer(msg.sender, totalEAIRewards), "EAI reward transfer failed");
            }
            if (totalUSDCRewards > 0) {
                require(usdcToken.transfer(msg.sender, totalUSDCRewards), "USDC reward transfer failed");
            }
            
            user.lastClaimEpoch = latestEpoch - 1;
            emit RewardsClaimed(msg.sender, latestEpoch - 1, totalEAIRewards, totalUSDCRewards);
            
        }
    }
    }
    /**
    * @dev Allows users to claim their accumulated staking rewards.
    * Rewards are distributed based on the user's stake in each epoch.
    *
    * Requirements:
    * - Staking must have started (`epochStartTime` must be set).
    * - The user must have unclaimed rewards from previous epochs.
    *
    * Process:
    * 1. Checks if staking has started.
    * 2. Retrieves the user's last claimed epoch and the latest epoch.
    * 3. Ensures there are unclaimed rewards.
    * 4. Iterates through each unclaimed epoch and calculates the user's rewards.
    * 5. Updates reward tracking to prevent double claims.
    * 6. Transfers the accumulated rewards to the user.
    * 7. Updates the `lastClaimEpoch` to the latest claimed epoch.
    * 8. Emits the `RewardsClaimed` event with details.
    */
     function claimRewards() public nonReentrant whenNotPaused whenContractActive {
         require(epochStartTime > 0, "Staking has not started");

        UserInfo storage user = userInfo[msg.sender];
        uint256 lastClaimedEpoch = user.lastClaimEpoch;
        uint256 latestEpoch = getCurrentEpochNumber();
        require(lastClaimedEpoch < latestEpoch, "No new rewards available");

        uint256 totalEAIRewards = 0;
        uint256 totalUSDCRewards = 0;

        for (uint256 epoch = lastClaimedEpoch + 1; epoch < latestEpoch; epoch++) {
            if (user.hasClaimedRewards[epoch]) continue; // Skip already claimed epochs

            uint256 userStake = user.stakedAmount;
            if (userStake == 0) continue; // Skip epochs where user had no stake

            Epoch storage epochData = epochs[epoch];
            if (epochData.eaiRewards == 0 && epochData.usdcRewards == 0) continue; // Skip empty reward epochs

            uint256 eaiRewards = (userStake * epochData.eaiRewards) / epochData.totalStaked;
            uint256 usdcRewards = (userStake * epochData.usdcRewards) / epochData.totalStaked;

            totalEAIRewards += eaiRewards;
            totalUSDCRewards += usdcRewards;

            user.hasClaimedRewards[epoch] = true;
            user.claimedEAIRewards[epoch] = eaiRewards;
            user.claimedUSDCRewards[epoch] = usdcRewards;
        }

        require(totalEAIRewards > 0 || totalUSDCRewards > 0, "No rewards to claim");

        if (totalEAIRewards > 0) {
            require(eaiToken.transfer(msg.sender, totalEAIRewards), "EAI reward transfer failed");
        }
        if (totalUSDCRewards > 0) {
            require(usdcToken.transfer(msg.sender, totalUSDCRewards), "USDC reward transfer failed");
        }

        user.lastClaimEpoch = latestEpoch - 1;

        emit RewardsClaimed(msg.sender, latestEpoch - 1, totalEAIRewards, totalUSDCRewards);
    }
    /**
    * @dev Returns the pending rewards (EAI and USDC) for a given user.
    * Rewards are calculated based on the user's stake in each epoch.
    *
    * Requirements:
    * - The function is `view`, meaning it does not modify state.
    *
    * Process:
    * 1. Fetches the user's last claimed epoch and the latest epoch.
    * 2. Iterates through unclaimed epochs to calculate the user's share of rewards.
    * 3. Skips epochs where the user had no stake or no rewards were distributed.
    * 4. Accumulates pending EAI and USDC rewards.
    * 5. Returns the total pending rewards for the user.
    *
    * @param user The address of the user to check pending rewards for.
    * @return totalEAIRewards The total pending EAI rewards for the user.
    * @return totalUSDCRewards The total pending USDC rewards for the user.
    */
    function getPendingRewards(address user) external view returns (uint256 totalEAIRewards, uint256 totalUSDCRewards) {
        UserInfo storage userInfo_ = userInfo[user];
        uint256 lastClaimedEpoch = userInfo_.lastClaimEpoch;
        uint256 latestEpoch = getCurrentEpochNumber();

        for (uint256 epoch = lastClaimedEpoch + 1; epoch < latestEpoch; epoch++) {
            if (userInfo_.hasClaimedRewards[epoch]) continue;

            uint256 userStake = userInfo_.stakedAmount;
            if (userStake == 0) continue;

            Epoch storage epochData = epochs[epoch];
            if (epochData.eaiRewards == 0 && epochData.usdcRewards == 0) continue;

            totalEAIRewards = (userStake * epochData.eaiRewards) / epochData.totalStaked;
            totalUSDCRewards = (userStake * epochData.usdcRewards) / epochData.totalStaked;
        }
    }
    /**
    * @dev Updates the current epoch if enough time has passed.
    * 
    * Process:
    * - Checks if the contract is paused or hasn't started.
    * - Determines the latest epoch number.
    * - If the epoch has progressed, finalizes the previous epoch and updates `totalStakedAmount`.
    * - Aligns `epochStartTime` to the beginning of the new epoch.
    */
   function updateEpoch() internal    {
        if (epochStartTime == 0 || paused()) {
            return;
        }

        uint256 newEpochNumber = getCurrentEpochNumber();
        if (currentEpoch < newEpochNumber) {           

            // Carry forward totalStaked to each new epoch until the current epoch
            for (uint256 i = currentEpoch + 1; i <= newEpochNumber; i++) {
                epochs[i].totalStaked = epochs[currentEpoch].totalStaked;
            }

            currentEpoch = newEpochNumber;
            epochs[currentEpoch].totalStaked = totalStakedAmount;

            // Adjust epochStartTime to align with the beginning of the new epoch
            epochStartTime = block.timestamp - ((block.timestamp - epochStartTime - totalPauseDuration) % EPOCH_DURATION);

            emit EpochStarted(currentEpoch, epochStartTime);
        }
    }

    /**
    * @dev Updates the current epoch if enough time has passed.
    * 
    * Process:
    * - Checks if the contract is paused or hasn't started.
    * - Determines the latest epoch number.
    * - If the epoch has progressed, finalizes the previous epoch and updates `totalStakedAmount`.
    * - Aligns `epochStartTime` to the beginning of the new epoch.
    */

     function getTotalStaked() external view returns (uint256) {
        return totalStakedAmount;
    }
   /**
    * @dev Returns the reward amounts (EAI and USDC) for a given epoch.
    * @param epoch The epoch number to fetch rewards for.
    * @return eaiRewards The total EAI rewards distributed in the epoch.
    * @return usdcRewards The total USDC rewards distributed in the epoch.
    */    
    function getEpochRewards(uint256 epoch) external view returns (uint256 eaiRewards, uint256 usdcRewards) {
        return (epochs[epoch].eaiRewards, epochs[epoch].usdcRewards);
    }
    /**
    * @notice Checks if a user is eligible for rewards.
    * @dev The function returns true if the user has staked tokens and the contract is not active.
    * @param user The address of the user to check.
    * @return bool True if the user has staked tokens and the contract is inactive, false otherwise.
    */
    function isEligibleForRewards(address user) external view returns (bool) {
        UserInfo storage userInfo_ = userInfo[user];
        return userInfo_.stakedAmount > 0 && isContractActive;
    }
    /**
    * @notice Returns the adjusted end time for the current epoch, factoring in any pause durations.
    * @dev If the epoch has not started yet (`epochStartTime` is 0), the function returns 0. 
    *      Otherwise, it computes the end time by adding the `EPOCH_DURATION` and `totalPauseDuration` 
    *      to the `epochStartTime`.
    * @return uint256 The adjusted epoch end time.
    */
    function getAdjustedEpochEndTime() public view returns (uint256) {
        if (epochStartTime == 0) {
            return 0;
        }
        return epochStartTime + EPOCH_DURATION + totalPauseDuration;
    }
    /**
    * @notice Pauses the contract, preventing further actions until resumed.
    * @dev This function can only be called by the contract owner (`onlyOwner`). 
    *      It records the current timestamp as `lastPauseTime` and triggers the `_pause` modifier 
    *      to pause the contract. The contract must be active when this function is called (`whenContractActive`).
    */
    function pauseContract() external onlyOwner whenContractActive {
        lastPauseTime = block.timestamp;
        _pause();
    }
    /**
    * @notice Resumes the contract from a paused state.
    * @dev This function can only be called by the contract owner (`onlyOwner`). It requires that the contract is currently paused 
    *      (`paused()`), and if the contract is paused, it calculates the duration of the pause and adds it to `totalPauseDuration`. 
    *      It then emits an `EpochExtended` event, indicating the current epoch and the pause duration. Finally, the contract is unpaused 
    *      using the `_unpause` modifier to allow normal operation.
    * @dev Emits an `EpochExtended` event with the current epoch and pause duration.
    */
    function resumeContract() external onlyOwner {
        require(paused(), "Contract not paused");
        uint256 pauseDuration = block.timestamp - lastPauseTime;
        totalPauseDuration += pauseDuration;
        emit EpochExtended(currentEpoch, pauseDuration);
        _unpause();
    }
   
    /**
    * @notice Checks if a user has claimed rewards for a specific epoch.
    * @dev This function returns a boolean value indicating whether the user has claimed rewards for the given epoch. 
    *      It accesses the `hasClaimedRewards` mapping from the `userInfo` struct for the specified user and epoch.
    * @param user The address of the user to check.
    * @param epoch The epoch number to check for reward claims.
    * @return bool True if the user has claimed rewards for the specified epoch, false otherwise.
    */
    function hasUserClaimedRewards(address user, uint256 epoch) external view returns (bool) {
        return userInfo[user].hasClaimedRewards[epoch];
    }
    /**
    * @notice Retrieves the amount of claimed rewards for a user for a specific epoch.
    * @dev This function returns the amounts of both EAI and USDC rewards that the user has claimed for the specified epoch.
    *      It accesses the `claimedEAIRewards` and `claimedUSDCRewards` mappings from the `userInfo` struct for the given user and epoch.
    * @param user The address of the user whose claimed rewards are being checked.
    * @param epoch The epoch number to check the claimed rewards for.
    * @return eaiRewards The amount of EAI rewards claimed by the user for the specified epoch.
    * @return usdcRewards The amount of USDC rewards claimed by the user for the specified epoch.
    */
    function getUserClaimedRewards(address user, uint256 epoch) external view returns (uint256 eaiRewards, uint256 usdcRewards) {
        UserInfo storage userInfo_ = userInfo[user];
        return (
            userInfo_.claimedEAIRewards[epoch],
            userInfo_.claimedUSDCRewards[epoch]
        );  
    }
    /**
    * @notice Allows the contract owner to withdraw EAI tokens from the contract.
    * @dev This function enables the owner to withdraw a specified amount of EAI tokens from the contract. 
    *      It ensures that the withdrawal amount is greater than 0 and that the contract has enough EAI tokens. 
    *      If the conditions are met, the EAI tokens are transferred to the owner's address.
    * @param amount The amount of EAI tokens to withdraw.
    * @dev Reverts if the amount is 0, if the contract does not have enough EAI tokens, or if the transfer fails.
    */
    /*function withdrawEAI(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(eaiToken.balanceOf(address(this)) >= amount, "Insufficient EAI balance in contract");

        require(eaiToken.transfer(msg.sender, amount), "EAI transfer failed");
    }*/
}
