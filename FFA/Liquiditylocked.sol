// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface TokenI {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
}

//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Liquiditylocked is Ownable {

    address public immutable LPAddress;
    uint256 public immutable unlockDate;
    uint256 public immutable lockedamount;
    uint256 public immutable deployTimestamp;
   
   /**
    * @dev To show contract event  .
    */
    event claim(address _to, uint _amount);

    constructor(address _LPContract, uint256 _amount) {  
        deployTimestamp=block.timestamp;
        LPAddress= _LPContract;   

        require(TokenI(LPAddress).balanceOf(msg.sender) > _amount, "Insufficient tokens");         
        unlockDate =  deployTimestamp + (31*12*15*(24*60*60));// unlock start        
        lockedamount = _amount;
    }

    function Claim() public onlyOwner returns(bool){        
        require(unlockDate<=block.timestamp,"Liquidity locked!"); 
        TokenI(LPAddress).transfer(msg.sender, lockedamount);
        emit claim(msg.sender,lockedamount);
        return true;
    }

 }
