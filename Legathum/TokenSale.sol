// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;



// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface ITRC20 {
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
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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



//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//

contract TokenSale is Ownable {

    // public variables
    bool public safeguard;  //putting safeguard on will halt all non-owner functions
    uint256 public totalsale;
    uint256 public exchangeRate =  1000000;   // 1 Token = how many USDT?  It is in 6 decimals. so, 1000000 = 1

    address public tokenContract;
    address public usdtContract;
    
    event Buytoken(address buyer, uint256 tokenAmount);

    constructor(address _tokenContract, address _usdtContract)  {
        require(_tokenContract!=address(0),"Invalid Address"); 
        require(_usdtContract!=address(0),"Invalid Address");        
        tokenContract=_tokenContract;
        usdtContract = _usdtContract;
    }

    //fallback function just accepts incoming TRX
    receive() external payable{}



     /**
     * Buy Tokens.
     */
    function buyTokens(uint256 _token) external returns(string memory){
        //checking for safeguard
        require(!safeguard, 'safeguard failed');
        
        
        uint256 usdtAmount = (_token * exchangeRate) / 1e6;       
        
        ITRC20(usdtContract).transferFrom(msg.sender, owner(), usdtAmount);

        ITRC20(tokenContract).transfer(msg.sender,_token);
       
        //logging event and return_
        totalsale += _token;
       
    	emit Buytoken(msg.sender,usdtAmount);	
        return ("tokens are bought successfully");

    }

    /* Set usdt address */
    function changeusdtContract(address _usdtContractAddress) external onlyOwner returns(string memory){
        usdtContract=_usdtContractAddress;
        return "Contract address updated";
    }

     /**
        * Change safeguard status on or off
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    function changeSafeguardStatus() external onlyOwner returns(string memory) {
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;
        }
        return "Safeguard status updated";
    }
  
    /**
     * Change exchange rate. 
     */
     function changeExchangeRate(uint256 _exchangeRate) external onlyOwner returns(string memory){
         exchangeRate = _exchangeRate;
         return "Token price updated successfully";
     }
    
     /**
     * Change token contract. 
     */
     function changeTokenContract(address _tokenContract) external onlyOwner returns(string memory){
         tokenContract = _tokenContract;
         return "Token contract updated successfully";
     }
    
    /* Owner can withdraw Tokens from contract to specify address */ 
     function withdrawTRC20Token(address _tokenaddress,uint256 _amount) external onlyOwner returns(string memory){
         require(_tokenaddress!=address(0),"Invalid Address");
         require(_amount>0,"Invalid Amount"); 
         ITRC20(_tokenaddress).transfer(msg.sender,_amount);
         return "Tokens withdrawn successfully";
     }

    /* Owner can withdraw TRX from contract to specify address */ 
     function withdrawTRX() external onlyOwner returns(string memory){
         payable(msg.sender).transfer(address(this).balance);
         return "TRX withdrawn successfully";
     }
    

    /* display current trx amount in smart contract */
    function viewTRXinContract() external view returns(uint256){
        return address(this).balance;
    }

     

}
