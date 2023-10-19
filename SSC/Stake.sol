// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface TokenI {    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function decimals() external view returns (uint8);
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
        uint256 _id;
        uint256 _stakingStarttime;
        uint256 _stakingEndtime;
        uint256 _amount;
        uint256 _profit;
        uint256 _RewardPercentage;
    }  
    address public rewardPoolAddress;
    address public tokenAddress=address(0);
    mapping(address=>mapping(uint256=>_staking)) public staking; 
    mapping(address=>uint256) public activeStake;
    mapping(address=>uint256) public TotalProfit;   
    uint256 private rewardPercentage=8333; 
    uint256 private currentAPYpercentage=100000;
    uint256 private bonusPercentage;
    uint256 private rewardPoolOldBal;
    uint256 private rewardPoolNewBal;
    uint256 private stakebalance; 
    uint256 private lastStake=0;
    uint256 private onemonth = (31*1*(24*60*60));   
    uint256 private oneweek = (7*(24*60*60)); 
          
    
    constructor(address _tokenContract) {
        tokenAddress= _tokenContract;
        rewardPoolAddress = address(this);             
        rewardPoolOldBal= 1000000000*10**18;
        rewardPoolNewBal=rewardPoolOldBal;
       
        
    }
    /**
     * @dev To show contract event  .
     */
    event StakeEvent(uint256 _stakeid,address _to , uint _stakeamount);
    event unstake(uint256 _stakeid,address _to, uint _amount);

    /**
     * @dev returns number of stake, done by particular wallet .
     */
    function TotalStake()public view returns(uint256){
        return activeStake[msg.sender]; 
    } 
    
    /**
     * @dev return APY wise staking percentage.
     * 
     */
    function currentAPY() public view returns(uint){
        if((rewardPoolNewBal *100*1000)/rewardPoolOldBal >= 8000) return (rewardPoolNewBal *100*1000)/rewardPoolOldBal; else  return 8000; 
    }

    /**
     * @dev return month wise staking percentage.
     * 
     */
    function rewardInPercentage() public view returns(uint){  
        if(((rewardPoolNewBal *100*1000)/rewardPoolOldBal)/12 >= 6667) return ((rewardPoolNewBal *100*1000)/rewardPoolOldBal)/12; else  return 6667; 
    }
    /**
     * @dev return only Reward Balance from this Stake contract.
     * 
     */
    function viewRewardPoolBalance() public view returns(uint){
        return rewardPoolNewBal;
    }
    

     /**
     * @dev returns total staking wallet profited amount
     *
     */
    function totalProfitedAmt(address user,uint256 _stakeid) public view returns(uint){
        require(TotalProfit[msg.sender] > 0,"Wallet Address is not Exist");               
        uint profit; 
        uint locktime=staking[user][_stakeid]._stakingEndtime;         
        uint oneWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek;
        uint twoWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek*2;
        uint threeWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek*3;         
        require(staking[user][_stakeid]._amount > 0,"Wallet Address is not Exist");   

        for(uint i=1;i<=lastStake;i++){     

        if(block.timestamp >= locktime){
            if(block.timestamp >= locktime+oneweek){
                profit= staking[user][_stakeid]._profit+(staking[user][_stakeid]._amount/2);                
            }else{
                profit= staking[user][_stakeid]._profit;                
            }
        }else if(block.timestamp > oneWeekLocktime){
            profit= (staking[user][_stakeid]._profit*25)/100;            
        }else if(block.timestamp > twoWeekLocktime){
            profit= (staking[user][_stakeid]._profit*35)/100;            
        } 
        else if(block.timestamp > threeWeekLocktime){
            profit= (staking[user][_stakeid]._profit*40)/100;
            
        } 
        profit+=profit; 
        }
        return profit;
    }

    /**
     * @dev stake amount for particular duration.
     * parameters : _stakeamount ( need to set token amount for stake)
     * it will increase activeStake result of particular wallet.
     */
    function stake(uint _stakeamount) public returns (bool){
 
        require(TokenI(tokenAddress).balanceOf(msg.sender) >= _stakeamount, "Insufficient tokens");        
        require(_stakeamount > 0,"Amount should be greater then 0"); 

        _stakeamount=_stakeamount*10**18;
        rewardPoolOldBal=rewardPoolNewBal;
        uint profit = (_stakeamount * rewardPercentage)/100000;        
        TotalProfit[msg.sender]=TotalProfit[msg.sender]+profit;

        staking[msg.sender][activeStake[msg.sender]] =  _staking(activeStake[msg.sender],block.timestamp,block.timestamp + (30*(24*60*60)),_stakeamount,profit,rewardPercentage);       
        
        TokenI(tokenAddress).transferFrom(msg.sender,address(this), _stakeamount);
        bonusPercentage=rewardPercentage/2;
        stakebalance=_stakeamount+(_stakeamount*(bonusPercentage/1000))+profit;
        rewardPoolNewBal= rewardPoolOldBal-stakebalance;
        rewardInPercentage();         
        activeStake[msg.sender]=activeStake[msg.sender]+1;

        emit StakeEvent(activeStake[msg.sender],address(this),_stakeamount);
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
        
        uint256 totalAmt;
        uint256 profit;       
        address user=msg.sender;
        uint256 locktime=staking[user][_stakeid]._stakingEndtime; 
        uint256 oneWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek;
        uint256 twoWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek*2;
        uint256 threeWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek*3;         
        require(staking[user][_stakeid]._amount > 0,"Wallet Address is not Exist!");  
        require(_stakeid > 0,"Please set valid stakeid!");           

        if(block.timestamp > locktime){
            if(block.timestamp > locktime+oneweek){
                profit= staking[user][_stakeid]._profit+(staking[user][_stakeid]._amount/2);
                totalAmt= staking[user][_stakeid]._amount+ profit;
            }else{
                rewardPoolOldBal=rewardPoolNewBal;
                profit= staking[user][_stakeid]._profit;
                totalAmt= staking[user][_stakeid]._amount+ profit;
                uint stakeBack=(staking[user][_stakeid]._amount/2);
                stakebalance=stakebalance - stakeBack;
                rewardPoolNewBal= rewardPoolOldBal+stakebalance;
            }
        }else if(block.timestamp > oneWeekLocktime){
            rewardPoolOldBal=rewardPoolNewBal;
            profit= (staking[user][_stakeid]._profit*25)/100;
            uint penalty = (staking[user][_stakeid]._amount*5)/100;
            uint totstakeAmt=staking[user][_stakeid]._amount-penalty;
            uint stakeBack=penalty + (staking[user][_stakeid]._profit*75);
            stakebalance=stakebalance - stakeBack;
            rewardPoolNewBal= rewardPoolOldBal+stakebalance;
            totalAmt= totstakeAmt+profit;
        }else if(block.timestamp > twoWeekLocktime){
            rewardPoolOldBal=rewardPoolNewBal;
            profit= (staking[user][_stakeid]._profit*35)/100;
            uint penalty = (staking[user][_stakeid]._amount*5)/100;
            uint totstakeAmt=staking[user][_stakeid]._amount-penalty;
            uint stakeBack=penalty + (staking[user][_stakeid]._profit*65);
            stakebalance=stakebalance - stakeBack;
            rewardPoolNewBal= rewardPoolOldBal+stakebalance;
            totalAmt= totstakeAmt+profit;
        } 
        else if(block.timestamp > threeWeekLocktime){
            rewardPoolOldBal=rewardPoolNewBal;
            profit= (staking[user][_stakeid]._profit*40)/100;
            uint penalty = (staking[user][_stakeid]._amount*5)/100;
            uint totstakeAmt=staking[user][_stakeid]._amount-penalty;
            uint stakeBack=penalty + (staking[user][_stakeid]._profit*60);
            stakebalance=stakebalance - stakeBack;            
            rewardPoolNewBal= rewardPoolOldBal+stakebalance;
            totalAmt= totstakeAmt+profit;
        }  
        activeStake[user]=activeStake[user]-1;
        lastStake=activeStake[user];

        staking[user][_stakeid]._id = staking[user][lastStake]._id;
        staking[user][_stakeid]._amount = staking[user][lastStake]._amount;
        staking[user][_stakeid]._stakingStarttime = staking[user][lastStake]._stakingStarttime;
        staking[user][_stakeid]._stakingEndtime = staking[user][lastStake]._stakingEndtime;
        staking[user][_stakeid]._profit = staking[user][lastStake]._profit;
        staking[user][_stakeid]._RewardPercentage = staking[user][lastStake]._RewardPercentage;
        
        
        staking[user][lastStake]._id = 0;
        staking[user][lastStake]._amount = 0;
        staking[user][lastStake]._stakingStarttime = 0;
        staking[user][lastStake]._stakingEndtime = 0;
        staking[user][lastStake]._profit = 0;
        staking[user][lastStake]._RewardPercentage = 0;

        TokenI(tokenAddress).transfer(user, totalAmt); 
        emit unstake(_stakeid,user,totalAmt);
            
        return true; 
    }

     /**
     * @dev To know total withdrawal stake amount 
     * parameters : _stakeid is active stake ids which is getting from activeStake-
     */
    function viewWithdrawAmount(uint256 _stakeid) public view returns (uint256){        
        
        uint256 totalAmt;
        uint256 profit;       
        address user=msg.sender;
        uint256 locktime=staking[user][_stakeid]._stakingEndtime;            

        uint256 oneWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek;
        uint256 twoWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek*2;
        uint256 threeWeekLocktime=staking[user][_stakeid]._stakingStarttime+oneweek*3;         
        require(staking[user][_stakeid]._amount > 0,"Wallet Address is not Exist");           

        if(block.timestamp > locktime){
            if(block.timestamp > locktime+oneweek){
                profit= staking[user][_stakeid]._profit+(staking[user][_stakeid]._amount/2);
                totalAmt= staking[user][_stakeid]._amount+ profit;
            }else{                
                profit= staking[user][_stakeid]._profit;
                totalAmt= staking[user][_stakeid]._amount+ profit;                
            }
        }else if(block.timestamp > oneWeekLocktime){            
            profit= (staking[user][_stakeid]._profit*25)/100;
            uint penalty = (staking[user][_stakeid]._amount*5)/100;
            uint totstakeAmt=staking[user][_stakeid]._amount-penalty;            
            totalAmt= totstakeAmt+profit;
        }else if(block.timestamp > twoWeekLocktime){           
            profit= (staking[user][_stakeid]._profit*35)/100;
            uint penalty = (staking[user][_stakeid]._amount*5)/100;
            uint totstakeAmt=staking[user][_stakeid]._amount-penalty;
            totalAmt= totstakeAmt+profit;
        }else if(block.timestamp > threeWeekLocktime){
            profit= (staking[user][_stakeid]._profit*40)/100;
            uint penalty = (staking[user][_stakeid]._amount*5)/100;
            uint totstakeAmt=staking[user][_stakeid]._amount-penalty; 
            totalAmt= totstakeAmt+profit;
        }         
            
        return totalAmt; 
    }

     /**
     * @dev To know Penalty amount, if you unstake before locktime
     * parameters : _stakeid is active stake ids which is getting from activeStake-
     */
     function viewPenalty(uint256 _stakeid) public view returns (uint256){  
        address user=msg.sender;         
        uint256 locktime=staking[user][_stakeid]._stakingEndtime; 
        uint256 penalty=0; 
        require(staking[user][_stakeid]._amount > 0,"Wallet Address is not Exist");           

        if(block.timestamp < locktime){ 
            penalty = (staking[user][_stakeid]._amount*5)/100;
        }
        return penalty; 
    }
 
}
