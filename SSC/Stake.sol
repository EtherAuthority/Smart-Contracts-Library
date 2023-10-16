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
        uint _id;
        uint _stakingStarttime;
        uint _stakingEndtime;
        uint _amount;
        uint _profit;
        uint _RewardPercentage;
    }  
    address public RewardPoolAddress;
    address public tokenAddress=address(0);
    mapping(address=>mapping(uint256=>_staking)) public staking; 
    mapping(address=>uint256) private activeStake;
    mapping(address=>uint256) private TotalProfit;   
    uint256 private RewardPercentage; 
    uint256 private RewardPoolOldBal;
    uint256 private RewardPoolNewBal;
    uint256 private stakebalance;
    uint256 private Percentage;    
    uint256 private lastStake;
    //uint public onemonth = (31*1*(24*60*60));   
    uint public onemonth = 60;        
    
    constructor(address _tokenContract) {
        tokenAddress= _tokenContract;
        RewardPoolAddress = address(this);
        //Days wise Percentage        
        RewardPoolOldBal= address(this).balance;
        Percentage = (RewardPoolNewBal * 100)/RewardPoolOldBal;  
        if(Percentage >= 8) RewardPercentage=Percentage; else  RewardPercentage=8; 
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
     * @dev return days wise staking percentage.
     * 
     */
    function viewCurrentPercentage() public view returns(uint){
        return RewardPercentage;
    }

    /**
     * @dev stake amount for particular duration.
     * parameters : _staketime in days (exp: 30, 90, 180 ,360 )
     *              _stakeamount ( need to set token amount for stake)
     * it will increase activeStake result of particular wallet.
     */
    function stake(uint _stakeamount) public returns (bool){
        require(msg.sender != address(0),"Wallet Address can not be address 0");  
        require(TokenI(tokenAddress).balanceOf(msg.sender) > _stakeamount, "Insufficient tokens");
        
        require(_stakeamount > 0,"Amount should be greater then 0");        
        
        uint profit = (_stakeamount * RewardPercentage/100)*TokenI(tokenAddress).decimals();
        
        TotalProfit[msg.sender]=TotalProfit[msg.sender]+profit;

        staking[msg.sender][activeStake[msg.sender]] =  _staking(activeStake[msg.sender]+1,block.timestamp,block.timestamp + (30*(24*60*60)),_stakeamount,profit,RewardPercentage);       
        
        TokenI(tokenAddress).transferFrom(msg.sender,address(this), _stakeamount);

        stakebalance=((_stakeamount+(_stakeamount/2))*TokenI(tokenAddress).decimals())+profit;
        RewardPoolNewBal= address(this).balance-stakebalance;
        Percentage = (RewardPoolNewBal * 100)/RewardPoolOldBal;  
        if(Percentage >= 8) RewardPercentage=Percentage; else  RewardPercentage=8; 
        
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

 
}
