// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface ICOPIA
{

    function balanceOf(address user) external view returns(uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
}
interface IUSDT
{

    function balanceOf(address user) external view returns(uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
}

contract COPIAStaking is Ownable, ReentrancyGuard {
    struct poolData
    {
        uint256 poolTime;
        uint256 DailyGrowthRate;
        uint256 poolCOPIAStaked;
        uint256 poolUSDTStaked;
    }
    mapping (uint => poolData) public poolInfo;
    uint public immutable poolLength;
    struct stakingData
    {
        uint256 amount;
        uint256 stakeTime;
        uint256 stakeEndTime;
        uint256 rewardToBeGained;
    }
    //user's pool wise stakingInfo
    mapping(address => mapping(uint =>stakingData[])) public COPIAStakeInfo;
    mapping(address => mapping(uint =>stakingData[])) public USDTStakeInfo;
    mapping(address => mapping(uint =>uint)) public userCOPIAStakeCount;
    mapping(address => mapping(uint =>uint)) public userUSDTStakeCount;
    mapping(address =>uint256) public pendingCOPIARewards;
    mapping(address =>uint256) public pendingUSDTRewards;
    struct contractValues
    {
        ICOPIA  COPIAToken;
        IUSDT USDTToken;
        uint256  totalCOPIAStaked;
        uint256  totalUSDTStaked;
        uint256 rewardFundCOPIA;
        uint256 rewardFundUSDT;
    }

    contractValues public contractInfo;

    //events
    event EvStake(address indexed staker, address indexed tokenAddress, uint256 amount, uint poolId, uint stakeIndex, uint256 _staketime);
    event EvUnStake(address indexed staker, address indexed tokenAddress, uint256 amount, uint stakeIndex, uint256 unstaketime);
    event EvRewardRefund(address indexed sender, uint256 amount, uint256 refundtime);
    event EvWithdrawRewards(address indexed staker, address indexed tokenAddress, uint256 rewards, uint poolId, uint stakeIndex, uint256 withdrawtime);
    /* These valuese cannot be update after deploy.
        poolDays arrays of days for pool
        _DailyGrowthRate %  - value should be multiply by 10000.. for 0.274 - 2740
        _poolDays = [30,182,365]
        _poolDailyGrowthRate = [1370,2055,2740]
    */
    constructor(address _stakeCOPIAToken, address _stakeUSDTToken, uint256[] memory _poolDays, uint256[] memory _poolDailyGrowthRate)  {
        require(_stakeCOPIAToken != address(0) && _stakeUSDTToken !=address(0),"Invalid token address");
        require(_poolDays.length == _poolDailyGrowthRate.length, "Length not matched");
        for(uint i=0;i<_poolDays.length;i++)
        {
            poolInfo[i].poolTime = _poolDays[i] ;
            poolInfo[i].DailyGrowthRate = _poolDailyGrowthRate[i];
        }
        poolLength = _poolDays.length;
        contractInfo.COPIAToken = ICOPIA(_stakeCOPIAToken);
        contractInfo.USDTToken = IUSDT(_stakeUSDTToken);
   }

    function stake(uint poolId, uint256 tokenamount, bool isUSDT) external
   {
        require(tokenamount > 0, "Token amount is zero");
        if(isUSDT){
            require(contractInfo.USDTToken.balanceOf(msg.sender) >= tokenamount, "Not enough tokens");
            require(contractInfo.USDTToken.allowance(msg.sender, address(this)) >= tokenamount,"Not enough allowances");

            uint stakeIndex = userUSDTStakeCount[msg.sender][poolId] + 1;
            uint256 prevBalance = contractInfo.USDTToken.balanceOf(address(this));
            contractInfo.USDTToken.transferFrom(msg.sender, address(this), tokenamount);
            uint256 newBalance = contractInfo.USDTToken.balanceOf(address(this));
            tokenamount = newBalance - prevBalance;
            uint256 endtime = block.timestamp + (poolInfo[poolId].poolTime * 86400);
            uint256 rewardToBeGained = ((tokenamount * poolInfo[poolId].DailyGrowthRate) * poolInfo[poolId].poolTime) / 1000000  ;
            USDTStakeInfo[msg.sender][poolId].push(stakingData(tokenamount, block.timestamp, endtime , rewardToBeGained));
            poolInfo[poolId].poolUSDTStaked += tokenamount;
            contractInfo.totalUSDTStaked += tokenamount;
            userUSDTStakeCount[msg.sender][poolId] = stakeIndex;
            emit EvStake(msg.sender, address(contractInfo.USDTToken), tokenamount, poolId, stakeIndex, block.timestamp);
        }
        else {
            require(contractInfo.COPIAToken.balanceOf(msg.sender) >= tokenamount, "Not enough tokens");
            require(contractInfo.COPIAToken.allowance(msg.sender, address(this)) >= tokenamount,"Not enough allowances");

            uint stakeIndex = userCOPIAStakeCount[msg.sender][poolId] + 1;
            contractInfo.COPIAToken.transferFrom(msg.sender, address(this), tokenamount);
            uint256 rewardToBeGained = ((tokenamount * poolInfo[poolId].DailyGrowthRate) * poolInfo[poolId].poolTime) / 1000000  ;
            uint256 endtime = block.timestamp + (poolInfo[poolId].poolTime * 86400);
            COPIAStakeInfo[msg.sender][poolId].push(stakingData(tokenamount, block.timestamp, endtime, rewardToBeGained));
            poolInfo[poolId].poolCOPIAStaked += tokenamount;
            contractInfo.totalCOPIAStaked += tokenamount;
            userCOPIAStakeCount[msg.sender][poolId] = stakeIndex;
            emit EvStake(msg.sender, address(contractInfo.COPIAToken), tokenamount, poolId, stakeIndex, block.timestamp);
        }

   }

    function unstake(uint poolId, uint stakeIndex, bool isUSDT) external {
        if(isUSDT){
            require(userUSDTStakeCount[msg.sender][poolId] > stakeIndex, "Invalid Stake Index");
            uint256 stakedamount = USDTStakeInfo[msg.sender][poolId][stakeIndex].amount;
            require(stakedamount > 0, "Invalid stake");
            require(USDTStakeInfo[msg.sender][poolId][stakeIndex].stakeEndTime <= block.timestamp,"Cannot unstake early");
            _withdrawRewardsUSDT(poolId, stakeIndex);
            USDTStakeInfo[msg.sender][poolId][stakeIndex].amount = 0;
            USDTStakeInfo[msg.sender][poolId][stakeIndex].stakeTime = 0;
            poolInfo[poolId].poolUSDTStaked -= stakedamount;
            contractInfo.totalUSDTStaked -= stakedamount;
            contractInfo.USDTToken.transfer(msg.sender, stakedamount);
            emit EvUnStake(msg.sender, address(contractInfo.USDTToken), stakedamount, stakeIndex, block.timestamp);
        }
        else
        {
            require(userCOPIAStakeCount[msg.sender][poolId] > stakeIndex, "Invalid Stake Index");
            uint256 stakedamount = COPIAStakeInfo[msg.sender][poolId][stakeIndex].amount;
            require(stakedamount > 0, "Invalid stake");
            require(COPIAStakeInfo[msg.sender][poolId][stakeIndex].stakeEndTime <= block.timestamp,"Cannot unstake early");
            _withdrawRewardsCOPIA(poolId, stakeIndex);
            COPIAStakeInfo[msg.sender][poolId][stakeIndex].amount = 0;
            COPIAStakeInfo[msg.sender][poolId][stakeIndex].stakeTime = 0;
            poolInfo[poolId].poolCOPIAStaked -= stakedamount;
            contractInfo.totalCOPIAStaked -= stakedamount;
            contractInfo.COPIAToken.transfer(msg.sender, stakedamount);
            emit EvUnStake(msg.sender, address(contractInfo.COPIAToken), stakedamount, stakeIndex, block.timestamp);
        }
    }

   function withdrawPendings(bool isUSDT) external nonReentrant
   {
        if(isUSDT)
        {
            uint256 amount = pendingUSDTRewards[msg.sender];
            require(amount >0, "No pending USDT rewards");
            require(amount > 0 && contractInfo.rewardFundUSDT >= amount && contractInfo.USDTToken.balanceOf(address(this)) >= amount,"Contract does not have enough reward fund");
            pendingUSDTRewards[msg.sender] = 0;
            contractInfo.rewardFundUSDT -= amount;
            contractInfo.USDTToken.transfer(msg.sender, amount);
            emit EvWithdrawRewards(msg.sender, address(contractInfo.USDTToken), amount, 0, 0, block.timestamp);
        }
        else {
            uint256 amount = pendingCOPIARewards[msg.sender];
            require(pendingCOPIARewards[msg.sender]>0, "No pending COPIA rewards");
            require(amount > 0 && contractInfo.rewardFundCOPIA >= amount && contractInfo.COPIAToken.balanceOf(address(this)) >= amount,"Contract does not have enough reward fund");
            pendingCOPIARewards[msg.sender] = 0;
            contractInfo.rewardFundCOPIA -= amount;
            contractInfo.COPIAToken.transfer(msg.sender, amount);
            emit EvWithdrawRewards(msg.sender, address(contractInfo.COPIAToken), amount, 0, 0, block.timestamp);
        }
   }

   //Owner Function
    function sendRewardCOPIAToken(uint256 amount) external onlyOwner nonReentrant
    {
        contractInfo.COPIAToken.transferFrom(msg.sender, address(this), amount);
        contractInfo.rewardFundCOPIA += amount;
        emit EvRewardRefund(msg.sender, amount, block.timestamp);
    }
    function sendRewardUSDTToken(uint256 amount) external onlyOwner nonReentrant
    {
        uint256 prevBalance = contractInfo.USDTToken.balanceOf(address(this));
        contractInfo.USDTToken.transferFrom(msg.sender, address(this), amount);
        uint256 newBalance = contractInfo.USDTToken.balanceOf(address(this));
        amount = newBalance - prevBalance;
        contractInfo.rewardFundUSDT += amount;
        emit EvRewardRefund(msg.sender, amount, block.timestamp);
    }
    function rescueRewardFundCOPIA(uint256 amount) external onlyOwner nonReentrant
    {
        require(contractInfo.rewardFundCOPIA >= amount,"Not enough reward fund");
        contractInfo.rewardFundCOPIA -= amount;
        contractInfo.COPIAToken.transfer(msg.sender, amount);
    }
    function rescueRewardFundUSDT(uint256 amount) external onlyOwner nonReentrant
    {
        require(contractInfo.rewardFundUSDT >= amount,"Not enough reward fund");
        contractInfo.rewardFundUSDT -= amount;
        contractInfo.USDTToken.transfer(msg.sender, amount);
    }
    function updateDailyGrowth(uint256 poolIndex, uint256 _dailyGrowth) external onlyOwner
    {
        require(_dailyGrowth > 0,"daily growth must be greater than 0");
        poolInfo[poolIndex].DailyGrowthRate = _dailyGrowth;
    }


    //internal function
    function _withdrawRewardsCOPIA(uint poolId, uint stakeIndex)  internal nonReentrant
   {
        uint256 rewards = COPIAStakeInfo[msg.sender][poolId][stakeIndex].rewardToBeGained ;

        if(rewards > 0 && contractInfo.rewardFundCOPIA >= rewards && contractInfo.COPIAToken.balanceOf(address(this)) >= rewards)
        {
            COPIAStakeInfo[msg.sender][poolId][stakeIndex].rewardToBeGained = 0;
            contractInfo.rewardFundCOPIA -= rewards;
            contractInfo.COPIAToken.transfer(msg.sender, rewards);
            emit EvWithdrawRewards(msg.sender, address(contractInfo.COPIAToken), rewards, poolId, stakeIndex, block.timestamp);
        }
        else {
            pendingCOPIARewards[msg.sender] += rewards;
        }
   }
    function _withdrawRewardsUSDT(uint poolId, uint stakeIndex)  internal nonReentrant
   {
        uint256 rewards = USDTStakeInfo[msg.sender][poolId][stakeIndex].rewardToBeGained ;

        if(rewards > 0 && contractInfo.rewardFundUSDT >= rewards && contractInfo.USDTToken.balanceOf(address(this)) >= rewards)
        {
            USDTStakeInfo[msg.sender][poolId][stakeIndex].rewardToBeGained =0;
            contractInfo.rewardFundUSDT-= rewards;
            contractInfo.USDTToken.transfer(msg.sender, rewards);
            emit EvWithdrawRewards(msg.sender, address(contractInfo.USDTToken), rewards, poolId, stakeIndex, block.timestamp);
        }
        else {
            pendingUSDTRewards[msg.sender] += rewards;
        }
   }

}