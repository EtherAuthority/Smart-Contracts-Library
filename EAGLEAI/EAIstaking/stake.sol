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
        uint256 totalLockstaked; // Total rewards staked amount for this epoch
        uint256 eaiRewards;    // Total EAI rewards allocated to this epoch
        uint256 usdcRewards;   // Total USDC rewards allocated to this epoch
        mapping(address => bool)  eaiRewardStatus;
        mapping(address => bool)  usdcRewardStatus;
        mapping(address => uint256) rewardStakeBalance;
    }

    // Updated user info with separate balances:
    struct UserInfo {
        uint256 lockedStake;   // "Old" stake locked in at the start of an epoch and eligible for rewards.
        uint256 pendingStake;  // "New" stake added mid-epoch; not eligible for rewards until next epoch.
        uint256 lastStakeTimestamp; // Timestamp of the last stake (for cooldowns, etc.)
        uint256 lastStakeEpoch; // The epoch in which the user last updated their stake (rolled over pending)       
        uint256 lastRolloverStake;
        uint256 lastClaimEpoch; // Last epoch that has been fully claimed
        // For each epoch, we now store the amount claimed so far (so that partial claims are possible)
        mapping(uint256 => uint256) claimedEAIRewards; 
        mapping(uint256 => uint256) claimedUSDCRewards;
    }

    IERC20 public immutable eaiToken; // EAI token contract
    IERC20 public immutable usdcToken; // USDC token contract
    ITdEAI public immutable tdEAIToken; // tdEAI token contract for staking receipts
     
    address[] public stakers;  // Array to track stakers 
    uint256 public constant EPOCH_DURATION = 30 days; // Duration of each epoch
    uint256 private currentEpoch; // Tracks the current epoch number
    uint256 public epochStartTime; // Timestamp when staking started
    uint256 public epochEndTime; // Timestamp when staking Ended
    uint256 public lastPauseTime; // Last time the contract was paused
    uint256 public totalPauseDuration; // Total duration contract was paused
    bool public isContractActive; // Indicates if the contract is active
    bool public isEpochStarted; // Indicates that epoch start or not
    uint256 private totalStakedAmount; // Total amount staked in the contract

    uint256 public lastProcessedIndex = 0; // Track last processed index
    uint256 public batchSize = 1000; // Default batch size (can be changed manually)

    mapping(uint256 => Epoch) public epochs; // Mapping of epoch number to Epoch struct
    mapping(address => UserInfo) public userInfo; // Mapping of user addresses to UserInfo struct
    mapping(address => bool) public hasStaked;    

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 indexed epoch, uint256 eaiAmount, uint256 usdcAmount);
    event RewardsClaimed(address indexed user, uint256 indexed epoch, uint256 eaiAmount, uint256 usdcAmount);
    event EpochExtended(uint256 indexed epoch, uint256 pauseDuration);
    event ContractActivated(address contractaddress, bool status);
    event FirstEpochStarted(uint256 startTime);
    event EpochStarted(uint256 indexed epoch, uint256 startTime);
    event FirstStake(address indexed user, uint256 amount, uint256 timestamp);
    event Rollover(address indexed user, uint256 newLockedStake);
    
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
        require(epochStartTime > 0, "please set epoch start Date");
        isContractActive = true;       
        emit ContractActivated(address(this),true);
    }

    /**
     * @dev Sets the start date for epoch 1. This can only be set once before any staking occurs.
     * @param dateTimestamp The timestamp for the epoch 1 start time.
     * @notice This function ensures that the epoch start date is set only if no staking has occurred.
     */
    function setEpoch1date(uint256 dateTimestamp) external onlyOwner{
        require(totalStakedAmount==0,"Staking has started");
        epochStartTime = dateTimestamp;
         // Update the end time based on the new start time
        epochEndTime = epochStartTime + EPOCH_DURATION;
    }
    /**
     * @dev Starts the first epoch. This function can only be called once by the owner.
     * @notice Epoch 1 cannot be started again once it has been initialized.
     * Emits {FirstEpochStarted} and {EpochStarted} events.
     */   
    function startEpoch1() external onlyOwner whenContractActive {
        require(block.timestamp >= epochStartTime ,"Epoch has not started yet");        
        require(!isEpochStarted, "Epoch 1 already started");
        require(epochStartTime > 0,"please set epoch start Date");
        
        currentEpoch = 1;
        isEpochStarted = true;
        emit FirstEpochStarted(epochStartTime);
        emit EpochStarted(currentEpoch, epochStartTime);
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
        if (!isEpochStarted || epochStartTime == 0) 
            return 0; 
        else if (paused())          
            return currentEpoch + 1;
        else{
            uint256 timeElapsed = block.timestamp - epochStartTime - totalPauseDuration;
            uint256 completedEpochs = timeElapsed / EPOCH_DURATION;
            return currentEpoch + completedEpochs; 
        }         
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
        
        if (getCurrentEpochNumber()  <= userinfo.lastStakeEpoch && userinfo.lastStakeEpoch!=0) {
            revert("Staking cooldown period is active, please wait until the next epoch.");
        }      

        totalStakedAmount += amount;
        // Only add to stakers array if not already added.
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

       if (userinfo.lastStakeEpoch < getCurrentEpochNumber()) {
            userinfo.lockedStake = userinfo.lockedStake + userinfo.pendingStake;
            userinfo.pendingStake = 0;
            userinfo.lastStakeEpoch = getCurrentEpochNumber();
        }    
       

        if(currentEpoch == 0){
            userinfo.lastStakeTimestamp = epochStartTime;
            userinfo.lastStakeEpoch = 1;           
            epochs[getCurrentEpochNumber()+1].totalStaked = totalStakedAmount;
            epochs[getCurrentEpochNumber()+1].totalLockstaked = totalStakedAmount;
            epochs[getCurrentEpochNumber()+1].rewardStakeBalance[msg.sender] = amount;
            userinfo.lastRolloverStake = 1;
             // For simplicity, all stakes made during the current epoch are recorded as pending.
            userinfo.lockedStake += amount;
        }else{           
            userinfo.lastStakeTimestamp = block.timestamp;    
            userinfo.lastStakeEpoch = getCurrentEpochNumber();    
            epochs[getCurrentEpochNumber()].totalStaked = totalStakedAmount;                  
            epochs[getCurrentEpochNumber()].rewardStakeBalance[msg.sender] = userinfo.lockedStake;
            userinfo.pendingStake += amount;            
        }
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
        uint256 totalUserStake = user_info.lockedStake + user_info.pendingStake;
        require(totalUserStake >= amount, "Insufficient staked amount");

       
        uint256 epochNumber = getCurrentEpochNumber();
        Epoch storage currentEpochData = epochs[epochNumber];

        // Ensure rewards for the current epoch have not been claimed
       // require(!user_info.hasClaimedRewards[epochNumber], "Cannot unstake after claiming rewards for this epoch");
        

       uint256 remaining = amount;
        // Remove from pending stake first.
        if (user_info.pendingStake >= remaining) {
            user_info.pendingStake -= remaining;
            remaining = 0;
        } else {
            remaining = remaining - user_info.pendingStake;
            user_info.pendingStake = 0;
        }
        // Then remove from locked stake.
        if (remaining > 0) {
            require(user_info.lockedStake >= remaining, "Insufficient locked stake");
            user_info.lockedStake -= remaining;
            epochs[getCurrentEpochNumber()].rewardStakeBalance[msg.sender] = user_info.lockedStake;
            uint256 currentEpochNumber = getCurrentEpochNumber();
            if (epochs[currentEpochNumber].totalStaked >= remaining) {
                epochs[currentEpochNumber].totalStaked -= remaining;
                epochs[currentEpochNumber].totalLockstaked -= remaining;    
            } else {
                epochs[currentEpochNumber].totalStaked = 0;
                epochs[currentEpochNumber].totalLockstaked = 0;
            }
        }
        totalStakedAmount -= amount;
        currentEpochData.totalStaked = totalStakedAmount;

        // Burn tdEAI tokens and return EAI tokens to the user
        tdEAIToken.burn(msg.sender, amount);
        require(eaiToken.transfer(msg.sender, amount), "EAI transfer failed");
        
        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Updates the epoch time based on the elapsed time since the last update.
     * Ensures the contract is active and not paused before execution.
     * - Calculates the number of completed epochs based on the elapsed time.
     * - Updates the `currentEpoch` count accordingly.
     * - Adjusts `epochStartTime` to align with the latest completed epoch.
     * - Sets `epochEndTime` to reflect the duration of the next epoch.
     * 
     * Requirements:
     * - Only the contract owner can call this function.
     * - The contract must not be paused.
     * - The contract must be active.
     */
    function updateEpochTime() external onlyOwner whenNotPaused whenContractActive {
        uint256 timeElapsed = block.timestamp - epochStartTime - totalPauseDuration;
        uint256 completedEpochs = timeElapsed / EPOCH_DURATION;

        // Update epoch number and start time
        currentEpoch += completedEpochs;
        epochStartTime += completedEpochs * EPOCH_DURATION;

        // Update the end time based on the new start time
        epochEndTime = epochStartTime + EPOCH_DURATION;
    }

    /**
     * @dev Processes stakers for a new epoch in batches to efficiently manage gas costs.
     * Transfers pending stakes to locked stakes and updates the epoch's total staked balances.
     * Ensures that each staker is processed only once per epoch.
     *
     * - Iterates through stakers from `lastProcessedIndex` to `batchSize` or the total number of stakers.
     * - Moves `pendingStake` to `lockedStake` for each staker if not already processed in the current epoch.
     * - Updates `rewardStakeBalance`, `totalStaked`, and `totalLockstaked` for the epoch.
     * - Updates `lastProcessedIndex` to track progress.
     * - Resets `lastProcessedIndex` when all stakers are processed.
     *
     * Requirements:
     * - Only the contract owner can call this function.
     * - The contract must not be paused.
     * - The contract must be active.
     */
    function processStakesForNewEpoch() external onlyOwner whenNotPaused whenContractActive {
        Epoch storage epochData = epochs[currentEpoch];
            
        uint256 stakerCount = stakers.length;
        uint256 endIndex = lastProcessedIndex + batchSize;

        if (endIndex > stakerCount) {
            endIndex = stakerCount;
        }

        // Process stakers in batches
        for (uint256 i = lastProcessedIndex; i < endIndex; i++) {

            address user = stakers[i];
            if(userInfo[user].lastRolloverStake!=currentEpoch ){

            // Transfer pending stake to locked stake
            uint256 pending = userInfo[user].pendingStake;
            userInfo[user].lockedStake += pending;
            userInfo[user].pendingStake = 0;
            userInfo[user].lastRolloverStake = currentEpoch;
            
             // Add locked stake to the epoch's total staked amount
            epochData.rewardStakeBalance[user] = userInfo[user].lockedStake;
            epochData.totalStaked += userInfo[user].lockedStake;
            epochData.totalLockstaked += userInfo[user].lockedStake;
            
            }
        }

        lastProcessedIndex = endIndex;

        // Reset index when all stakers are processed
        if (lastProcessedIndex >= stakerCount) {
            lastProcessedIndex = 0;
        }
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
        require(eaiToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance, approve contract first");
        require(isEpochStarted, "Epoch is not start");
        require(amount > 0, "Amount must be greater than 0");
        require( block.timestamp >= epochStartTime, "Staking has not started");
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
       
        emit RewardsDistributed(epochNumber, isUSDC ? 0 : amount, isUSDC ? amount : 0);
    }


    /**
     * @notice Claims the reward for a specific epoch.
     * @dev The caller specifies the epoch number, the wallet address to receive the reward, 
     * and the token type (USDC or EAI). The function calculates the reward based on the user's 
     * portion of the stake for that epoch and transfers the reward tokens to the provided wallet.
     *
     * Requirements:
     * - The specified epoch must be in the past (i.e. less than the current epoch).
     * - The caller must have a positive reward stake balance for that epoch.
     * - The reward tokens must be available in the contract.
     *
     * @param epoch The epoch number from which the rewards are to be claimed.     *
     * @param isUSDC Boolean flag indicating whether to claim USDC rewards (true) or EAI rewards (false).
     */
    function claimReward(uint256 epoch, bool isUSDC) external nonReentrant whenNotPaused whenContractActive {
        require(epoch < getCurrentEpochNumber(), "Can only claim rewards from past epochs");
        
        Epoch storage epochData = epochs[epoch];
        require(epochData.totalLockstaked > 0, "No stakes in this epoch");
        
        // Get the user's reward stake balance for the given epoch
        uint256 userStake = epochData.rewardStakeBalance[msg.sender];
        require(userStake > 0, "No reward stake for user in this epoch");
        
        uint256 rewardAmount;
        if (isUSDC) {
            require(epochData.usdcRewardStatus[msg.sender]==false, "Already claimed epoch." );
            // Calculate USDC reward based on user's share of the total stake in the epoch
            rewardAmount = (userStake * epochData.usdcRewards) / epochData.totalLockstaked;
            require(rewardAmount > 0, "No USDC reward available");
            require(usdcToken.transfer(msg.sender, rewardAmount), "USDC transfer failed");
            // Record the claim for USDC rewards
            userInfo[msg.sender].claimedUSDCRewards[epoch] = rewardAmount;
            epochData.usdcRewardStatus[msg.sender]=true;
            emit RewardsClaimed(msg.sender, epoch, 0, rewardAmount);
        } else {
            // Calculate EAI reward based on user's share of the total stake in the epoch
            require(epochData.eaiRewardStatus[msg.sender]==false, "Already claimed epoch." );
            rewardAmount = (userStake * epochData.eaiRewards) / epochData.totalLockstaked;
            require(rewardAmount > 0, "No EAI reward available");
            require(eaiToken.transfer(msg.sender, rewardAmount), "EAI transfer failed");
            // Record the claim for EAI rewards
            userInfo[msg.sender].claimedEAIRewards[epoch] = rewardAmount;
            epochData.eaiRewardStatus[msg.sender]=true;
            emit RewardsClaimed(msg.sender, epoch, rewardAmount, 0);
        }

      
    }
    /**
    * @dev Internal function to calculate the rewards (both EAI and USDC) for a user in a specific epoch.
    * @param epoch The epoch for which to calculate rewards.
    * @param user The address of the user.
    * @return rewardEAI The total EAI reward the user is entitled to in the epoch.
    * @return rewardUSDC The total USDC reward the user is entitled to in the epoch.
    */
    function _calculateEpochReward(uint256 epoch, address user) internal view returns (uint256 rewardEAI, uint256 rewardUSDC) {
        Epoch storage ep = epochs[epoch];
        // If no tokens were staked in the epoch, return zeros.
        if (ep.totalStaked == 0) {
            return (0, 0);
        }
        
        // Get user's reward stake balance.
        uint256 userStake = ep.rewardStakeBalance[user];
        if (userStake == 0) {
            return (0, 0);
        }
        
        // Calculate user's total entitled rewards.
        rewardEAI = (userStake * ep.eaiRewards) / ep.totalLockstaked;
        rewardUSDC = (userStake * ep.usdcRewards) / ep.totalLockstaked;
    }
    
    /**
    * @notice Claims all available rewards for the caller from past epochs (up to 12 epochs per call).
    * @dev Iterates over epochs from the one after the user's last fully claimed epoch up to a maximum of 12 epochs.
    *      For each epoch, it calculates the unclaimed rewards using _calculateEpochReward, transfers the rewards,
    *      updates the claim status, and resets the user's reward stake balance.
    */
    function claimAll() external nonReentrant whenNotPaused whenContractActive {
        require(hasStaked[msg.sender], "Not a staker"); // Ensure only stakers can claim
        uint256 currEpoch = getCurrentEpochNumber();
        UserInfo storage user = userInfo[msg.sender];
        uint256 startEpoch = user.lastClaimEpoch + 1;
        uint256 endEpoch = startEpoch + 12; // Limit to 12 epochs per call
        if (endEpoch > currEpoch) {
            endEpoch = currEpoch;
        }
        
        uint256 totalEAIRewards;
        uint256 totalUSDCRewards;
        
        for (uint256 epoch = startEpoch; epoch < endEpoch; epoch++) {
            Epoch storage ep = epochs[epoch];
            if (ep.totalLockstaked == 0) continue;
            
            uint256 userStake = ep.rewardStakeBalance[msg.sender];
            if (userStake == 0) continue;
            
            // Calculate the total rewards the user is entitled to.
            (uint256 entitledEAI, uint256 entitledUSDC) = _calculateEpochReward(epoch, msg.sender);
            
            // Determine the unclaimed rewards.
            uint256 unclaimedEAI = entitledEAI > user.claimedEAIRewards[epoch] ? entitledEAI - user.claimedEAIRewards[epoch] : 0;
            uint256 unclaimedUSDC = entitledUSDC > user.claimedUSDCRewards[epoch] ? entitledUSDC - user.claimedUSDCRewards[epoch] : 0;
            
            if (unclaimedEAI > 0 && !ep.eaiRewardStatus[msg.sender]) {
                totalEAIRewards += unclaimedEAI;
                user.claimedEAIRewards[epoch] = entitledEAI;
                ep.eaiRewardStatus[msg.sender] = true;
            }
            
            if (unclaimedUSDC > 0 && !ep.usdcRewardStatus[msg.sender]) {
                totalUSDCRewards += unclaimedUSDC;
                user.claimedUSDCRewards[epoch] = entitledUSDC;
                ep.usdcRewardStatus[msg.sender] = true;
            }
            
            // Reset the user's reward stake balance for this epoch.
            ep.rewardStakeBalance[msg.sender] = 0;
            user.lastClaimEpoch = epoch;
        }
        // **Require condition to check if no rewards exist**
        if(totalEAIRewards > 0 || totalUSDCRewards > 0){

        if (totalEAIRewards > 0) {
            require(eaiToken.transfer(msg.sender, totalEAIRewards), "EAI transfer failed");
        }
        if (totalUSDCRewards > 0) {
            require(usdcToken.transfer(msg.sender, totalUSDCRewards), "USDC transfer failed");
        }
        
        emit RewardsClaimed(msg.sender, user.lastClaimEpoch, totalEAIRewards, totalUSDCRewards);
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
    * @param userAddr The address of the user to check.
    * @return bool True if the user has staked tokens and the contract is inactive, false otherwise.
    */
    function isEligibleForRewards(address userAddr) external view returns (bool) {
        UserInfo storage userRec = userInfo[userAddr];
        return (userRec.lockedStake + userRec.pendingStake) > 0 && isContractActive;
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
    * @notice Returns the unclaimed reward amounts for a specific user in a given epoch.
    * @dev The function calculates the total rewards the user is entitled to based on their
    *      reward stake balance and then subtracts any rewards already claimed.
    *      If no stake exists or the epoch has no staked tokens, it returns zero for both rewards.
    * @param epoch The epoch number to query.
    * @param user The address of the user.
    * @return unclaimedEAI The unclaimed EAI rewards available for the user in the specified epoch.
    * @return unclaimedUSDC The unclaimed USDC rewards available for the user in the specified epoch.
    */
    function viewUnclaimedEpochReward(address user,uint256 epoch) external view returns (uint256 unclaimedEAI, uint256 unclaimedUSDC) {
       
        Epoch storage epochData = epochs[epoch];

        if (epochData.totalStaked == 0) {
            return (0, 0);
        }

        uint256 userStake = epochData.rewardStakeBalance[user];
        if (userStake == 0) {
            return (0, 0);
        }

        uint256 totalEAI = (userStake * epochData.eaiRewards) / epochData.totalLockstaked;
        uint256 totalUSDC = (userStake * epochData.usdcRewards) / epochData.totalLockstaked;

        uint256 claimedEAI = userInfo[user].claimedEAIRewards[epoch];
        uint256 claimedUSDC = userInfo[user].claimedUSDCRewards[epoch];

        unclaimedEAI = totalEAI > claimedEAI ? totalEAI - claimedEAI : 0;
        unclaimedUSDC = totalUSDC > claimedUSDC ? totalUSDC - claimedUSDC : 0;
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
    function viewUserClaimedRewards(address user, uint256 epoch) external view returns (uint256 eaiRewards, uint256 usdcRewards) {
        UserInfo storage userInfo_ = userInfo[user];
        return (
            userInfo_.claimedEAIRewards[epoch],
            userInfo_.claimedUSDCRewards[epoch]
        );  
    }

    /**
    * @notice Returns the aggregated unclaimed rewards (both EAI and USDC) for a user across past epochs.
    * @param user The address of the user.
    * @return totalUnclaimedEAI The total unclaimed EAI rewards.
    * @return totalUnclaimedUSDC The total unclaimed USDC rewards.
    */
    function viewAllReward(address user) external view returns (uint256 totalUnclaimedEAI, uint256 totalUnclaimedUSDC) {
        UserInfo storage userRec = userInfo[user];
        uint256 currEpoch = getCurrentEpochNumber();
        
        // Iterate over epochs from the one after the last fully claimed epoch up to current epoch.
        for (uint256 epoch = userRec.lastClaimEpoch + 1; epoch < currEpoch; epoch++) {
            (uint256 entitledEAI, uint256 entitledUSDC) = _calculateEpochReward(epoch, user);
            
            uint256 claimedEAI = userRec.claimedEAIRewards[epoch];
            uint256 claimedUSDC = userRec.claimedUSDCRewards[epoch];
            
            uint256 unclaimedEAI = entitledEAI > claimedEAI ? entitledEAI - claimedEAI : 0;
            uint256 unclaimedUSDC = entitledUSDC > claimedUSDC ? entitledUSDC - claimedUSDC : 0;
            
            totalUnclaimedEAI += unclaimedEAI;
            totalUnclaimedUSDC += unclaimedUSDC;
        }
    }

    /**
    * @notice Allows the contract owner to withdraw EAI tokens from the contract.
    * @dev This function enables the owner to withdraw a specified amount of EAI tokens from the contract. 
    *      It ensures that the withdrawal amount is greater than 0 and that the contract has enough EAI tokens. 
    *      If the conditions are met, the EAI tokens are transferred to the owner's address.
    * @param amount The amount of EAI tokens to withdraw.
    * @dev Reverts if the amount is 0, if the contract does not have enough EAI tokens, or if the transfer fails.
    */    
    function withdrawEAI(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(eaiToken.balanceOf(address(this)) > (amount + totalStakedAmount), "Insufficient EAI balance in contract");
        require(eaiToken.transfer(msg.sender, amount), "EAI transfer failed");
    }

    /**
    * @dev Withdraws a specified amount of USDC tokens from the contract.
    * Only callable by the owner.
    * Requirements:
    * - The withdrawal amount must be greater than 0.
    * - The contract must have a sufficient USDC balance.
    * - The USDC token transfer to the owner must succeed.
    * @param amount The amount of USDC tokens to withdraw.
    */
    function withdrawUSDC(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(usdcToken.balanceOf(address(this)) > amount, "Insufficient USDC balance in contract");
        require(usdcToken.transfer(msg.sender, amount), "USDC transfer failed");
    }

    /**
    * @dev Returns the reward stake balance for a specific user in a given epoch.
    * This value represents the portion of the user's staked tokens that are 
    * eligible for rewards in that epoch.
    * @param epoch The epoch number for which to retrieve the reward stake balance.
    * @param user The address of the user whose reward stake balance is being queried.
    * @return The reward stake balance of the user for the specified epoch.
    */
    function getUserRewardStakeBalance(uint256 epoch, address user) external view returns (uint256) {
        return epochs[epoch].rewardStakeBalance[user];
    }
}
