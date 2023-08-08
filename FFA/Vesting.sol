//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.2; 
import "./DateTime.sol";

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}

// ERC20 Token contract interface

interface Token {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);

}

contract Vesting { 

    address public owner;  
    using SafeMath for uint256;

    struct _withdrawdetails{
        uint time;
        uint amount;
    }
    mapping(address => uint) public lockingWallet;
    mapping(address => uint) public VestingTime;
    mapping(address => uint) public unlockDate;
    mapping(address=>mapping(uint=>_withdrawdetails)) public withdrawdetails;
    uint public deployTimestamp;
    address public tokenContract=address(0);
    uint public oneyear = (31*12*(24*60*60));
    //uint public oneyear = 60;
   
     function getYear(uint _timeStemp) internal  pure returns (uint256 year) {
        year = DateTime.getYear(_timeStemp);
    }

    // Years Ends with fab and 1st march we can withdraw maturity amount  
    function timestampFromDateTime(uint _timeStemp)
        internal
        pure
        returns (uint256 timestamp)
    {
        uint year=getYear(_timeStemp);
        return DateTime.timestampFromDateTime(year, 3 , 1, 0, 0, 0);
    }
    
    constructor(address[] memory _wallet,uint[] memory  _tokenamount, uint[] memory  _vestingTime, address _tokenContract) {

       owner=msg.sender;       
       
       tokenContract= _tokenContract; 
       deployTimestamp = timestampFromDateTime(block.timestamp);
       //deployTimestamp = block.timestamp;
       require(_wallet.length == _tokenamount.length && _wallet.length == _vestingTime.length,"Please check parameter values");

       for(uint i=0; i < _wallet.length; i++){      
       
         lockingWallet[_wallet[i]]=_tokenamount[i]; 
         VestingTime[_wallet[i]]=_vestingTime[i];
         unlockDate[_wallet[i]] =  timestampFromDateTime(deployTimestamp + (_vestingTime[i] * (31*12*(24*60*60))));
        

        }

        
    } 
 

    event withdraw(address _to, uint _amount);

    function CompletedVestingYear() public view  returns(uint){
             require(block.timestamp < unlockDate[msg.sender],"Vesting time completed");
            return (VestingTime[msg.sender].sub(getYear(unlockDate[msg.sender]).sub(getYear(block.timestamp))));
        
      }

   
     function ViewVestingAmount( address user )public view returns (uint){ 
        uint tempVer = 0; 
             for(uint i=1;i<=VestingTime[user];i++) 
             { 
                 require(deployTimestamp+oneyear<=block.timestamp,"Unable to Withdraw"); 
                 if(block.timestamp>=deployTimestamp+(oneyear*i)) 
                 { 
                     if(withdrawdetails[user][i].time==0) 
                     { 
                        tempVer+=lockingWallet[user]/VestingTime[user];                        
                     } 
                 } 
                 else 
                 { 
                     break; 
                 } 
             } 
             return tempVer; 
    }
    
    // Years Ends with fab and 1st march we can withdraw maturity amount  
    function withdrawTokens() public returns (bool){
             require(lockingWallet[msg.sender] > 0,"Wallet Address is not Exist"); 
             
             uint tempVer = 0;
             for(uint i=1;i<=VestingTime[msg.sender];i++)
             {
                 require(deployTimestamp+oneyear<=block.timestamp,"Unable to Withdraw");
                 if(block.timestamp>=deployTimestamp+(oneyear*i))
                 {
                     if(withdrawdetails[msg.sender][i].time==0)
                     {
                        tempVer+=lockingWallet[msg.sender]/VestingTime[msg.sender];
                        withdrawdetails[msg.sender][i]=_withdrawdetails(block.timestamp,lockingWallet[msg.sender]/VestingTime[msg.sender]);
                     }
                 }
                 else
                 {
                     break;
                 }
             }

             
            
                   
             Token(tokenContract).transfer(msg.sender, tempVer);
            
             emit withdraw(msg.sender,tempVer);
             return true;

             
           
    }

   

    
}
