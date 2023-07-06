// SPDX-License-Identifier: MIT
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.19;


// IERC20 standard interface
interface IERC20
{
    function balanceOf(address user) external view returns(uint256);
    function decimals() external view returns(uint8);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
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
    uint256 public tokensSold;
    IERC20 public token;
    address public usdtToken;

    uint256 public exchangeRateInEth = 2000;    // 1 ETH = how many tokens?
    uint256 public exchangeRateInUSDT = 1;      // 1 USDT = how many tokens?
    uint256 public maxAmountinEth = 13.45 ether;
    uint256 public maxAmountinUSDT = 25000;

    
    // Events
    event TokensPurchased(address indexed buyer, address tokenAddress, uint256 amount);
    

    constructor(
        IERC20 _token,
        address _usdtToken
    ) {
        token = _token;
        usdtToken = _usdtToken;
    }



    /**
    * Token Buy
    */
    function buyTokens(uint256 tokenAmountinUSDT) external payable {
        uint256 amount;
        if(msg.value > 0){
            require (msg.value <= maxAmountinEth, "Cannot buy more than max limit");
            /* spend token is ETHER*/

            amount = msg.value * exchangeRateInEth;
            token.transfer(msg.sender, amount);
            payable(owner()).transfer(msg.value);
        }
        else{
            require(IERC20(usdtToken).balanceOf(msg.sender) >= tokenAmountinUSDT, "Not sufficient balance");
            require(tokenAmountinUSDT > 0, "Token amount should be greater than zero");
            require(tokenAmountinUSDT <= maxAmountinUSDT, "Cannot buy more than max limit");

            amount = tokenAmountinUSDT * exchangeRateInUSDT;
           
            IERC20(usdtToken).transferFrom(msg.sender, owner(), tokenAmountinUSDT);
            
            token.transfer(msg.sender, amount);

        }

        tokensSold += amount;

        emit TokensPurchased(msg.sender, usdtToken, amount);
        
    }


    /**
    Owner functions
    */
    function updateExchangeRateInEth(uint256 _exchangeRate) external onlyOwner {
        exchangeRateInEth = _exchangeRate;
    }

    function updateExchangeRateInUSDT(uint256 _exchangeRate) external onlyOwner {
        exchangeRateInUSDT = _exchangeRate;
    }

    function updateMaxAmountinEth(uint256 _maxAmount) external onlyOwner {
        maxAmountinEth = _maxAmount;
    }

    function updateMaxAmountinUSDT(uint256 _maxAmount) external onlyOwner {
        maxAmountinUSDT = _maxAmount;
    }

    function withdrawLeftoverTokens() external onlyOwner{
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        token.transfer(msg.sender, balance);
    }
}
