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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
/**
 *
 * @dev main contract start
 *
 **/
contract Locker is Ownable{

    // This is a type for a single proposal.
    struct Proposal {
        uint256 proposalid;
        address wallet;
        uint256 amount;              
        uint256 voteCount; // number of accumulated votes
        string status;
    }
      // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;
    mapping(address => bool) public signer;
    uint256 proposalid = 1;

    
    
    function addSigner(address _signerWallet)public onlyOwner returns(bool){
         signer[_signerWallet]=true;        
         return true;
    }

    function removeSigner(address _signerWallet)public onlyOwner returns(bool){
         signer[_signerWallet]=false;        
         return true;
    }
    
    function addProposal(address _wallet, uint256 _amount)public onlyOwner returns(bool){
       
         proposals.push(Proposal({
                proposalid:proposalid++,
                wallet:_wallet,
                amount: _amount,
                voteCount: 0,
                status:"pending"
            }));
        return true;
    }

  

    function vote(uint proposal) public{
        require(signer[msg.sender]==true,"Only signers have right to vote");
        require(proposals[proposal].voteCount < 2, "Has no right to vote");
        
        

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount=proposals[proposal].voteCount+1;

        if(proposals[proposal].voteCount==2){
            proposals[proposal].status="completed"; 
            require(proposals[proposal].amount <= address(this).balance, "Insufficient balance");        
            address payable recipient=payable(proposals[proposal].wallet);
            recipient.transfer(proposals[proposal].amount);                      
        }
    }

    receive() external payable{
        
    }

}
