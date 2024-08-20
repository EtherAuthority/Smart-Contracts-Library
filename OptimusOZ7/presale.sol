// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 *//**
 *Submitted for verification at testnet.bscscan.com on 2024-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    function getLatestPrice() public view returns (uint256) {
        (, uint256 price, , , ) = priceFeed.latestRoundData();

        return uint256(price);
    }
}

contract TokenPresale is Ownable, PriceConsumerV3 {
    enum PresalePhase {
        Phase1,
        Phase2,
        Phase3,
        Phase4,
        Phase5
    }

    struct PresaleInfo {
        uint256 totalTokens;
        uint256 tokenPrice;
    }

    struct PurchaseDetails {
        uint256 purchaseId;
        uint256 amount;
        uint256 purchaseTime;
        uint256 claimedAmount;
        uint256 purchaseStage;
    }

    /**
     * @dev Duration of the vesting period (4 months).
     */
    uint256 public constant VESTINGDURATION = (4 * 31 days);
    /**
     * @dev Timestamp for the start of the vesting period.
     */
    uint256 public vestingStartdate;

    /**
     * @dev Timestamp for the end of the vesting period.
     */
    uint256 public vestingEndDate;

    /**
     * @dev Mapping to store the number of purchases made by each buyer.
     */
    mapping(address => uint256) public noOfPurchases;

    /**
     * @dev Nested mapping to store purchase details for each buyer.
     */
    mapping(address => mapping(uint256 => PurchaseDetails)) public purchases;

    IERC20 public USDC = IERC20(0x5E1c50eEDF58d410B9402753855713A66e5F7003);
    IERC20 public token = IERC20(0x8083f306F987fd6965b1Cec9EaFc4e7Ac64B6c5c); 
    PresaleInfo[5] public presalePhases;

    event TokensPurchasedUsdc(
        address indexed buyer,
        uint256 amount,
        uint256 paidAmount,
        PresalePhase phase
    );

    event TokensClaimed(address indexed claimer, uint256 amount);

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526 //testnet bsc
            // 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE //mainnet bsc
        );

        presalePhases[uint256(PresalePhase.Phase1)] = PresaleInfo(
            50000000 * 1e18,
            100 * 1e18
        );
        presalePhases[uint256(PresalePhase.Phase2)] = PresaleInfo(
            50000000 * 1e18,
            66 * 1e18
        );
        presalePhases[uint256(PresalePhase.Phase3)] = PresaleInfo(
            50000000 * 1e18,
            50 * 1e18
        );
        presalePhases[uint256(PresalePhase.Phase4)] = PresaleInfo(
            50000000 * 1e18,
            40 * 1e18
        );
        presalePhases[uint256(PresalePhase.Phase5)] = PresaleInfo(
            50000000 * 1e18,
            33 * 1e18
        );
        vestingStartdate = block.timestamp + 90 days;
        vestingEndDate = vestingStartdate + VESTINGDURATION;
    }

    function buyTokensUSDC(uint256 amount, PresalePhase phase) public {
        require(amount > 0, "Can't buy tokens");
        require(
            phase == PresalePhase.Phase1 ||
                phase == PresalePhase.Phase2 ||
                phase == PresalePhase.Phase3 ||
                phase == PresalePhase.Phase4 ||
                phase == PresalePhase.Phase5,
            "Invalid phase"
        );
        PresaleInfo storage presale = presalePhases[uint256(phase)];
        uint256 tokensToBuy = usdcToToken(amount, phase);
        require(
            tokensToBuy <= presale.totalTokens,
            "Not enough tokens left for sale"
        );

        noOfPurchases[msg.sender] += 1;
        purchases[msg.sender][noOfPurchases[msg.sender]] = PurchaseDetails(
            noOfPurchases[msg.sender],
            tokensToBuy,
            block.timestamp,
            0,
            uint256(phase)
        );

        USDC.transferFrom(msg.sender, owner(), amount);
        emit TokensPurchasedUsdc(msg.sender, tokensToBuy, amount, phase);
    }

    function claimTokens() external {
        require(
            block.timestamp >= vestingStartdate,
            "Vesting period has not started yet"
        );

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
        require(
            token.transfer(msg.sender, claimableAmount),
            "Token transfer failed"
        );

        emit TokensClaimed(msg.sender, claimableAmount);
    }

    function usdcToToken(uint256 _amount, PresalePhase phase)
        public
        view
        returns (uint256)
    {
        PresaleInfo storage presale = presalePhases[uint256(phase)];
        uint256 numberOfTokens = (_amount * (presale.tokenPrice)) /
            10**(USDC.decimals());
        return numberOfTokens;
    }

    function withdrawBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setToken(IERC20 _token) external onlyOwner {
        require(
            address(_token) != address(0),
            "Token address cannot be the zero address"
        );
        token = _token;
    }

    function setUsdcToken(IERC20 _token) external onlyOwner {
        require(
            address(_token) != address(0),
            "Token address cannot be the zero address"
        );
        USDC = _token;
    }

    function setTokenPrice(PresalePhase phase, uint256 _price)
        external
        onlyOwner
    {
        require(
            phase == PresalePhase.Phase1 ||
                phase == PresalePhase.Phase2 ||
                phase == PresalePhase.Phase3 ||
                phase == PresalePhase.Phase4 ||
                phase == PresalePhase.Phase5,
            "Invalid phase"
        );
        presalePhases[uint256(phase)].tokenPrice = _price;
    }

    function fundsToken(uint256 _amount) external onlyOwner {
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function transferTokens(IERC20 _token) external onlyOwner {
        uint256 _value = _token.balanceOf(address(this));
        require(_value > 0, "Not enough tokens to withdraw");
        _token.transfer(msg.sender, _value);
    }

    function setTokensaleLimits(PresalePhase phase, uint256 _totalTokens)
        external
        onlyOwner
    {
        require(
            phase == PresalePhase.Phase1 ||
                phase == PresalePhase.Phase2 ||
                phase == PresalePhase.Phase3 ||
                phase == PresalePhase.Phase4 ||
                phase == PresalePhase.Phase5,
            "Invalid phase"
        );
        require(_totalTokens > 0, "Tokens must be greater than 0");
        presalePhases[uint256(phase)].totalTokens = _totalTokens;
    }

    function calculateVestedAmount(uint256 totalAmount)
        public
        view
        returns (uint256)
     {
        if (block.timestamp >= vestingEndDate) {
            return totalAmount;
        } else {
            uint256 elapsedTime = block.timestamp - vestingStartdate;
            uint256 vested;
                if (elapsedTime <= 31 days) {
                    // First month: 10%
                    vested = (totalAmount * 10) / 100;
                } else if (elapsedTime <= 62 days) {
                    // Second month: 10% + 15% = 25%
                    vested = (totalAmount * 25) / 100;
                } else if (elapsedTime <= 93 days) {
                    // Third month: 25% + 25% = 50%
                    vested = (totalAmount * 50) / 100;
                } else if (elapsedTime <= 124 days) {
                    // Fourth month: 50% + 25% = 75%
                    vested = (totalAmount * 75) / 100;
                } else {
                    // Fifth month: 75% + 25% = 100%
                    vested = totalAmount;
                }

            return vested;
        }
    }

        function changeVestingStartDate(uint256 newVestingStartDate) public onlyOwner returns (bool) {
        require(vestingStartdate >= newVestingStartDate, "Vesting time has started; you cannot modify the date.");
        vestingStartdate = newVestingStartDate;
        return true;
    }

}
interface IERC20 {
     /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PresaleVesting is Ownable{
    /**
     * @dev ERC20 token being sold in the presale.
     */
    IERC20 immutable public presaleToken;

    /**
     * @dev USDC token used for payments.
     */
    IERC20 immutable public usdcToken;

    /**
     * @dev USDT token used for payments.
     */
    IERC20 immutable public usdtToken;
    

    /**
     * @dev Timestamp when the presale starts.
     */
    uint256 immutable public  purchaseStartDate;

   /**
     * @dev Duration of the vesting period (4 months).
     */
    uint256 constant public  VESTINGDURATION = (4 * 31 days);
    /**
     * @dev Timestamp for the start of the vesting period.
     */
    uint256  public  vestingStartdate = 1726310400; // 14th September 2024

    /**
     * @dev Timestamp for the end of the vesting period.
     */
    uint256  public  vestingEndDate = vestingStartdate + VESTINGDURATION;

    /**
     * @dev Current active stage of the presale.
     */
    uint256 public activeStage = 1;

    /**
     * @dev Mapping to store prices for different stages.
     */
    mapping(uint256 => uint256) private purchaseStage;

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
     * @param token Total token in USDT.
     * @param timestamp Time of purchase.
     * @param stage Stage of the presale.
     */
    event Purchase(address indexed buyer, uint256 amount, uint256 token, uint256 timestamp, uint256 stage);

    /**
     * @dev Emitted when tokens are claimed.
     * @param claimer Address of the claimer.
     * @param amount Amount of tokens claimed.
     */
    event TokensClaimed(address indexed claimer, uint256 amount);

    /**
     * @dev Emitted when set stage price.
     * @param stage set 1 to 5.
     * @param price in decimal.
     */
    event SetStagePrice(uint256 stage , uint256 price);

    /**
     * @dev Emitted when stage changed.
     */
    event ChangeStage(uint256 stage);

    /**
     * @dev Constructor to initialize the contract with token addresses, price, and purchase start date.
     * @param _presaleToken Address of the presale token.
     * @param _usdtToken Address of the USDT token.
     * @param _price Initial price per token in the first stage.
     */
    constructor(IERC20 _presaleToken, IERC20 _usdtToken, IERC20 _usdcToken, uint256 _price, uint256 _purchaseStartDate) {
        presaleToken = _presaleToken;
        usdcToken = _usdcToken;
        usdtToken = _usdtToken;
        purchaseStartDate = _purchaseStartDate;
        purchaseStage[activeStage-1] = _price;
    }

    /**
     * @dev Sets the price for a specific stage.
     * @param stage Stage number (1-5).
     * @param price Price per token for the stage.
     */
    function setStagePrice(uint256 stage, uint256 price) external onlyOwner {        
        require(stage > 0  && stage <= 5 , "Please select valid stage!");
        require(activeStage-1 <= stage-1, "Please set correct stage!");
        purchaseStage[stage-1] = price;
        emit SetStagePrice(stage , price);
    }

    
     /**
     * @dev Changes the vesting start date.
     * 
     * Requirements:
     * - The new vesting start date must be earlier than or equal to the current vesting start date.
     * - The new vesting start date must be later than or equal to the purchase start date.
     * - Can only be called by the owner.
     * 
     * @param newVestingStartDate The new start date for the vesting period.
     * @return bool Returns true if the operation was successful.
     */
    function changeVestingStartDate(uint256 newVestingStartDate) public onlyOwner returns (bool) {
        // Ensure the new vesting start date is not earlier than the current vesting start date
        require(vestingStartdate >= newVestingStartDate, "Vesting time has started; you cannot modify the date.");
        
        // Ensure the new vesting start date is after or equal to the purchase start date
        require(purchaseStartDate <= newVestingStartDate, "Vesting start date should be greater than or equal to the purchase start date.");
        
        // Update the vesting start date to the new date
        vestingStartdate = newVestingStartDate;
        
        return true; // Indicate that the operation was successful
    }

    /**
     * @dev Changes the current active stage.
     */
    function changeStage() external onlyOwner {        
        require(activeStage <= 5, "You can change stage till the 5th stage!");
        require(purchaseStage[activeStage++] > 0, "Please set price before change stage!");
        emit ChangeStage(activeStage);
    }

    /**
     * @dev Allows users to buy tokens during the presale.
     * @param amount Number of tokens to purchase.
     * @param _token The token to use for the purchase ("USDT" or "USDC").
     */
    function buyTokens(uint256 amount , string memory _token) external {
        require(block.timestamp >= purchaseStartDate, "Presale purchase not active yet!");
        require(amount > 0, "Please set valid token amount!");
        uint256 token = (amount * (10 ** 18) / purchaseStage[activeStage - 1]); 
       if (keccak256(bytes(_token)) == keccak256(bytes("USDT"))) {
            require(usdtToken.transferFrom(msg.sender, owner(), amount), "USDT transfer failed");
        } else if (keccak256(bytes(_token)) == keccak256(bytes("USDC"))) {
            require(usdcToken.transferFrom(msg.sender, owner() , amount), "USDC transfer failed");
        } else {
            revert("Unsupported token");
        }

        noOfPurchases[msg.sender] += 1;
        purchases[msg.sender][noOfPurchases[msg.sender]] = PurchaseDetails(
            noOfPurchases[msg.sender],
            token,
            block.timestamp,
            0,
            activeStage
        );

        emit Purchase(msg.sender, amount, token, block.timestamp, activeStage);
    }

    /**
     * @dev Allows users to claim their vested tokens.
     */
    function claimTokens() external {
        require(block.timestamp >= vestingStartdate, "Vesting period has not started yet");

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
        require(presaleToken.transfer(msg.sender, claimableAmount), "Token transfer failed");
    

        
        emit TokensClaimed(msg.sender, claimableAmount);
    }

    /**
     * @dev Calculates the vested amount of tokens.
     * @param totalAmount Total number of tokens purchased.
     * @return Vested amount of tokens.
     */
    function calculateVestedAmount(uint256 totalAmount) public view returns (uint256) {
        if (block.timestamp < vestingStartdate) {
            return 0;
        } else if (block.timestamp >= vestingEndDate) {
            return totalAmount;
        } else {
            uint256 elapsedTime = block.timestamp - vestingStartdate;
            uint256 vestingPeriods = elapsedTime / (VESTINGDURATION / 4); // Divide the vesting period into 4 parts
            uint256 vested = (totalAmount * vestingPeriods) / 4;
            return vested;
        }
    }

    /**
    * @dev Returns the price of tokens at the current presale stage.
    * 
    * The presale stages are defined in the `purchaseStage` mapping, and the `activeStage`
    * variable indicates the current stage. This function retrieves the price for the 
    * current stage, which is `activeStage - 1` due to zero-based indexing in the mapping.
    * 
    * @return The price of tokens at the current presale stage.
    */
    function viewPresaleStage() public view returns(uint256) {
        return purchaseStage[activeStage-1];
    }
}
