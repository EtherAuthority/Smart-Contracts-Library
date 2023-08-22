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

contract Vesting { 
    struct _withdrawdetails{
        uint time;
        uint amount;
    }
    address public owner; 
    mapping(address => uint) public lockingWallet;
    mapping(address => uint) public VestingTime;
    mapping(address => uint) public unlockDate;
    mapping(address=>mapping(uint=>_withdrawdetails)) public withdrawdetails;
    uint public deployTimestamp;
    address public tokenContract=address(0);
   // uint public onemonth = (31*1*(24*60*60));
    uint public onemonth = 60;
    uint256 public decimals; 
    mapping(address => uint) public completedMoth;  
    
    constructor( address _tokenContract) {
        owner=msg.sender;
        tokenContract= _tokenContract; 
        //deployTimestamp = timestampFromDateTime(block.timestamp);
        deployTimestamp = block.timestamp;          
        decimals=Token(tokenContract).decimals();

         // Category A
         lockingWallet[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=37500000000* (10**decimals);// Team Allocation Assigned Tokens 
         VestingTime[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=24; //lock months
        // unlockDate[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] =  deployTimestamp + (31*VestingTime[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]*(24*60*60));// unlock start
          unlockDate[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] =  deployTimestamp + (180);// unlock start
         
            /*
         // Category B
         lockingWallet[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=37500000000* (10**decimals);// Team Allocation Assigned Tokens 
         VestingTime[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=24; //lock months
         //unlockDate["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"] =  deployTimestamp + (31*_vestingTime[i]*(24*60*60));// unlock start
         unlockDate[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] =  deployTimestamp + (120);

         // Category c
         lockingWallet[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=37500000000* (10**decimals);// Team Allocation Assigned Tokens 
         VestingTime[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=24; //lock months
         //unlockDate["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"] =  deployTimestamp + (31*_vestingTime[i]*(24*60*60));// unlock start
         unlockDate[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] =  deployTimestamp + (120);

         // Category D
         lockingWallet[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=37500000000* (10**decimals);// Team Allocation Assigned Tokens 
         VestingTime[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2]=24; //lock months
         //unlockDate["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"] =  deployTimestamp + (31*_vestingTime[i]*(24*60*60));// unlock start
         unlockDate[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] =  deployTimestamp + (120);

            */
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
        for(uint i=0;i<12;i++) 
        { 
            if(unlockDate[user]<=block.timestamp){
                 if(block.timestamp>=unlockDate[user]+(onemonth*i)) { 
                     if(withdrawdetails[user][i+1].time==0) 
                     { 
                        VestingAmount+=lockingWallet[user]/12;                        
                     } 
                 } else { 
                     break; 
                 } 
             }
        }  
             return VestingAmount; 
    }

     /**
     * @dev returns left vesting amount.
     *
     */
    function viewLeftAmount( address user) public view returns (uint){
            uint LeftAmount =viewLeftMonth(user);       
            return (lockingWallet[user]/12)*LeftAmount;
    } 
    /**
     * @dev returns left vesting month.
     *
     */
    function viewLeftMonth( address user) public view returns (uint){
            uint compmonth=0;
             for(uint i=0;i<12;i++) 
             { 
                 if(unlockDate[user]<=block.timestamp){
                 if(block.timestamp>=unlockDate[user]+(onemonth*i)){ 
                     compmonth+=1;  
                 } else { 
                     break; 
                 }

             }  
             } 

            return 12-compmonth;
    } 
    
    /**
     * @dev Team Allocation amount release in particular category wallet.
     *
     */
    function withdrawTokens()public returns (bool){ 
        uint VestingAmount = 0; 
             for(uint i=0;i<12;i++) 
             { 
                 require(unlockDate[msg.sender]<=block.timestamp,"Unable to Withdraw"); 
                 if(block.timestamp>=unlockDate[msg.sender]+(onemonth*i)){ 
                     if(withdrawdetails[msg.sender][i+1].time==0) 
                     { 
                        VestingAmount+=lockingWallet[msg.sender]/12; 
                        withdrawdetails[msg.sender][i+1]=_withdrawdetails(block.timestamp,lockingWallet[msg.sender]/12);                       
                       
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
