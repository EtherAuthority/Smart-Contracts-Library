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

/**
* @dev To Main Stake contract  .
*/
contract Stake is Ownable { 

    struct _staking{         
        uint _Month;
        uint _stakingStarttime;
        uint _stakingEndtime;
        uint _amount;
        uint _profit;
    }  
    address public RewardPoolAddress;
    address public tokenAddress=address(0);
    mapping(address=>mapping(uint256=>_staking)) public staking; 
    mapping(address=>uint256) private activeStake;
    mapping(address=>uint256) private TotalProfit;   
    mapping(uint256 => uint256) private RewardPercentage; 
    uint256 private lastStake;
    //uint public onemonth = (31*1*(24*60*60));   
    uint public onemonth = 60;        
    
    constructor(address _tokenContract) {
        tokenAddress= _tokenContract;
        //Days wise Percentage        
        RewardPercentage[6] = 70000;
        RewardPercentage[12] = 160000;
    }
    /**
     * @dev To show contract event  .
     */
    event StakeEvent(uint256 _stakeid,address _to , uint _stakeamount);
    event unstake(uint256 _stakeid,address _to, uint _amount);

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
    function RewardPercentageChange( uint256 _stakeMonth , uint256 _percentage) public onlyOwner returns(uint256) {
        require(_percentage > 10000 &&  _percentage < 1000000,"Invalid parameter set for change percentage.");
        RewardPercentage[_stakeMonth] = _percentage;
        return  RewardPercentage[_stakeMonth];
    }

    /**
     * @dev return days wise staking percentage.
     * 
     */
    function viewPercentage(uint _stakeMonth) public view returns(uint){
        return RewardPercentage[_stakeMonth];
    }

    /**
     * @dev set number of token from the RewardPoolAddress
     *
     */
    function setRewardToken(uint _amount) public onlyOwner{     
        require(_amount > 0,"Amount should be greater then 0");
        TokenI(tokenAddress).transferFrom(RewardPoolAddress,address(this), _amount);       
    }

     /**
     * @dev returns total staking wallet profited amount
     *
     */
    function TotalProfitedAmt(address user,uint256 _stakeid) public view returns(uint){
        require(TotalProfit[msg.sender] > 0,"Wallet Address is not Exist");               
        uint profit; 
        uint locktime=staking[user][_stakeid]._stakingEndtime;         
        uint oneMonthLocktime=staking[user][_stakeid]._stakingStarttime+onemonth; 
       
        require(staking[user][_stakeid]._amount > 0,"Wallet Address is not Exist");            

        if(block.timestamp > locktime){
            profit= staking[user][_stakeid]._profit;
            
        }else if(block.timestamp > oneMonthLocktime){
            uint256 compmonth=CompletedMonth(_stakeid,user);
            profit = staking[user][_stakeid]._amount * ((compmonth*10000)/10000);            
           
        }
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
        require(_stakeamount > 0,"Amount should be greater then 0");        
        
        uint profit = _stakeamount * RewardPercentage[_staketime]/10000;
        
        TotalProfit[msg.sender]=TotalProfit[msg.sender]+profit;

        staking[msg.sender][activeStake[msg.sender]] =  _staking(_staketime,block.timestamp,block.timestamp + (_staketime*(24*60*60)),_stakeamount,profit);       
        
        TokenI(tokenAddress).transferFrom(msg.sender,address(this), _stakeamount);
        
        activeStake[msg.sender]=activeStake[msg.sender]+1;

        emit StakeEvent(activeStake[msg.sender],address(this),_stakeamount);
        return true;       
    }

    /**
     * @dev returns left vesting month.
     *
     */
    function CompletedMonth(uint256 _stakeid, address user) public view returns (uint){

            uint compmonth=0;

            if(staking[user][_stakeid]._stakingStarttime>0){
            uint oneMonthLocktime=staking[user][_stakeid]._stakingStarttime+onemonth;             
             for(uint i=1;i<=12;i++) 
             { 
                 if(oneMonthLocktime<=block.timestamp){
                       if(block.timestamp>=staking[user][_stakeid]._stakingStarttime+(onemonth*i)){ 
                         compmonth+=1;  
                     } else { 
                         break; 
                     }
                 }  
             } 
            }
            return compmonth;
            
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
        
        uint totalAmt;
        uint profit;       
        address user=msg.sender;
        //uint locktime=staking[user][_stakeid]._stakingEndtime; 
        uint locktime=staking[user][_stakeid]._stakingStarttime+600;
        //uint oneMonthLocktime=staking[user][_stakeid]._stakingStarttime+onemonth; 
        uint oneMonthLocktime=staking[user][_stakeid]._stakingStarttime+onemonth;
        require(staking[user][_stakeid]._amount > 0,"Wallet Address is not Exist");            

        if(block.timestamp > locktime){
            profit= staking[user][_stakeid]._profit;
            totalAmt= staking[user][_stakeid]._amount+ profit;
        }else if(block.timestamp > oneMonthLocktime){
            uint256 compmonth=CompletedMonth(_stakeid,user);
            profit = staking[user][_stakeid]._amount * ((compmonth*10000)/10000);            
            totalAmt= staking[user][_stakeid]._amount+ profit;
        } 
        activeStake[user]=activeStake[user]-1;
        lastStake=activeStake[user];

        staking[user][_stakeid]._Month = staking[user][lastStake]._Month;
        staking[user][_stakeid]._amount = staking[user][lastStake]._amount;
        staking[user][_stakeid]._stakingStarttime = staking[user][lastStake]._stakingStarttime;
        staking[user][_stakeid]._stakingEndtime = staking[user][lastStake]._stakingEndtime;
        staking[user][_stakeid]._profit = staking[user][lastStake]._profit;
        
        staking[user][lastStake]._Month = 0;
        staking[user][lastStake]._amount = 0;
        staking[user][lastStake]._stakingStarttime = 0;
        staking[user][lastStake]._stakingEndtime = 0;
        staking[user][lastStake]._profit = 0;

        TokenI(tokenAddress).transfer(user, totalAmt); 
        emit unstake(_stakeid,user,totalAmt);
            
        return true; 
    }
 
}
