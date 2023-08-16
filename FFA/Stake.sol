// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface TokenI {
    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
}

contract Stake { 

    struct _staking{         
        uint _days;
        uint _stakingStarttime;
        uint _stakingEndtime;
        uint _amount;
        uint _profit;
    }
    address public owner;    
    address public RewardPoolAddress;
    address public tokenAddress=address(0);
    address public contractadd = address(this);
    mapping(address=>mapping(uint256=>_staking)) public staking; 
    mapping(address=>uint256) public activeStake;
    mapping(address=>uint256) public TotalProfit;   
    mapping(uint256 => uint256) public RewardPercentage;        
    
    constructor(address _tokenContract) {
        owner=msg.sender;
        tokenAddress= _tokenContract; 

        //Days wise Percentage
        RewardPercentage[30] = 700;
        RewardPercentage[90] = 7500;
        RewardPercentage[180] = 3500;
        RewardPercentage[360] = 160000;
    }  

    modifier onlyOwner() {    
        if (msg.sender == owner) {      
             _;
        }   
    }    
    /**
     * @dev To show contract event  .
     */
    event unstake(address _to, uint _amount);

    /**
     * @dev returns number of stake, done by particular wallet .
     */
    function ActiveStake()public view returns(uint){
        return activeStake[msg.sender]; 
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
    function StakeWiseProfit(uint256 _stakeid, uint256 _stakeDays) public view returns(uint){
        require(staking[msg.sender][_stakeid]._amount > 0,"Wallet Address is not Exist");
        uint profit = staking[msg.sender][_stakeid]._amount *  RewardPercentage[_stakeDays]/10000;
        return profit;
    }

     /**
     * @dev returns total staking wallet profited amount
     *
     */
    function TotalProfitedAmt() public view returns(uint){
        require(TotalProfit[msg.sender] > 0,"Wallet Address is not Exist");
        uint profit = TotalProfit[msg.sender];
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
        
        TotalProfit[msg.sender]=TotalProfit[msg.sender]+profit;

        staking[msg.sender][activeStake[msg.sender]] =  _staking(_staketime,block.timestamp,block.timestamp + (_staketime*(24*60*60)),_stakeamount,profit);       

        TokenI(tokenAddress).approve(address(this), _stakeamount);
        
        TokenI(tokenAddress).transferFrom(msg.sender,address(this), _stakeamount);
        
        activeStake[msg.sender]=activeStake[msg.sender]+1;
        
        return true;       
    }

     /**
     * @dev stake amount release.
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

        staking[msg.sender][_stakeid]._days = staking[msg.sender][activeStake[msg.sender]]._days;
        staking[msg.sender][_stakeid]._amount = staking[msg.sender][activeStake[msg.sender]]._amount;
        staking[msg.sender][_stakeid]._stakingStarttime = staking[msg.sender][activeStake[msg.sender]]._stakingStarttime;
        staking[msg.sender][_stakeid]._stakingEndtime = staking[msg.sender][activeStake[msg.sender]]._stakingEndtime;
        staking[msg.sender][_stakeid]._profit = staking[msg.sender][activeStake[msg.sender]]._profit;               

        TokenI(tokenAddress).transfer(msg.sender, totalAmt);
            
        activeStake[msg.sender]=activeStake[msg.sender]-1;
            
        emit unstake(msg.sender,totalAmt);
            
        return true; 
    }
 
}
