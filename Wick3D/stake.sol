/*
██╗    ██╗██╗ ██████╗██╗  ██╗██████╗ ██████╗     ███████╗████████╗ █████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗ 
██║    ██║██║██╔════╝██║ ██╔╝╚════██╗██╔══██╗    ██╔════╝╚══██╔══╝██╔══██╗██║ ██╔╝██║████╗  ██║██╔════╝ 
██║ █╗ ██║██║██║     █████╔╝  █████╔╝██║  ██║    ███████╗   ██║   ███████║█████╔╝ ██║██╔██╗ ██║██║  ███╗
██║███╗██║██║██║     ██╔═██╗  ╚═══██╗██║  ██║    ╚════██║   ██║   ██╔══██║██╔═██╗ ██║██║╚██╗██║██║   ██║
╚███╔███╔╝██║╚██████╗██║  ██╗██████╔╝██████╔╝    ███████║   ██║   ██║  ██║██║  ██╗██║██║ ╚████║╚██████╔╝
 ╚══╝╚══╝ ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═════╝     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                                                                                                                                  
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
interface TokenI {
  function transfer(address to, uint256 amount) external returns (bool);

  function transferFrom(address from, address to, uint256 amount) external returns (bool);

  function balanceOf(address to) external returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);
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
  constructor() {
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
 * @dev InsightX Staking contract  .
 */
