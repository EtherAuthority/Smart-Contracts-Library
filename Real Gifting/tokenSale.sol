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
    address public tokenEQE = 0x9E345564f52BB7159cf1a1459cC1CFA09fdb22fF;
    address public tokenEQQ = 0x5BA2442f5E1C0322CF05A575AE529aEae324543a;
    address public tokenUSDT = 0xE3F5a90F9cb311505cd691a46596599aA1A0AD7D;


    uint256 public constant multiplier = 10**10;
    uint256 public eqeRateInBrise = 1865;               // 1 BRISE = how many EQE? 1865 = $0.0000001865 with multiplier devision
    uint256 public eqqRateInBrise = 186500;             // 1 BRISE = how many EQQ? 186500 = $0.000018 with multiplier devision
    uint256 public eqqRateInUSDT = 100 * multiplier;    // 1 USDT = 100 EQQ

    
    // Events
    event TokensPurchased(address indexed buyer, address tokenPaid, address tokenReceived, uint256 amountPaid, uint256 amountReceived);
    


    function buyEQEwithUSDT(uint256 amountUSDT) external returns(bool) {
        
        require(amountUSDT > 0, "Token amount should be greater than zero");
        
        //USDT has 6 decimals. so, the amount was devided with 10**12
        IERC20(tokenUSDT).transferFrom(msg.sender, owner(), amountUSDT);
        
        //This contract should have enough EQE tokens
        IERC20(tokenEQE).transfer(msg.sender, amountUSDT * (10**12));

        emit TokensPurchased(msg.sender, tokenUSDT, tokenEQE, amountUSDT, amountUSDT * (10**12));

        return true;
    }

    function buyEQEwithBRISE() external payable returns(bool){

        require(msg.value > 0, "The amount should be greater than zero");

        uint256 amountEQE = msg.value * eqeRateInBrise / multiplier;

        //This contract should have enough EQE tokens
        IERC20(tokenEQE).transfer(msg.sender, amountEQE);

        payable(owner()).transfer(msg.value);

        emit TokensPurchased(msg.sender, address(0), tokenEQE, msg.value, amountEQE);
        
        return true;
    }


    function buyEQQwithUSDT(uint256 amountUSDT) external returns(bool) {
        
        require(amountUSDT > 0, "Token amount should be greater than zero");

        uint256 amountEQQ = eqqRateInUSDT * amountUSDT * (10**12) / multiplier;
        
        //USDT has 6 decimals. so, the amount was devided with 10**12
        IERC20(tokenUSDT).transferFrom(msg.sender, owner(), amountUSDT);
        
        //This contract should have enough EQE tokens
        IERC20(tokenEQQ).transfer(msg.sender, amountEQQ);

        emit TokensPurchased(msg.sender, tokenUSDT, tokenEQQ, amountUSDT, amountEQQ);

        return true;
    }


    function buyEQQwithBRISE() external payable returns(bool){

        require(msg.value > 0, "The amount should be greater than zero");

        uint256 amountEQQ = msg.value * eqqRateInBrise / multiplier;

        //This contract should have enough EQE tokens
        IERC20(tokenEQQ).transfer(msg.sender, amountEQQ);

        payable(owner()).transfer(msg.value);

        emit TokensPurchased(msg.sender, address(0), tokenEQQ, msg.value, amountEQQ);
        
        return true;
    }



    /**
    Owner functions
    */
    function updateTokens(address _tokenEQE, address _tokenEQQ, address _tokenUSDT ) external onlyOwner {
        tokenEQE = _tokenEQE;
        tokenEQQ = _tokenEQQ;
        tokenUSDT = _tokenUSDT;
    }

    function updateExchangeRates(uint256 _eqeRateInBrise, uint256 _eqqRateInBrise, uint256 _eqqRateInUSDT) external onlyOwner {
        eqeRateInBrise = _eqeRateInBrise;               
        eqqRateInBrise = _eqqRateInBrise;                
        eqqRateInUSDT = _eqqRateInUSDT;
    }

    

    function rescueTokens(address tokenAddress) external onlyOwner{
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        IERC20(tokenAddress).transfer(msg.sender, balance);
    }

    function rescueBrise() external onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }
}
