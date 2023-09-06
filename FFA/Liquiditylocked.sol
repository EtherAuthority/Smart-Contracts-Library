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
    
contract owned {
    address public owner;
    address private newOwner;

    /**
    * @dev To show contract event  .
    */
    event OwnershipTransferred(uint256 curTime, address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner, 'Only owner can call this function');
        _;
    }
    function onlyOwnerTransferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    /**
    *
    * @dev This flow is to prevent transferring ownership to wrong wallet by mistake
    *
    */    
    function acceptOwnership() public {
        require(msg.sender == newOwner, 'Only new owner can call this function');
        emit OwnershipTransferred(block.timestamp, owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
contract Liqiditylocked is owned {
    address public immutable LPAddress;
    uint256 public immutable unlockDate;
    uint256 public immutable lockedamount;
    uint256 public immutable deployTimestamp;   
   /**
    *
    * @dev To show contract event  .
    *
    */
    event claim(address _to, uint _amount);

    constructor(address _LPContract, uint256 _amount) {   
        require(owner != address(0),"Wallet Address can not be address 0");  
        //require(TokenI(LPAddress).balanceOf(owner) > _amount, "Insufficient tokens");  
        deployTimestamp=block.timestamp;
        LPAddress= _LPContract; 
       // unlockDate[owner] =  deployTimestamp + (31*12*15*(24*60*60));// unlock start
        unlockDate =  deployTimestamp + (120);// unlock start (for testing)
        lockedamount = _amount; 
    }
     /**
     *
     * @dev Liquidity amount release in particular category wallet.
     *
     */
    function Claim() public onlyOwner returns(bool){        
        require(unlockDate<=block.timestamp,"Liquidity locked!"); 
        TokenI(LPAddress).transfer(owner, lockedamount);
        emit claim(msg.sender,lockedamount);
        return true;
    }

 }
