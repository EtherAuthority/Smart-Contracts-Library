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
        uint256 maxAmount; // Maximum amount for this phase
    }

    struct PurchaseDetails {
        uint256 purchaseId;
        uint256 amount;
        uint256 purchaseTime;
        uint256 claimedAmount;
        uint256 purchaseStage;
        uint256 claimedMonth;        
    }

    /**
     * @dev Duration of the vesting period (4 months).
     */
    uint256 public constant VESTINGDURATION = (5 * 31 days);
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
    uint256 public noOfPurchases;

    /**
     * @dev Nested mapping to store purchase details for each buyer.
     */
    mapping(address => mapping(uint256 => PurchaseDetails)) public purchases;

    /**
    * @dev Mapping to track the total amount of USDC spent by each address
    */
    mapping(address => mapping(uint256 => uint256)) public totalSpentByAddress;

   /**
   * @dev Define the maximum purchase limit
   */
    uint256 public constant MAX_PURCHASE_AMOUNT = 10000 * 1e6; // $10,000 in USDC (assuming 6 decimals)
    // State variables for presale and claim phases
    bool public presaleActive;
    bool public claimActive;


    IERC20 public USDC = IERC20(0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d);
    IERC20 public token = IERC20(0x0fC5025C764cE34df352757e82f7B5c4Df39A836); 
    PresaleInfo[5] public presalePhases;

    event TokensPurchasedUsdc(
        address indexed buyer,
        uint256 amount,
        uint256 paidAmount,
        PresalePhase phase
    );

    event TokensClaimed(address indexed claimer, uint256 amount);

    // Modifier to check if presale is active
    modifier whenPresaleActive() {
        require(presaleActive, "Presale is not active");
        _;
    }

    // Modifier to check if claim is active
    modifier whenClaimActive() {
        require(claimActive, "Claim phase is not active");
        _;
    }

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526 //testnet bsc
            // 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE //mainnet bsc
        );

        presalePhases[uint256(PresalePhase.Phase1)] = PresaleInfo(
            token.totalSupply() * 2 / 100,
            100 * 1e18,
            10000000 * 1e6 // Set an initial max amount for Phase 1
        );
        presalePhases[uint256(PresalePhase.Phase2)] = PresaleInfo(
            token.totalSupply() * 3 / 100,
            66 * 1e18,
            15000000 * 1e6 // Set an initial max amount for Phase 2
        );
        presalePhases[uint256(PresalePhase.Phase3)] = PresaleInfo(
            token.totalSupply() * 4 / 100,
            50 * 1e18,
            20000000 * 1e6 // Set an initial max amount for Phase 3
        );
        presalePhases[uint256(PresalePhase.Phase4)] = PresaleInfo(
            token.totalSupply() * 5 / 100,
            40 * 1e18,
            25000000 * 1e6 // Set an initial max amount for Phase 4
        );
        presalePhases[uint256(PresalePhase.Phase5)] = PresaleInfo(
            token.totalSupply() * 6 / 100,
            33 * 1e18,
            30000000 * 1e6 // Set an initial max amount for Phase 5
        );
       
        vestingEndDate = vestingStartdate + VESTINGDURATION;
    }
    // Admin function to start the presale
    function startPresale() external onlyOwner {
        require(claimActive!=true,"Vesting time already started");
        presaleActive = true;
        claimActive = false;        
    }

    // Admin function to close the presale
    function closePresale() external onlyOwner {
        presaleActive = false;
    }

    // Admin function to start the claim phase
    function startClaiming() external onlyOwner {
        require(!presaleActive, "Presale is still active");
        require(claimActive!=true,"Vesting time already started");
        claimActive = true;
        vestingStartdate=block.timestamp;
    }

    // Admin function to terminate the presale and start claiming
    function terminatePresaleAndStartClaim() external onlyOwner {
        require(claimActive!=true,"Vesting time already started");
        presaleActive = false;
        claimActive = true;
    }
    // Function to allow the owner to set the max amount for a specific phase
    function setMaxAmount(PresalePhase phase, uint256 maxAmount) external onlyOwner {
        require(
            phase == PresalePhase.Phase1 ||
            phase == PresalePhase.Phase2 ||
            phase == PresalePhase.Phase3 ||
            phase == PresalePhase.Phase4 ||
            phase == PresalePhase.Phase5,
            "Invalid phase"
        );
        require(maxAmount > 0, "Max amount must be greater than 0");
        presalePhases[uint256(phase)].maxAmount = maxAmount;
    }


    function buyTokensUSDC(uint256 amount, PresalePhase phase) public whenPresaleActive {
        require(amount > 0, "Can't buy tokens! Amount should be grater then 0.");
        require(
            phase == PresalePhase.Phase1 ||
            phase == PresalePhase.Phase2 ||
            phase == PresalePhase.Phase3 ||
            phase == PresalePhase.Phase4 ||
            phase == PresalePhase.Phase5,
            "Invalid phase"
        );

        require(
            totalSpentByAddress[msg.sender][uint256(phase)] + amount <= MAX_PURCHASE_AMOUNT,
            "Purchase exceeds maximum allowed"
        );
        
        require(amount <= presalePhases[uint256(phase)].maxAmount, "Purchase exceeds max amount for this phase");

        PresaleInfo storage presale = presalePhases[uint256(phase)];
        uint256 tokensToBuy = usdcToToken(amount, phase);
        require(tokensToBuy <= presale.totalTokens, "Not enough tokens left for sale");

        PurchaseDetails storage newPurchase = purchases[msg.sender][uint256(phase)];
        bool isNewPurchase = newPurchase.amount == 0;

        if (isNewPurchase) {
            noOfPurchases++;
            newPurchase.purchaseId = noOfPurchases;
        }

        newPurchase.amount += tokensToBuy;
        newPurchase.purchaseTime = block.timestamp;
        newPurchase.claimedAmount = 0;
        newPurchase.purchaseStage = uint256(phase);
        newPurchase.claimedMonth = 0;
        
        totalSpentByAddress[msg.sender][uint256(phase)] += amount;
        USDC.transferFrom(msg.sender, owner(), amount);
        emit TokensPurchasedUsdc(msg.sender, tokensToBuy, amount, phase);
    }



    function claimTokens(PresalePhase phase) whenClaimActive external {
        claimCalculation(msg.sender,phase);
    }

    function onlyOwnerClaimTokens(address[] memory users,PresalePhase phase) public onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            claimCalculation(users[i],phase);
        }
    }

    function claimCalculation(address wallet,PresalePhase phase) public {
       
        uint256 claimableAmount;
       
        PurchaseDetails storage purchase = purchases[wallet][uint256(phase)];
        (uint256 vestedAmount, uint256  updatedclaimMonth)= calculateVestedAmount(purchase.amount,purchase.claimedMonth);
        uint256 unclaimedAmount = purchase.amount - purchase.claimedAmount;
        purchase.claimedMonth=updatedclaimMonth;
        if (unclaimedAmount > 0) {
            claimableAmount += unclaimedAmount;
            purchase.claimedAmount += vestedAmount;            
        }else if(unclaimedAmount == 0){
            purchase.amount=0;
        }
    

        require(claimableAmount > 0, "No tokens available for claiming");
        require(
            token.transfer(wallet, claimableAmount),
            "Token transfer failed"
        );

        emit TokensClaimed(wallet, claimableAmount);
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

    function calculateVestedAmount(uint256 totalAmount, uint256 claimedMonth)
        public
        view
        returns (uint256,uint256)
    {
        uint256 vestedAmount = 0;
       
        if (block.timestamp >= vestingStartdate + (1 * 31 days) && claimedMonth == 0) {
            vestedAmount += (totalAmount * 10) / 100;
            claimedMonth = 1;
        }
        if (block.timestamp >= vestingStartdate + (2 * 31 days) && claimedMonth == 1) {
            vestedAmount += (totalAmount * 15) / 100;
            claimedMonth = 2;
        }
        if (block.timestamp >= vestingStartdate + (3 * 31 days)  && claimedMonth == 2) {
            vestedAmount += (totalAmount * 25) / 100;
            claimedMonth = 3;
        }
        if (block.timestamp >= vestingStartdate + (4 * 31 days) && claimedMonth == 3) {
            vestedAmount += (totalAmount * 25) / 100;
            claimedMonth = 4;
        }
        if (block.timestamp >= vestingStartdate + (5 * 31 days) && claimedMonth == 4) {
            vestedAmount += (totalAmount * 25) / 100;
            claimedMonth = 5;
        }
       
        return (vestedAmount,claimedMonth);       
            
    }      

    // Function to get claims per stage for a given address and presale phase
    function getClaimsPerStage(address wallet, PresalePhase phase) public view returns (uint256) {
        PurchaseDetails storage purchase = purchases[wallet][uint256(phase)]; 
        return  purchase.claimedAmount;
    }

    // Admin function to withdraw unsold tokens
    function withdrawUnsoldTokens() external onlyOwner {
        require(!presaleActive, "Presale is still active");
        uint256 unsoldTokens = token.balanceOf(address(this));
        token.transfer(owner(), unsoldTokens);
    }

}
