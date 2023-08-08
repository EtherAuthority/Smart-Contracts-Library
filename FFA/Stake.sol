//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.2; 



interface TokenI {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
}

contract Stake { 
    address public owner;  

    //_stakigntime=month; _stakedtime=on which block u staked;
    struct _staking{
        uint _stakingStarttime;
        uint _stakingEndtime;
        uint _amount;
        uint _profit;
    }

    mapping(address=>mapping(uint256=>_staking)) public staking;    
    mapping(uint => uint) public RewardPercentage;
    address public RewardPoolAddress;
    address public tokenAddress=address(0);
    address public contractadd = address(this);
    
    
    
    constructor(address _tokenContract) {

       owner=msg.sender;       
       
       tokenAddress= _tokenContract; 
       //deployTimestamp = block.timestamp ;
        RewardPercentage[30] = 700;
        RewardPercentage[90] = 7500;
        RewardPercentage[180] = 3500;
        RewardPercentage[360] = 160000;

        
    }  

    modifier onlyOwner() {
    // owner is storage variable is set during constructor
    if (msg.sender != owner) {      
       _;
    }
   
  }

   
    event unstake(address _to, uint _amount);

    function changeRewardPoolAddress( address _rewardaddress) public {
        RewardPoolAddress = _rewardaddress;
    }   

    function RewardPercentageChange( uint _stakeDays , uint _percentage) public returns(uint) {
        RewardPercentage[_stakeDays] = _percentage;
        return  RewardPercentage[_stakeDays];
    }

    function viewPercentage(uint _stakeDays) public view returns(uint){
        return RewardPercentage[_stakeDays];
    }

    function setRewardToken(uint _amount) public {
        TokenI(tokenAddress).transferFrom(RewardPoolAddress,contractadd, _amount);
       
    }   

   

    function viewProfit(uint256 _stakeDays ) public view returns(uint){
        require(staking[msg.sender][_stakeDays]._amount > 0,"Wallet Address is not Exist");
        uint profit = staking[msg.sender][_stakeDays]._amount *  RewardPercentage[_stakeDays]/10000;
        return profit;
    }

    function stake(uint _staketime , uint _stakeamount) public returns (bool){
        require(staking[msg.sender][_staketime]._amount == 0,"Wallet Address is already Exist");
        require(TokenI(tokenAddress).balanceOf(msg.sender) > _stakeamount, "Insufficient tokens");
        require(RewardPercentage[_staketime] > 0,"Please enter valid stack days");
        uint profit = _stakeamount * RewardPercentage[_staketime]/10000;
        staking[msg.sender][_staketime] =  _staking(block.timestamp,block.timestamp + (_staketime*(24*60*60)),_stakeamount,profit);

        TokenI(tokenAddress).transfer(address(this), _stakeamount);
        return true;
       
    }


 function unStake(uint256 _stakeDays) public returns (bool){            
            
            require(staking[msg.sender][_stakeDays]._amount > 0,"Wallet Address is not Exist");
            require(RewardPercentage[_stakeDays] > 0,"Please enter valid stack days");
            uint locktime=staking[msg.sender][_stakeDays]._stakingStarttime+600;
            
             
            
            uint totalAmt;
            uint profit;
            uint remainingProfit;

            if(block.timestamp > locktime){
            
                profit= staking[msg.sender][_stakeDays]._profit;
                totalAmt= staking[msg.sender][_stakeDays]._amount+ profit;

            }else{

                profit= staking[msg.sender][_stakeDays]._profit;
                remainingProfit=profit/2; //penalty
                totalAmt= staking[msg.sender][_stakeDays]._amount+ remainingProfit;

            }
            staking[msg.sender][_stakeDays]._amount=0;
            staking[msg.sender][_stakeDays]._stakingStarttime=0;
            staking[msg.sender][_stakeDays]._stakingEndtime=0;
            staking[msg.sender][_stakeDays]._profit=0;
                 

            TokenI(tokenAddress).transfer(msg.sender, totalAmt);

            
             emit unstake(msg.sender,totalAmt);
            return true;

             
           
    }
   

    //function rescueTokens(){}
}

