// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import 'hardhat/console.sol';


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
        uint256 startDateTime; // Start date and time for this phase
        uint256 endDateTime;   // End date and time for this phase
        bool activeStage;
    }

    struct PurchaseDetails {
        uint256 purchaseId;
        uint256 tokenAmount;
        uint256 usdcAmount;
        uint256 purchaseTime;       
        uint256 purchaseStage;           
    }
    uint256 public totalNoOfPurchaseToken;
    /**
     * @dev Duration of the vesting period (4 months).
     */
    uint256 public constant VESTINGDURATION = (5 * 2 minutes);
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

    mapping(address => uint256) public totalPurchased; // Store the total purchase amount per buyer
    mapping(address => uint256) public totalClaimed;   // Store the total claimed amount per buyer
    mapping(address => mapping(uint8 => bool)) public hasClaimed; // Track which vesting months the buyer has claimed

    uint256 public vestingStartTime; // Timestamp for when vesting begins

    // Vesting percentages by month (month 1 = 10%, month 2 = 15%, month 3-5 = 25%)
    uint8[5] public vestingPercentages = [10, 15, 25, 25, 25];

   /**
   * @dev Define the maximum purchase limit
   */
    uint256 public constant MAX_PURCHASE_AMOUNT = 10000 * 1e6; // $10,000 in USDC (assuming 6 decimals)
    // State variables for presale and claim phases
    bool public presaleActive;
    bool public claimActive;


    IERC20 public USDC = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);
    IERC20 public token = IERC20(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8); 
    PresaleInfo[5] public presalePhases;

    event TokensPurchasedUsdc(
        address indexed buyer,
        uint256 amount,
        uint256 paidAmount,
        uint256 phase
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
            10000000 * 1e18, // Set an initial max amount for Phase 1
            100 * 1e18,
            0,
            1727264987,      // Start date for Phase 1 (example timestamp)
            1727405429,      // End date for Phase 1 (example timestamp)
            false            // Active stage
        );
        presalePhases[uint256(PresalePhase.Phase2)] = PresaleInfo(
            15000000 * 1e18, // Set an initial max amount for Phase 2
            66 * 1e18,
            0,
            1730991600,      // Start date for Phase 2 (example timestamp)
            1734966000,      // End date for Phase 2 (example timestamp)
            false            // Active stage
        );
        presalePhases[uint256(PresalePhase.Phase3)] = PresaleInfo(
            20000000 * 1e18, // Set an initial max amount for Phase 3
            50 * 1e18,
            0,
            1734966000,      // Start date for Phase 3 (example timestamp)
            1736348400,      // End date for Phase 3 (example timestamp)
            false            // Active stage
        
        );
        presalePhases[uint256(PresalePhase.Phase4)] = PresaleInfo(
            25000000 * 1e18, // Set an initial max amount for Phase 4
            40 * 1e18,
            0,
            1736348400,      // Start date for Phase 4 (example timestamp)
            1741100400,      // End date for Phase 4 (example timestamp)
            false            // Active stage
        );
        presalePhases[uint256(PresalePhase.Phase5)] = PresaleInfo(
            30000000 * 1e18, // Set an initial max amount for Phase 5
            33 * 1e18,
            0,
            1741100400,      // Start date for Phase 5 (example timestamp)
            1746896400,      // End date for Phase 5 (example timestamp)
            false            // Active stage
        );
        
    }
    // Admin function to start the presale
    function startPresale() external onlyOwner {
        require(claimActive!=true,"Vesting time already started");
        presaleActive = true;       
        updateActivePhases();  
    }

    function updateActivePhases() public onlyOwner {    

    for (uint256 i = 1; i <= presalePhases.length; i++) {
            if (block.timestamp >= presalePhases[i-1].startDateTime && block.timestamp <= presalePhases[i-1].endDateTime) {
                presalePhases[i-1].activeStage = true;
            } else {
                presalePhases[i-1].activeStage = false;
            }
        }
    }

    function activePhase() public returns(uint256){        
        for (uint256 i = 0; i < presalePhases.length; i++) {           
                require(presalePhases[i].activeStage == true,"Phase is not active!");
                return i;            
        }
    }


    // Admin function to close the presale
    function closePresale() external onlyOwner {
        presaleActive = false;
    }

    // Admin function to start the claim phase
    function startClaiming() external onlyOwner {        
        require(noOfPurchases > 0, "There are no purchases for claim");        
        require(!presaleActive, "Presale is still active");
        require(claimActive!=true,"Vesting time already started");
        claimActive = true;
        vestingStartdate=block.timestamp;
        vestingEndDate = vestingStartdate + VESTINGDURATION;
    }

    // Admin function to terminate the presale and start claiming
    function terminatePresaleAndStartClaim() external onlyOwner {
        require(claimActive!=true,"Vesting time already started");
        require(presaleActive, "Presale not activeted");
        require(noOfPurchases > 0,  "There are no purchases for claim");  
        presaleActive = false;
        claimActive = true;
        vestingStartdate=block.timestamp;
        vestingEndDate = vestingStartdate + VESTINGDURATION;
    }
   


    function buyTokensUSDC(uint256 amount) public whenPresaleActive {
        require(amount > 0, "Can't buy tokens! Amount should be grater then 0.");
        uint256 phase = activePhase();       

        require(
            purchases[msg.sender][uint256(phase)].usdcAmount + amount <= MAX_PURCHASE_AMOUNT,
            "Purchase exceeds maximum allowed"
        ); 

        PresaleInfo storage presale = presalePhases[uint256(phase)];
        
        uint256 tokensToBuy = usdcToToken(amount, uint256(phase));

               
        require((presale.maxAmount+tokensToBuy) <= presale.totalTokens, "Not enough tokens left for sale");

        PurchaseDetails storage newPurchase = purchases[msg.sender][uint256(phase)];       
        

        bool isNewPurchase = newPurchase.tokenAmount == 0;

        if (isNewPurchase) {
            noOfPurchases++;
            newPurchase.purchaseId = noOfPurchases;
        }
        totalNoOfPurchaseToken+=tokensToBuy;
        newPurchase.tokenAmount += tokensToBuy;
        newPurchase.purchaseTime = block.timestamp;        
        newPurchase.purchaseStage = uint256(phase);

        totalPurchased[msg.sender]+=tokensToBuy;
        

        purchases[msg.sender][uint256(phase)].usdcAmount += amount;
        USDC.transferFrom(msg.sender, owner(), amount);
        presale.maxAmount+= tokensToBuy; 

        emit TokensPurchasedUsdc(msg.sender, tokensToBuy, amount, uint256(phase));
    }

    function claimTokens() whenClaimActive external {
        claimCalculation(msg.sender);
    }

    function onlyOwnerClaimTokens(address[] memory users) public onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            claimCalculation(users[i]);
        }
    }

   function claimCalculation(address wallet) public {
        require(block.timestamp > vestingStartTime, "Vesting has not started yet");

        uint256 totalAmount = totalPurchased[wallet]; // Total amount buyer has purchased
        uint256 claimableAmount = 0;                  // Amount buyer is allowed to claim

        bool[5] memory claimableMonths = this.viewClaimMonth(wallet); // External call
       

        for (uint8 i = 0; i < 5; i++) {
            if (claimableMonths[i]==true) {
                claimableAmount += totalAmount / 5;
                hasClaimed[wallet][i]=true;
            }
        }

        require(claimableAmount > 0, "No claimable tokens available");

        totalClaimed[wallet] += claimableAmount;
        token.transfer(wallet, claimableAmount);
    }

    // View total claimed amount for a buyer
    function viewTotalClaimed(address _buyer) external view returns (uint256) {
        return totalClaimed[_buyer];
    }

    // View claim month for each vesting month (returns an array of booleans)
    function viewClaimMonth(address _buyer) external view returns (bool[5] memory) {
        bool[5] memory availableToClaim;
        
        // Calculate how many months have passed since vesting started
        uint256 monthsPassed = (31*1*(24*60*60));

         console.log("monthsPassed",monthsPassed);
        // Loop through each vesting month and set availability
        for (uint8 i = 0; i < 5; i++) {
            if (block.timestamp >= vestingStartdate+(monthsPassed*i) && !hasClaimed[_buyer][i]) {
                // If the vesting month has passed and the buyer hasn't claimed, mark it as available
                  console.log("vestingStartdate+(monthsPassed*i)",vestingStartdate+(monthsPassed*i));
                availableToClaim[i] = true;
            } else {
                // Otherwise, mark it as not available
                availableToClaim[i] = false;
            }
        }

        return availableToClaim;
    }

    
    function usdcToToken(uint256 _amount, uint256 phase)
        public
        view
        returns (uint256)
    {
        PresaleInfo storage presale = presalePhases[uint256(phase)];
        uint256 numberOfTokens = (_amount * (presale.tokenPrice)) /
            10**(USDC.decimals());
        return numberOfTokens;
    }

   function tokenToUSDC(uint256 _tokenAmount, PresalePhase phase)
    public
    view
    returns (uint256)
    {
        // Get the presale phase info
        PresaleInfo storage presale = presalePhases[uint256(phase)];

        // Calculate the USDC equivalent of the given token amount
        uint256 usdcAmount = (_tokenAmount * 10**(USDC.decimals())) /
            presale.tokenPrice;

        return usdcAmount;
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
        // Calculate the total tokens allocated to all phases
        uint256 totalAllocatedTokens = 0;
        for (uint256 i = 0; i < presalePhases.length; i++) {
            if (i == uint256(phase)) {
                totalAllocatedTokens += _totalTokens;
            } else {
                totalAllocatedTokens += presalePhases[i].totalTokens;
            }
        }

        // Ensure the total allocated tokens do not exceed the total supply of the token
        require(
            totalAllocatedTokens <= token.totalSupply(),
            "Cannot set above the total supply of the token"
        );

        // Set the total tokens for the specified phase
        presalePhases[uint256(phase)].totalTokens = _totalTokens;
        
    }  

    

    // Admin function to withdraw unsold tokens
    function withdrawUnsoldTokens() external onlyOwner {
        require(!presaleActive, "Presale is still active");
        uint256 unsoldTokens = token.balanceOf(address(this))-totalNoOfPurchaseToken;
        token.transfer(owner(), unsoldTokens);
    }
    // Function to update the start and end dates of a presale phase
    function updatePresaleDates(
        uint256 phaseIndex,
        uint256 newStartDate,
        uint256 newEndDate
    ) external whenPresaleActive onlyOwner {
        require(phaseIndex < presalePhases.length, "Invalid phase index");
        require(newEndDate > newStartDate, "End date must be after start date");

        for (uint256 i = 1; i < presalePhases.length; i++) {
            if(phaseIndex !=0)
                require(presalePhases[phaseIndex-1].startDateTime < newStartDate || presalePhases[phaseIndex-1].endDateTime < newEndDate);              
       }

         presalePhases[phaseIndex-1].startDateTime = newStartDate;
         presalePhases[phaseIndex-1].endDateTime = newEndDate;
         updateActivePhases();  // Ensure the active status of the phases is updated based on the new dates
        
    }

   

}
