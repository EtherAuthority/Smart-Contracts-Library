// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;



interface TokenI {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
}

contract Stake { 
    address public owner;  

    
    struct _staking{         
        uint _days;
        uint _stakingStarttime;
        uint _stakingEndtime;
        uint _amount;
        uint _profit;
    }

    mapping(address=>mapping(uint256=>_staking)) public staking; 
    mapping(address=>uint256) public activeStake;
   
    mapping(uint256 => uint256) public RewardPercentage;
    address public RewardPoolAddress;
    address public tokenAddress=address(0);
    address public contractadd = address(this);
    
    
    
    constructor(address _tokenContract) {

       owner=msg.sender;       
       
       tokenAddress= _tokenContract; 
       
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


    /**
     * @dev returns number of stake, done by particular wallet .
     */

    function viewTotalStake()public view returns(uint){
        return activeStake[msg.sender]; //stake[msg.sender][1]= _staking(30,block.timestamp,block.timestamp,122,22);

    } 

    /**
     * @dev This wallet is useful for maintain contract token balance.
     * owner can manage profit distribution using rewardPool address.
     */
    function changeRewardPoolAddress( address _rewardaddress) public onlyOwner {
        RewardPoolAddress = _rewardaddress;
    }   

    /**
     * @dev return new days wise staking percentage.
     * owner can change staking _percentage .
     */
    function RewardPercentageChange( uint256 _stakeDays , uint256 _percentage) public onlyOwner returns(uint256) {
        RewardPercentage[_stakeDays] = _percentage;
        return  RewardPercentage[_stakeDays];
    }

    /**
     * @dev return days wise staking percentage.
     * 
     */
    function viewPercentage(uint _stakeDays) public view returns(uint){
        return RewardPercentage[_stakeDays];
    }

    /**
     * @dev set number of token from the RewardPoolAddress
     *
     */
    function setRewardToken(uint _amount) public onlyOwner{
        TokenI(tokenAddress).approve(RewardPoolAddress, _amount);
        TokenI(tokenAddress).transferFrom(RewardPoolAddress,contractadd, _amount);
       
    }   

   
     /**
     * @dev returns staking wallet profited amount
     *
     */
    function viewProfit(uint256 _stakeDays ) public view returns(uint){
        require(staking[msg.sender][_stakeDays]._amount > 0,"Wallet Address is not Exist");
        uint profit = staking[msg.sender][_stakeDays]._amount *  RewardPercentage[_stakeDays]/10000;
        return profit;
    }

    /**
     * @dev stake amount for particular duration.
     * parameters : _staketime in days (exp: 30, 90, 180 ,360 )
     *              _stakeamount ( need to set token amount for stake)
     * it will increase activeStake result of particular wallet.
     */
    function stake(uint _staketime , uint _stakeamount) public returns (bool){

        require(msg.sender != address(0),"Wallet Address can not be address 0");  
        require(TokenI(tokenAddress).balanceOf(msg.sender) > _stakeamount, "Insufficient tokens");
        require(RewardPercentage[_staketime] > 0,"Please enter valid stack days");
        
        uint profit = _stakeamount * RewardPercentage[_staketime]/10000;

        staking[msg.sender][activeStake[msg.sender]] =  _staking(_staketime,block.timestamp,block.timestamp + (_staketime*(24*60*60)),_stakeamount,profit);       

        TokenI(tokenAddress).transfer(address(this), _stakeamount);

        activeStake[msg.sender]=activeStake[msg.sender]+1;

        return true;
       
    }

     /**
     * @dev stake amount for particular duration.
     * parameters : _stakeid is active stake ids which is getting from activeStake-1
     *              
     * it will decrease activeStake result of particular wallet.
     * result : If unstake happen before time duration it will set 50% penalty on profited amount else it will sent you all stake amount,
     *          to the staking wallet.
     */
 function unStake(uint256 _stakeid) public returns (bool){            
            
            require(staking[msg.sender][_stakeid]._amount > 0,"Wallet Address is not Exist");            
            uint locktime=staking[msg.sender][_stakeid]._stakingStarttime+600;
            
             
            
            uint totalAmt;
            uint profit;
            uint remainingProfit;

            if(block.timestamp > locktime){
            
                profit= staking[msg.sender][_stakeid]._profit;
                totalAmt= staking[msg.sender][_stakeid]._amount+ profit;

            }else{

                profit= staking[msg.sender][_stakeid]._profit;
                remainingProfit=profit/2; //penalty
                totalAmt= staking[msg.sender][_stakeid]._amount+ remainingProfit;

            }
            staking[msg.sender][_stakeid]._days=0;
            staking[msg.sender][_stakeid]._amount=0;
            staking[msg.sender][_stakeid]._stakingStarttime=0;
            staking[msg.sender][_stakeid]._stakingEndtime=0;
            staking[msg.sender][_stakeid]._profit=0;
                 

            TokenI(tokenAddress).transfer(msg.sender, totalAmt);

            activeStake[msg.sender]=activeStake[msg.sender]-1;
             emit unstake(msg.sender,totalAmt);
            return true;

             
           
    }
   

    //function rescueTokens(){}
}

