// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
* @dev  ERC20 Token contract interface
*/
interface Token {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
    function decimals() external view returns (uint8);

}

contract Tresuryreserve { 
    struct _withdrawdetails{
        uint time;
        uint amount;
    }
    address public owner; 
    mapping(address => uint) public lockingWallet;
    mapping(address => uint) public VestingTime;
    mapping(address => uint) public unlockDate;
    mapping(address => uint) public RemainingAmt;
    mapping(address=>mapping(uint=>_withdrawdetails)) public withdrawdetails;
    uint public deployTimestamp;
    address public tokenContract=address(0);
   // uint public quarter = (31*3*(24*60*60));
    uint public quarter = 60;
    uint256 public decimals; 
    
    
    constructor( address _tokenContract) {
        owner=msg.sender;
        tokenContract= _tokenContract; 
        //deployTimestamp = timestampFromDateTime(block.timestamp);
        deployTimestamp = block.timestamp;          
        decimals=Token(tokenContract).decimals();

      
        lockingWallet[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=170000000000* (10**decimals);// Team Allocation Assigned Tokens 
        VestingTime[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=6; //lock months
        // unlockDate[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] =  deployTimestamp + (31*VestingTime[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]*(24*60*60));// unlock start
        unlockDate[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] =  deployTimestamp + (120);// unlock start

    } 

    /**
    * @dev To show contract event  .
    */
    event withdraw(address _to, uint _amount);

    /**
    * @dev ViewVestingAmount shows available Team Allocation amount of particular wallet
    * parameters : user (wallet Address)
    *              
    */   
     function ViewVestingAmount( address user )public view returns (uint){ 
        uint VestingAmount = 0; 
        for(uint i=0;i<17;i++) 
        { 
            if(unlockDate[user]<=block.timestamp){
                 if(block.timestamp>=unlockDate[user]+(quarter*i)) { 
                     if(withdrawdetails[user][i+1].time==0) 
                     { 
                        VestingAmount+=10000000000 * (10**decimals);                        
                     } 
                 } else { 
                     break; 
                 } 
             }
        }  
             return VestingAmount; 
    } 
    /**
     * @dev returns completed vesting month.
     *
     */
    function completedMonth( address user) public view returns (uint){
            uint compmonth=0;
             for(uint i=0;i<17;i++) 
             { 
                if(block.timestamp>=unlockDate[user]+(quarter*i)){                 
                     compmonth=(i+3+6); 
                }  
             } 
            return compmonth;
    } 
    
    /**
     * @dev Team Allocation amount release in particular category wallet.
     *
     */
    function withdrawTokens()public returns (bool){ 
        uint VestingAmount = 0; 
             for(uint i=0;i<17;i++) 
             { 
                 require(unlockDate[msg.sender]<=block.timestamp,"Unable to Withdraw"); 
                 if(block.timestamp>=unlockDate[msg.sender]+(quarter*i)){ 
                     if(withdrawdetails[msg.sender][i+1].time==0) 
                     { 
                        VestingAmount=10000000000 * (10**decimals); 
                        withdrawdetails[msg.sender][i+1]=_withdrawdetails(block.timestamp,VestingAmount);                       
                       
                     } 
                 } else { 
                     break; 
                 } 
             } 
             Token(tokenContract).transfer(msg.sender, VestingAmount);            
             emit withdraw(msg.sender,VestingAmount);
             return true;
    }
}
