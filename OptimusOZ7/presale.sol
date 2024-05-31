// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @dev main presale contract.
 */
contract Presale {
    // State variables
    address public owner; // Address of the owner
    IERC20 public token; // ERC20 token being sold
    uint256 public price; // Price per token
    uint256 public vestingDuration = 4 * 30 days; // Vesting duration (4 months)
    uint256 public tgePercentage = 20; // TGE (Token Generation Event) percentage

    // Struct to store purchase details
    struct _purchaseDetails {
        uint256 purchaseid; // Purchase ID
        uint256 purchaseAmt; // Amount of tokens purchased
        uint256 purchaseStartTime; // Purchase start time
        uint256 purchaseEndTime; // Purchase end time (vesting end time)
        bool tgclaimed; // TGE (Token Generation Event) claimed
        uint256 tgeAmount; // TGE (Token Generation Event) amount
        uint256 vestedAmount; // Vested amount
    }

    // Mapping to store purchase details for each user
    mapping(address => mapping(uint256 => _purchaseDetails)) public purchase;

    // Mapping to store the number of purchases made by each user
    mapping(address => uint256) public noOfpurchase;

    // Constructor
    constructor(address _token, uint256 _price) {
        owner = msg.sender;
        token = IERC20(_token);
        price = _price;
    }

     /**
     * @dev Allows a user to buy tokens by transferring tokens from their account to this contract.
     * Calculates the cost based on the token amount and current price.
     * Increments the purchase count for the user.
     * Records the purchase details including purchase ID, amount, start and end times, TGE claim status,
     * TGE amount, and vested amount.
     * Transfers TGE tokens to the user.
     * 
     * Requirements:
     * - The token transfer from the user to this contract must be successful.
     * - The token transfer from this contract to the user must be successful.
     * 
     * @param _amount The amount of tokens to be purchased.
     */
    function buyTokens(uint256 _amount) external {
        uint256 cost = _amount * price;
        require(token.transferFrom(msg.sender, address(this), cost), "Token transfer failed");
        noOfpurchase[msg.sender] += 1;
        purchase[msg.sender][noOfpurchase[msg.sender]] = _purchaseDetails(
            noOfpurchase[msg.sender],
            _amount,
            block.timestamp,
            block.timestamp + vestingDuration,
            true,
            (_amount * tgePercentage) / 100,
            0
        );
        
        require(token.transfer(msg.sender, purchase[msg.sender][noOfpurchase[msg.sender]].tgeAmount*price), "Token transfer failed");
    }

    /**
     * @dev Allows the owner to adjust the price of the tokens.
     * 
     * Requirements:
     * - Only the owner can call this function.
     * 
     * @param _newPrice The new price per token.
     */
    function adjustPrice(uint256 _newPrice) external {
        require(msg.sender == owner, "Only owner can adjust price");
        price = _newPrice;
    }

    /**
     * @dev Allows a user to claim their vested tokens.
     * 
     * Calculates the vested amount for the specified purchase ID and transfers the tokens to the user.
     * 
     * Requirements:
     * - The user must have vested tokens to claim.
     * - The token transfer to the user must be successful.
     * 
     * @param _purchaseid The ID of the purchase for which tokens are to be claimed.
     */
    function claimTokens(uint256 _purchaseid) external {
        uint256 vestedAmounts = calculateVestedAmount(msg.sender, _purchaseid);
        require(vestedAmounts > 0, "No tokens to claim");
        require(token.transfer(msg.sender, vestedAmounts*price), "Token transfer failed");
       
    }

    /**
     * @dev Calculates the vested amount of tokens for a user's purchase.
     * 
     * If the current time is after the purchase end time, the entire remaining vested amount is claimable.
     * Otherwise, calculates the vested amount based on elapsed time and vesting duration.
     * 
     * Requirements:
     * - The user must have remaining vested tokens.
     * 
     * @param _user The address of the user.
     * @param _purchaseid The ID of the purchase.
     * @return The claimable vested amount of tokens.
     */
    function calculateVestedAmount(address _user, uint256 _purchaseid) internal returns (uint256) {
        uint256 uservestingamt = purchase[_user][_purchaseid].purchaseAmt - purchase[_user][_purchaseid].tgeAmount;
        uint256 claimable;
        if (block.timestamp >= purchase[_user][_purchaseid].purchaseEndTime) {
            claimable = uservestingamt - purchase[_user][_purchaseid].vestedAmount;
            purchase[_user][_purchaseid].vestedAmount = uservestingamt;
        } else {
            uint256 elapsedTime = block.timestamp - purchase[_user][_purchaseid].purchaseStartTime;
            uint256 vestingPeriods = elapsedTime / (vestingDuration / 4); // Divide the vesting period into 4 parts
            uint256 vested = (uservestingamt * vestingPeriods) / 4;
            require(vested > purchase[_user][_purchaseid].vestedAmount, "Nothing to claim");
            claimable = vested - purchase[_user][_purchaseid].vestedAmount;
            require(uservestingamt >= claimable, "Nothing to claim");
            purchase[_user][_purchaseid].vestedAmount = vested;
        }
        return claimable;
    }

     /**
     * @dev Calculates the total completed months since the purchase start time.
     * 
     * Divides the elapsed time by the vesting duration and assumes each month is divided into 4 parts.
     * 
     * @param _user The address of the user.
     * @param _purchaseid The ID of the purchase.
     * @return The total completed months.
     */
    function getTotalCompletedMonths(address _user, uint256 _purchaseid) public view returns (uint256) {
        uint256 elapsedTimeMonth = block.timestamp - purchase[_user][_purchaseid].purchaseStartTime;
        uint256 completedMonths = ((elapsedTimeMonth * 1000 / vestingDuration)) * 4; // Assuming each month is divided into 4 parts
        uint256 Months = 0;
        if (completedMonths < 2000 && completedMonths >= 1000)
            Months = 1;
        else if (completedMonths < 3000 && completedMonths >= 2000)
            Months = 2;
        else if (completedMonths < 4000 && completedMonths >= 3000)
            Months = 3;
        else if (completedMonths >= 4000) Months = 4;

        return Months;
    }
}
