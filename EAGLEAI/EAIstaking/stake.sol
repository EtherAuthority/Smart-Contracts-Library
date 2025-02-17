// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Interface for the TdEAI token, allowing minting and burning of tokens.
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
        bool finalized;        // Indicates if the epoch is finalized
    }

    struct UserInfo {
        uint256 stakedAmount; // Amount of EAI tokens staked by the user
        uint256 lastStakeTimestamp; // Timestamp of the last stake
        uint256 lastStakeEpoch; // Last epoch in which the user staked
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
    event ContractActivated();
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
        currentEpoch = 1;
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
     * @dev Activates the contract, allowing staking operations to begin.
     *      Can only be called by the owner.
     */
    function activateContract() external onlyOwner {
        require(!isContractActive, "Contract is already active");
        isContractActive = true;
        emit ContractActivated();
    }

    /**
     * @dev Returns the current epoch number based on time elapsed.
     * @return uint256 The current epoch number
     */
    function getCurrentEpochNumber() public view returns (uint256) {
        if (epochStartTime == 0 || paused()) {
            return currentEpoch;
        }
        uint256 timeElapsed = block.timestamp - epochStartTime - totalPauseDuration;
        uint256 completedEpochs = timeElapsed / EPOCH_DURATION;
        return currentEpoch + completedEpochs;
    }

    /**
     * @dev Allows users to stake EAI tokens into the contract.
     *      The first stake initializes the epoch system.
     * @param amount Amount of EAI tokens to stake
     */
    function stake(uint256 amount) external nonReentrant whenNotPaused whenContractActive {
        require(amount > 0, "Cannot stake 0");
        require(eaiToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance, approve contract first");
        require(eaiToken.balanceOf(msg.sender) >= amount, "Insufficient EAI balance");
        require(eaiToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        UserInfo storage userinfo = userInfo[msg.sender];
        
        if (epochStartTime == 0) {
            epochStartTime = block.timestamp;
            emit FirstStake(msg.sender, amount, block.timestamp);
            emit EpochStarted(getCurrentEpochNumber(), epochStartTime);
        }

        userinfo.stakedAmount += amount;
        userinfo.lastStakeTimestamp = block.timestamp;
        totalStakedAmount += amount;
        epochs[getCurrentEpochNumber()].totalStaked = totalStakedAmount;

        tdEAIToken.mint(msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Allows users to unstake their EAI tokens after meeting epoch requirements.
     * @param amount Amount of EAI tokens to unstake
     */
    function unstake(uint256 amount) external nonReentrant whenNotPaused whenContractActive {
        require(amount > 0, "Cannot unstake 0");
        require(tdEAIToken.balanceOf(msg.sender) >= amount, "Insufficient tdEAI balance");

        UserInfo storage user_info = userInfo[msg.sender];
        require(user_info.stakedAmount >= amount, "Insufficient staked amount");

        user_info.stakedAmount -= amount;
        totalStakedAmount -= amount;
        epochs[getCurrentEpochNumber()].totalStaked = totalStakedAmount;

        tdEAIToken.burn(msg.sender, amount);
        require(eaiToken.transfer(msg.sender, amount), "EAI transfer failed");
        emit Unstaked(msg.sender, amount);
    }

 /**
     * @dev Distributes rewards (either USDC or EAI) for the current epoch.
     * @param amount The amount of rewards to be distributed.
     * @param isUSDC Boolean indicating if the reward is in USDC (true) or EAI (false).
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
     * @dev Internal function to claim rewards from past epochs.
     */
    function claim() internal {
        require(epochStartTime > 0, "Staking has not started");

        UserInfo storage user = userInfo[msg.sender];
        uint256 lastClaimedEpoch = user.lastStakeEpoch;
        uint256 latestEpoch = getCurrentEpochNumber();

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

        if (totalEAIRewards > 0) {
            require(eaiToken.transfer(msg.sender, totalEAIRewards), "EAI reward transfer failed");
        }
        if (totalUSDCRewards > 0) {
            require(usdcToken.transfer(msg.sender, totalUSDCRewards), "USDC reward transfer failed");
        }

        if (totalEAIRewards > 0) {
            user.lastStakeEpoch = latestEpoch - 1;
            emit RewardsClaimed(msg.sender, latestEpoch - 1, totalEAIRewards, totalUSDCRewards);
        }
    }

    /**
     * @dev Public function to claim rewards, ensuring reentrancy protection.
     */
    function claimRewards() public nonReentrant whenNotPaused whenContractActive {
        require(epochStartTime > 0, "Staking has not started");

        UserInfo storage user = userInfo[msg.sender];
        uint256 lastClaimedEpoch = user.lastStakeEpoch;
        uint256 latestEpoch = getCurrentEpochNumber();
        require(lastClaimedEpoch < latestEpoch, "No new rewards available");

        uint256 totalEAIRewards = 0;
        uint256 totalUSDCRewards = 0;

        for (uint256 epoch = lastClaimedEpoch + 1; epoch < latestEpoch; epoch++) {
            if (user.hasClaimedRewards[epoch]) continue;

            uint256 userStake = user.stakedAmount;
            if (userStake == 0) continue;

            Epoch storage epochData = epochs[epoch];
            if (epochData.eaiRewards == 0 && epochData.usdcRewards == 0) continue;

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

        user.lastStakeEpoch = latestEpoch - 1;
        emit RewardsClaimed(msg.sender, latestEpoch - 1, totalEAIRewards, totalUSDCRewards);
    }

    /**
     * @dev Updates the epoch by finalizing the previous epoch and carrying forward staking amounts.
     */
    function updateEpoch() internal {
        if (epochStartTime == 0 || paused()) {
            return;
        }

        uint256 newEpochNumber = getCurrentEpochNumber();
        if (currentEpoch < newEpochNumber) {
            epochs[currentEpoch].finalized = true;

            for (uint256 i = currentEpoch + 1; i <= newEpochNumber; i++) {
                epochs[i].totalStaked = epochs[currentEpoch].totalStaked;
            }

            currentEpoch = newEpochNumber;
            epochs[currentEpoch].totalStaked = totalStakedAmount;
            epochStartTime = block.timestamp - ((block.timestamp - epochStartTime - totalPauseDuration) % EPOCH_DURATION);

            emit EpochStarted(currentEpoch, epochStartTime);
        }
    }

    /**
     * @dev Withdraw function to allow the owner to extract EAI tokens.
     * @param amount The amount of EAI tokens to withdraw.
     */
    function withdrawEAI(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(eaiToken.balanceOf(address(this)) >= amount, "Insufficient EAI balance in contract");
        require(eaiToken.transfer(msg.sender, amount), "EAI transfer failed");
    }
}
