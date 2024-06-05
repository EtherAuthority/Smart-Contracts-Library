// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the total supply of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner` through {transferFrom}. This is zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. 
     * One possible solution to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism. `value` is then deducted from the caller's allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract PresaleVesting {
    /**
     * @dev ERC20 token being sold in the presale.
     */
    IERC20 public presaleToken;

    /**
     * @dev USDT token used for payments.
     */
    IERC20 public usdtToken;

    /**
     * @dev Address of the contract owner.
     */
    address public owner;

    /**
     * @dev Timestamp when the presale starts.
     */
    uint256 public purchaseStartDate;

    /**
     * @dev Duration of the vesting period (4 months).
     */
    uint256 public vestingDuration = (4 * 31 days);

    /**
     * @dev Timestamp for the start of the vesting period.
     */
    uint256 public vestingStartDate = 1726310400; // 14th September 2024

    /**
     * @dev Timestamp for the end of the vesting period.
     */
    uint256 public vestingEndDate = vestingStartDate + vestingDuration;

    /**
     * @dev Current active stage of the presale.
     */
    uint256 public activeStage = 1;

    /**
     * @dev Mapping to store prices for different stages.
     */
    mapping(uint256 => uint256) public purchaseStage;

    /**
     * @dev Struct to store purchase details.
     */
    struct PurchaseDetails {
        uint256 purchaseId;
        uint256 amount;
        uint256 purchaseTime;
        uint256 claimedAmount;
        uint256 purchaseStage;
    }

    /**
     * @dev Mapping to store the number of purchases made by each buyer.
     */
    mapping(address => uint256) public noOfPurchases;

    /**
     * @dev Nested mapping to store purchase details for each buyer.
     */
    mapping(address => mapping(uint256 => PurchaseDetails)) public purchases;

    /**
     * @dev Emitted when a purchase is made.
     * @param buyer Address of the buyer.
     * @param amount Amount of tokens purchased.
     * @param cost Total cost in USDT.
     * @param timestamp Time of purchase.
     * @param stage Stage of the presale.
     */
    event Purchase(address indexed buyer, uint256 amount, uint256 cost, uint256 timestamp, uint256 stage);

    /**
     * @dev Emitted when tokens are claimed.
     * @param claimer Address of the claimer.
     * @param amount Amount of tokens claimed.
     */
    event TokensClaimed(address indexed claimer, uint256 amount);

    /**
     * @dev Constructor to initialize the contract with token addresses, price, and purchase start date.
     * @param _presaleToken Address of the presale token.
     * @param _usdtToken Address of the USDT token.
     * @param _price Initial price per token in the first stage.
     */
    constructor(IERC20 _presaleToken, IERC20 _usdtToken, uint256 _price) {
        owner = msg.sender;
        presaleToken = _presaleToken;
        usdtToken = _usdtToken;
        purchaseStartDate = block.timestamp;
        purchaseStage[activeStage-1] = _price;
    }

    /**
     * @dev Sets the price for a specific stage.
     * @param _stage Stage number (1-5).
     * @param _price Price per token for the stage.
     */
    function setStagePrice(uint256 _stage, uint256 _price) external {
        require(msg.sender == owner, "Only owner can adjust price!");
        require(_stage >= 1 && _stage <= 5 , "Please select valid stage!");
        purchaseStage[_stage-1] = _price;
    }

    /**
     * @dev Changes the current active stage.
     */
    function changeStage() external {
        require(msg.sender == owner, "Only owner can adjust price");
        require(activeStage <= 5, "You can change stage till the 5th stage");
        require(purchaseStage[activeStage++] > 0, "Please set price before change stage!");
    }

    /**
     * @dev Allows users to buy tokens during the presale.
     * @param _amount Number of tokens to purchase.
     */
    function buyTokens(uint256 _amount) external {
        require(block.timestamp >= purchaseStartDate, "Presale purchase not active yet!");
        require(_amount > 0, "Please set valid token amount!");
        uint256 cost = _amount * purchaseStage[activeStage - 1];        
        require(usdtToken.transferFrom(msg.sender, address(this), cost), "Token transfer failed");

        noOfPurchases[msg.sender] += 1;
        purchases[msg.sender][noOfPurchases[msg.sender]] = PurchaseDetails(
            noOfPurchases[msg.sender],
            _amount,
            block.timestamp,
            0,
            activeStage
        );

        emit Purchase(msg.sender, _amount, cost, block.timestamp, activeStage);
    }

    /**
     * @dev Allows users to claim their vested tokens.
     */
    function claimTokens() external {
        require(block.timestamp >= vestingStartDate, "Vesting period has not started yet");

        uint256 claimableAmount;
        for (uint256 i = 1; i <= noOfPurchases[msg.sender]; i++) {
            PurchaseDetails storage purchase = purchases[msg.sender][i];
            uint256 vestedAmount = calculateVestedAmount(purchase.amount);
            uint256 unclaimedAmount = vestedAmount - purchase.claimedAmount;
            if (unclaimedAmount > 0) {
                claimableAmount += unclaimedAmount;
                purchase.claimedAmount = vestedAmount;
            }
        }

        require(claimableAmount > 0, "No tokens available for claiming");
        presaleToken.transfer(msg.sender, claimableAmount);
        emit TokensClaimed(msg.sender, claimableAmount);
    }

    /**
     * @dev Calculates the vested amount of tokens.
     * @param totalAmount Total number of tokens purchased.
     * @return Vested amount of tokens.
     */
    function calculateVestedAmount(uint256 totalAmount) public view returns (uint256) {
        if (block.timestamp < vestingStartDate) {
            return 0;
        } else if (block.timestamp >= vestingEndDate) {
            return totalAmount;
        } else {
            uint256 elapsedTime = block.timestamp - vestingStartDate;
            uint256 vestingPeriods = elapsedTime / (vestingDuration / 4); // Divide the vesting period into 4 parts
            uint256 vested = (totalAmount * vestingPeriods) / 4;
            return vested;
        }
    }
}
