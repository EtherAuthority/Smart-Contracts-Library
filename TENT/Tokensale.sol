// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;


// IERC20 standard interface
interface IERC20
{
    function balanceOf(address user) external view returns(uint256);
    function decimals() external view returns(uint8);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
} 

//USDT contract in Ethereum does not follow ERC20 standard so it needs different interface
interface IERC20_USDT
{
    function transfer(address _to, uint256 _amount) external;
    function transferFrom(address _from, address _to, uint _value) external;
    function balanceOf(address who) external returns (uint);
}



// Ownership smart contract
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// Main Token sale smart contract 
contract TokenSale is Ownable{

    //public variables
    IERC20 public token;
    address public usdtToken;

    uint256 public exchangeRateInEth; // exchange rate => 1 ETH = how many tokens
    uint256 public maxAmountinEth;    // Max amount limit in ETH in one transacation

    uint256 public exchangeRateInUSDT=1; // exchange rate => 1 USDT = how many tokens
    uint256 public maxAmountinUSDT;    // Max amount limit in USDT in one transacation

    
    // Events
    event TokensPurchasedWithETH(address indexed buyer, uint256 amount, uint256 tokenPaid);
    event TokensPurchasedWithUSDT(address indexed buyer, address tokenAddress, uint256 amount);
    

    constructor(
        IERC20 _token,
        uint256 _exchangeRateInEth,
        uint256 _maxAmountinEth
    ) {
        token = _token;
        exchangeRateInEth = _exchangeRateInEth;
        maxAmountinEth = _maxAmountinEth;
    }

    function updateExchangeRateInEth(uint256 _exchangeRate) external onlyOwner {
        exchangeRateInEth = _exchangeRate;
    }

    function updateMaxAmountinEth(uint256 _maxAmount) external onlyOwner {
        maxAmountinEth = _maxAmount;
    }

    function updateExchangeRateInUSDT(uint256 _exchangeRate) external onlyOwner {
        exchangeRateInUSDT = _exchangeRate;
    }

    function updateMaxAmountinUSDT(uint256 _maxAmount) external onlyOwner {
        maxAmountinUSDT = _maxAmount;
    }

    function setUsdtToken(address _usdtToken) external onlyOwner {
        usdtToken = _usdtToken;
    }


    /**
    * Token Buy
    */
    function buyTokensWithEth() external payable {
        require (msg.value > 0, "You need to send some Ether");
        require (msg.value <= maxAmountinEth, "Cannot buy more than max limit");

        uint256 amount = msg.value * exchangeRateInEth;

        require(token.balanceOf(address(this)) >= amount, "Not enough tokens left for sale");

        token.transfer(msg.sender, amount);
        payable(owner()).transfer(msg.value);

        emit TokensPurchasedWithETH(msg.sender, msg.value, amount);
    }


    function buyTokensWithUSDT(uint256 usdtAmount) external {
        
        require(IERC20_USDT(usdtToken).balanceOf(msg.sender) >= usdtAmount, "Not suffiecient balance");
        require(usdtAmount > 0, "Token amount should be greater than zero");
        require(usdtAmount <= maxAmountinUSDT, "Cannot buy more than max limit");

        uint256 amount = usdtAmount * exchangeRateInUSDT * 10**6;
        uint256 totalusdtAmount = usdtAmount * 10**6;

        require(token.balanceOf(address(this)) >= amount, "Not enough tokens left for sale");
           
        IERC20_USDT(usdtToken).transferFrom(msg.sender, owner(), totalusdtAmount);
            
        token.transfer(msg.sender, amount);

        emit TokensPurchasedWithUSDT(msg.sender, usdtToken, amount);
        
    }

    /**
    * This lets owner to withdraw any leftover tokens.
    */
    function withdrawLeftoverTokens(address tokenAddress) external onlyOwner{
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        IERC20(tokenAddress).transfer(msg.sender, balance);
    }
}
