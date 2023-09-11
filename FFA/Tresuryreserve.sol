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
    address public immutable owner; 
    address public immutable lockingWallet;
    uint256 public immutable lockingWalletAmt;
    uint256 public immutable unlockDate;
    mapping(address=>mapping(uint=>_withdrawdetails)) public withdrawdetails;
    uint public immutable deployTimestamp;
    address public tokenContract=address(0);
    uint public constant quarter = (31*3*(24*60*60));   
    uint256 public immutable decimals;     
    
    constructor( address _tokenContract) {
        owner=msg.sender;
        tokenContract= _tokenContract; 
        //deployTimestamp = timestampFromDateTime(block.timestamp);
        deployTimestamp = block.timestamp;          
        decimals=Token(tokenContract).decimals();
      
        lockingWallet=0xF7d9Be10cD3BA123c085e03873688ec475d439CA;
        lockingWalletAmt=170000000000* (10**decimals);// Team Allocation Assigned Tokens 
        unlockDate =  deployTimestamp + (31*6*(24*60*60));// unlock start        
    } 

    /**
    * @dev To show contract event  .
    */
    event withdraw(address _to, uint _amount);

    /**
    * @dev The onlydefinedWallet modifier has one parameter, user, which is of type address. 
    * The modifier includes a require statement that checks the value of the user parameter and only allows the function to execute if the defined wallet is equal to user.
    **/
    modifier onlydefinedWallet(address user) {
        require(lockingWallet == user);
        _;
    }
    /**
    * @dev ViewUnlockAmount  shows available Team Allocation amount of particular wallet
    * parameters : user (wallet Address)
    *              
    */   
     function ViewUnlockAmount( address user )public view onlydefinedWallet(user) returns (uint){ 
        uint VestingAmount = 0; 
        for(uint i=0;i<17;i++) 
        { 
            if(unlockDate<=block.timestamp){
                 if(block.timestamp>=unlockDate+(quarter*i)) { 
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
    function completedMonth( address user) public view onlydefinedWallet(user) returns (uint){
            uint compmonth=0;
             for(uint i=0;i<17;i++) 
             { 
                if(block.timestamp>=unlockDate+(quarter*i)){                 
                     compmonth=(i+3+6); 
                }  
             } 
            return compmonth;
    } 
    
    /**
     * @dev Team Allocation amount release in particular category wallet.
     *
     */
    function withdrawTokens() public onlydefinedWallet(msg.sender) returns (bool){ 
            uint TresuryAmount = 0; 
             for(uint i=0;i<17;i++) 
             { 
                 require(unlockDate<=block.timestamp,"Unable to Withdraw"); 
                 if(block.timestamp>=unlockDate+(quarter*i)){ 
                     if(withdrawdetails[msg.sender][i+1].time==0) 
                     { 
                        TresuryAmount=10000000000 * (10**decimals); 
                        withdrawdetails[msg.sender][i+1]=_withdrawdetails(block.timestamp,TresuryAmount);                       
                       
                     } 
                 } else { 
                     break; 
                 } 
             } 
             require(TresuryAmount > 0,"Withdraw amount should be greater then 0");
             Token(tokenContract).transfer(msg.sender, TresuryAmount);            
             emit withdraw(msg.sender,TresuryAmount);
             return true;
    }
}