contract InsightXStake is Ownable {
  struct _staking {
    uint256 _stakingCount;
    uint256 _stakingStarttime;
    uint256 _stakingEndtime;
    uint256 _stakeAmount;
    uint256 _reward;
    uint256 _extraReward;
    bool _eligibleForExtraReward;
    uint256 _depositNo;
    uint256 _poolBalance;
    bool _claimed;
  }

  address public immutable tokenAddress;
  mapping(address => _staking) public staking;
  uint256 public FourLakhsStakers;
  uint256 public OneMillionStakers;
  uint256 public normalStakers;
  uint256 public totalNumberOfDeposits = 0;

  constructor(address _tokenContract) {
    tokenAddress = _tokenContract;
  }

  /**
   * @dev To show contract event  .
   */
  event stakeEvent(address _from, uint256 _stakeamount);
  event unStakeEvent(address _to, uint256 _amount);
  event Deposited(address, uint256, uint256);
   /**
   * @dev To deposite ether in to the contract(pool).   * 
   * it will increase deposite counter for stake reward.
   */
  function deposite() public payable onlyOwner {
    require(msg.value > 0, 'Cannot be zero Ether');
    totalNumberOfDeposits++;
    emit Deposited(msg.sender, msg.value, totalNumberOfDeposits);
  }
  /**
   * @dev stake amount for particular duration.
   * _stakeamount :  amount for stake)
   * it will increase activeStake result of particular wallet.
   */
  function stake(uint256 _stakeamount) public returns (bool) {
    require(msg.sender != address(0), 'Wallet Address can not be zero');
    require(TokenI(tokenAddress).balanceOf(msg.sender) >= _stakeamount, 'Insufficient tokens');
    require(_stakeamount > 0, 'Amount should be greater then 0');
    uint256 totalStakeAmount = staking[msg.sender]._stakeAmount + _stakeamount;
    bool eligibleForExtraReward;
    uint256 totalNormalReward;
    uint256 totalExtraReward;
    uint256 normalreward;
    uint256 extraFourPercentReward;
    uint256 extraTenPercentReward;
    uint256 extraReward;
    if (staking[msg.sender]._stakeAmount > 0) {
      (normalreward, extraFourPercentReward, extraTenPercentReward) = reward();
      totalNormalReward = normalreward * staking[msg.sender]._stakeAmount;
      if (staking[msg.sender]._stakeAmount >= 400000 * 10 ** 18 && staking[msg.sender]._stakeAmount < 1000000 * 10 ** 18) {
        extraReward = extraFourPercentReward / FourLakhsStakers;
        totalExtraReward = extraReward * staking[msg.sender]._stakeAmount;
      } else if (staking[msg.sender]._stakeAmount >= 1000000 * 10 ** 18) {
        extraReward = extraTenPercentReward / OneMillionStakers;
        totalExtraReward = extraReward * staking[msg.sender]._stakeAmount;
      }
    }
    // new stakeing in extra reward 4 Percentage.
    if (
      totalStakeAmount >= 400000 * 10 ** 18 &&
      totalStakeAmount < 1000000 * 10 ** 18 &&
      staking[msg.sender]._eligibleForExtraReward == false
    ) {
      eligibleForExtraReward = true;
      FourLakhsStakers++; // to know how many stakers are stake uo to 400k
      if (staking[msg.sender]._stakeAmount == 0) normalStakers++;
    }
    // new stakeing in extra reward 10 Percentage.
    else if (totalStakeAmount >= 1000000 * 10 ** 18 && staking[msg.sender]._eligibleForExtraReward == false) {
      eligibleForExtraReward = true;
      OneMillionStakers++; // to know how many stakers stake up to 1M
      if (staking[msg.sender]._stakeAmount == 0) normalStakers++;
    }
    //stake user already stake with extra reward but new stakeing changed extra reward 4 Percentage to 10 Percentage.
    else if (
      staking[msg.sender]._eligibleForExtraReward == true &&
      staking[msg.sender]._stakeAmount >= 400000 * 10 ** 18 &&
      staking[msg.sender]._stakeAmount < 1000000 * 10 ** 18 &&
      totalStakeAmount >= 1000000 * 10 ** 18
    ) {
      eligibleForExtraReward = true;
      FourLakhsStakers--;
      OneMillionStakers++;
    }
    //stake user already stake with above 400k token
    else if (
      staking[msg.sender]._eligibleForExtraReward == true &&
      totalStakeAmount >= 400000 * 10 ** 18 &&
      totalStakeAmount < 1000000 * 10 ** 18
    ) {
      eligibleForExtraReward = true;
    }
    //stake user already stake with above 1M token
    else if (staking[msg.sender]._eligibleForExtraReward == true && totalStakeAmount >= 1000000 * 10 ** 18) {
      eligibleForExtraReward = true;
    }
    //for new stake user and normal reward
    else if (totalStakeAmount < 400000 * 10 ** 18 && staking[msg.sender]._eligibleForExtraReward == false) {
      normalStakers++;
    }

    TokenI(tokenAddress).transferFrom(msg.sender, address(this), _stakeamount);

    if (staking[msg.sender]._stakeAmount > 0) {
      staking[msg.sender] = _staking(
        staking[msg.sender]._stakingCount + 1,
        block.timestamp,
        0,
        totalStakeAmount,
        totalNormalReward,
        totalExtraReward,
        eligibleForExtraReward,
        staking[msg.sender]._depositNo + 1,
        address(this).balance,
        false
      );
    } else {
      staking[msg.sender] = _staking(
        staking[msg.sender]._stakingCount + 1,
        block.timestamp,
        0,
        _stakeamount,
        0,
        0,
        eligibleForExtraReward,
        (totalNumberOfDeposits + 2),
        address(this).balance,
        false
      );
    }

    emit stakeEvent(msg.sender, _stakeamount);
    return true;
  }

  /**
   * @dev stake amount release.
   * it will unstake and distribute rewrds to stakers.
   */
  function unStake() public payable returns (bool) {
    uint256 totalAmt;
    uint256 totalReward;
    uint256 normalreward;
    uint256 extraFourPercentReward;
    uint256 extraTenPercentReward;
    uint256 extraReward;
    require(staking[msg.sender]._stakeAmount > 0, 'You are not a staker');

    require(
      totalNumberOfDeposits >= staking[msg.sender]._depositNo,
      'Cannot unstake, you need to wait 2 weeks from your latest stake'
    );
    require(address(this).balance > 0, 'No rewards in pool');
    uint256 totalExtraReward;
    uint256 totalNormalReward;

    (normalreward, extraFourPercentReward, extraTenPercentReward) = reward();    
    totalNormalReward = normalreward * staking[msg.sender]._stakeAmount;
    if (staking[msg.sender]._stakeAmount >= 400000 * 10 ** 18 && staking[msg.sender]._stakeAmount < 1000000 * 10 ** 18) {
      extraReward = extraFourPercentReward / FourLakhsStakers;
      totalExtraReward = extraReward * staking[msg.sender]._stakeAmount;      
      FourLakhsStakers--;
    } else if (staking[msg.sender]._stakeAmount >= 1000000 * 10 ** 18) {
      extraReward = extraTenPercentReward / OneMillionStakers;
      totalExtraReward = extraReward * staking[msg.sender]._stakeAmount;
      OneMillionStakers--;
    } else {
      normalStakers--;
    }

    totalReward = (totalNormalReward + staking[msg.sender]._reward) + (totalExtraReward + staking[msg.sender]._extraReward);   
    totalAmt = staking[msg.sender]._stakeAmount;  

    TokenI(tokenAddress).transfer(msg.sender, totalAmt);
    (bool sent, ) = msg.sender.call{value: totalReward}('');
    require(sent, 'Failed to send Ether');

    staking[msg.sender]._stakingEndtime = block.timestamp;
    staking[msg.sender]._stakeAmount = 0;
    staking[msg.sender]._reward = 0;
    staking[msg.sender]._extraReward = 0;
    staking[msg.sender]._eligibleForExtraReward = false;
    staking[msg.sender]._claimed = true;

    emit unStakeEvent(msg.sender, totalAmt);
    return true;
  }

  /**
   * @dev reward calulation.
   * result :it will calculate normal reward and extra personage on 400k or 1M stake amount.
   */
  function reward() public returns (uint256, uint256, uint256) {
    uint256 extraFourPercentReward = 0;
    uint256 extraTenPercentReward = 0;
    uint256 normal = 0;
    uint256 stakebalance = TokenI(tokenAddress).balanceOf(address(this));
    uint256 diffAmount = address(this).balance - staking[msg.sender]._poolBalance;    
    if (FourLakhsStakers > 0) {
      extraFourPercentReward = (diffAmount / (stakebalance / 10 ** 18)) * 4;     
    }
    if (OneMillionStakers > 0) {
      extraTenPercentReward = (diffAmount / (stakebalance / 10 ** 18)) * 10;      
    }
    normal = diffAmount - ((extraFourPercentReward) + (extraTenPercentReward));   
    return ((normal / (stakebalance / 10 ** 18)), (extraFourPercentReward), (extraTenPercentReward));
  }

  receive() external payable {}
}
