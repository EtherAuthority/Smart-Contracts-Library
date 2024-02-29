/*
██╗    ██╗██╗ ██████╗██╗  ██╗██████╗ ██████╗     ███████╗████████╗ █████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗ 
██║    ██║██║██╔════╝██║ ██╔╝╚════██╗██╔══██╗    ██╔════╝╚══██╔══╝██╔══██╗██║ ██╔╝██║████╗  ██║██╔════╝ 
██║ █╗ ██║██║██║     █████╔╝  █████╔╝██║  ██║    ███████╗   ██║   ███████║█████╔╝ ██║██╔██╗ ██║██║  ███╗
██║███╗██║██║██║     ██╔═██╗  ╚═══██╗██║  ██║    ╚════██║   ██║   ██╔══██║██╔═██╗ ██║██║╚██╗██║██║   ██║
╚███╔███╔╝██║╚██████╗██║  ██╗██████╔╝██████╔╝    ███████║   ██║   ██║  ██║██║  ██╗██║██║ ╚████║╚██████╔╝
 ╚══╝╚══╝ ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═════╝     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                                                                                                                                  
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title InsightXStake
 * @notice A contract for InsightX Staking, allowing users to stake and earn rewards.
 * @dev This contract extends the ERC20 token standard and adds staking functionality.
 * It allows users to stake their tokens and earn rewards based on the amount and duration of their stake.
 * The contract also includes ownership functionalities to manage the contract.
 */
contract InsightXStake is ERC20, Ownable {
    struct _staking {
        uint256 _stakingCount;
        uint256 _stakingStarttime;
        uint256 _stakingEndtime;
        uint256 _stakeAmount;
        uint256 _reward;
        uint256 _extraReward;
        bool _eligibleForExtraReward;
        uint256 _depositNo;
        uint256 _canWithdrawOndepositNo;
        uint256 _poolBalance;
        bool _claimed;
    }

    struct _deposit {
        uint256 _depositCount;
        uint256 _depositTime;
        uint256 _depositAmount;
        uint256 _normalReward;
        uint256 _extraFourPercentReward;
        uint256 _extraTenPercentReward;
        uint256 _poolBalance;
        uint256 _previousPoolBalance;
        uint256 _stakeBalance;
    }

    ERC20 public immutable tokenAddress;
    mapping(address => _staking) public staking;
    uint256 public totalNumberOfDeposits = 0;
    mapping(uint256 => _deposit) public deposit;
    uint256 public fourLakhsStakers;
    uint256 public oneMillionStakers;
    uint256 public totalNoOfStakers;   
    uint256 public existingPoolBalance;
    /**
    * @notice Constructor function for initializing the InsightX Staking contract.
    * @dev This constructor initializes the InsightX Staking contract with the provided token contract address
    * and sets the initial owner of the contract. It also initializes the ERC20 token with the name "InsightX Staking"
    * and symbol "stINX". The token contract address must be provided to interact with the staking contract.
    * @param _tokenContract The address of the ERC20 token contract to be used for staking.
    * @param initialOwner The address of the initial owner of the staking contract.
    */
    constructor(
        address _tokenContract,
        address initialOwner
    ) ERC20("InsightX Staking", "stINX") Ownable(initialOwner) {
        tokenAddress = ERC20(_tokenContract);
    }

    /**
     * @dev To show contract event  .
     */
    event stakeEvent(address _from, uint256 _stakeamount);
    event unStakeEvent(address _to, uint256 _amount, uint256 _reward);
    event Deposited(address, uint256, uint256);
    event claimedRewards(address _to, uint256 _reward);

    // Only staking contracts or burn are allowed.
    error UnauthorizedTransfer();

    /**
    * @notice Deposits ETH rewards into the staking pool.
    * @dev This function allows the contract owner to deposit ETH rewards into the staking pool.
    * It checks if the deposited ETH amount is greater than zero and if there are stakers eligible for rewards.
    * The function calculates rewards for stakers based on the current pool balances.
    * After depositing rewards, the function records deposit information and updates pool balances. Additionally,
    * it emits a deposit event to notify observers about the deposit action.
    */
    function depositReward() public payable onlyOwner {
        require(msg.value > 0, "Cannot be zero Ether");
        require(
            tokenAddress.balanceOf(address(this)) > 0,
            "No stakers from previous deposit"
        );
        uint256 normalreward;
        uint256 extraFourPercentReward;
        uint256 extraTenPercentReward;

        (
            normalreward,
            extraFourPercentReward,
            extraTenPercentReward
        ) = calculateRewards();
        totalNumberOfDeposits++;
        deposit[totalNumberOfDeposits] = _deposit(
            totalNumberOfDeposits,
            block.timestamp,
            msg.value,
            normalreward,
            extraFourPercentReward,
            extraTenPercentReward,
            existingPoolBalance + msg.value,
            existingPoolBalance,
            tokenAddress.balanceOf(address(this))
        );
        existingPoolBalance += msg.value;
        emit Deposited(msg.sender, msg.value, totalNumberOfDeposits);
    }

    /**
    * @notice Stakes tokens into the staking pool.
    * @dev This function allows users to stake their tokens into the staking pool.
    * It checks various conditions such as the availability of tokens, stake amount,
    * and eligibility for extra rewards based on stake thresholds. The function also
    * calculates and updates rewards for existing stakes if applicable. After a successful
    * stake, the tokens are transferred from the caller's address to the staking pool,
    * and new staking information is recorded for the caller. Additionally, the function
    * emits a stake event to notify observers about the stake action.
    * @param _stakeamount The amount of tokens to be staked.
    * @return A boolean indicating the success of the stake operation.
    */
    function stake(uint256 _stakeamount) public returns (bool) {
        require(msg.sender != address(0), "Wallet Address can not be zero");
        require(
            tokenAddress.balanceOf(msg.sender) >= _stakeamount,
            "Insufficient tokens"
        );
        require(_stakeamount > 0, "Amount should be greater then 0");
        uint256 totalStakeAmount = staking[msg.sender]._stakeAmount +
            _stakeamount;
        bool eligibleForExtraReward;
        uint256 totalNormalReward;
        uint256 totalExtraReward;
        uint256 normalreward;
        uint256 extraFourPercentReward;
        uint256 extraTenPercentReward;
        if (
            staking[msg.sender]._stakeAmount > 0 &&
            totalNumberOfDeposits >= staking[msg.sender]._depositNo
        ) {
            uint256 i = staking[msg.sender]._depositNo + 1;

            for (i; i <= totalNumberOfDeposits; i++) {
                normalreward += deposit[i]._normalReward;
                extraFourPercentReward += deposit[i]._extraFourPercentReward;
                extraTenPercentReward += deposit[i]._extraTenPercentReward;
            }
            totalNormalReward = (normalreward *
                (staking[msg.sender]._stakeAmount / 10 ** 18));
            if (
                staking[msg.sender]._stakeAmount >= 400000 * 10 ** 18 &&
                staking[msg.sender]._stakeAmount < 1000000 * 10 ** 18
            ) {
                totalExtraReward = extraFourPercentReward;
            } else if (staking[msg.sender]._stakeAmount >= 1000000 * 10 ** 18) {
                totalExtraReward = extraTenPercentReward;
            }
        }

        // new stakeing in extra reward 4 Percentage.
        if (
            totalStakeAmount >= 400000 * 10 ** 18 &&
            totalStakeAmount < 1000000 * 10 ** 18 &&
            staking[msg.sender]._eligibleForExtraReward == false
        ) {
            eligibleForExtraReward = true;
            fourLakhsStakers++; // to know how many stakers are stake uo to 400k
            if (staking[msg.sender]._stakeAmount == 0) totalNoOfStakers++;
        }
        // new stakeing in extra reward 10 Percentage.
        else if (
            totalStakeAmount >= 1000000 * 10 ** 18 &&
            staking[msg.sender]._eligibleForExtraReward == false
        ) {
            eligibleForExtraReward = true;
            oneMillionStakers++; // to know how many stakers stake up to 1M
            if (staking[msg.sender]._stakeAmount == 0) totalNoOfStakers++;
        }
        //stake user already stake with extra reward but new stakeing changed extra reward 4 Percentage to 10 Percentage.
        else if (
            staking[msg.sender]._eligibleForExtraReward == true &&
            staking[msg.sender]._stakeAmount >= 400000 * 10 ** 18 &&
            staking[msg.sender]._stakeAmount < 1000000 * 10 ** 18 &&
            totalStakeAmount >= 1000000 * 10 ** 18
        ) {
            eligibleForExtraReward = true;
            fourLakhsStakers--;
            oneMillionStakers++;
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
        else if (
            staking[msg.sender]._eligibleForExtraReward == true &&
            totalStakeAmount >= 1000000 * 10 ** 18
        ) {
            eligibleForExtraReward = true;
        }
        //for new stake user and normal reward
        else if (
            staking[msg.sender]._stakeAmount == 0 &&
            totalStakeAmount < 400000 * 10 ** 18 &&
            staking[msg.sender]._eligibleForExtraReward == false
        ) {
            totalNoOfStakers++;
        }

        require(
            tokenAddress.transferFrom(msg.sender, address(this), _stakeamount),
            "INX transfer failed"
        );

        _mint(msg.sender, _stakeamount);

        if (staking[msg.sender]._stakeAmount > 0) {
            staking[msg.sender] = _staking(
                staking[msg.sender]._stakingCount + 1,
                block.timestamp,
                0,
                totalStakeAmount,
                totalNormalReward,
                totalExtraReward,
                eligibleForExtraReward,
                totalNumberOfDeposits,
                staking[msg.sender]._canWithdrawOndepositNo + 1,
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
                totalNumberOfDeposits,
                (totalNumberOfDeposits + 2),
                address(this).balance,
                false
            );
        }

        emit stakeEvent(msg.sender, _stakeamount);
        return true;
    }

    /**
    * @notice Unstakes tokens and claims rewards for the caller.
    * @dev This function allows stakers to unstake their tokens and claim their accumulated rewards from the staking pool.
    * It checks if the caller is a staker and has tokens staked, and verifies if the staker has passed the waiting period
    * required for unstaking. It then calculates the total rewards for the staker, including both base rewards and any extra
    * rewards earned based on their stake amount. The function updates staker-related variables, including resetting balances
    * and flags. The claimed rewards and unstaked tokens are transferred to the staker's address. If the staker's stake amount
    * falls within certain thresholds, it also updates the corresponding staker counts. The function also burns the unstaked tokens
    * from the staker's balance. After successful execution, it emits an event indicating the unstake action.
    * @return A boolean indicating the success of the unstake operation.
    */
    function unStake() public payable returns (bool) {
        uint256 totalAmt;
        uint256 totalReward;
        uint256 normalreward;
        uint256 extraFourPercentReward;
        uint256 extraTenPercentReward;
        require(staking[msg.sender]._stakeAmount > 0, "You are not a staker");

        require(
            totalNumberOfDeposits >=
                staking[msg.sender]._canWithdrawOndepositNo,
            "Cannot unstake, you need to wait 2 weeks from your latest stake"
        );
        require(address(this).balance > 0, "No rewards in pool");
        uint256 totalNormalReward;
        uint256 totalExtraFourPercentReward;
        uint256 totalExtraTenPercentReward;

        (
            normalreward,
            extraFourPercentReward,
            extraTenPercentReward
        ) = calculateRewards();

        uint256 i = staking[msg.sender]._depositNo + 1;
        for (i; i <= totalNumberOfDeposits; i++) {
            totalNormalReward += deposit[i]._normalReward;
            totalExtraFourPercentReward += deposit[i]._extraFourPercentReward;
            totalExtraTenPercentReward += deposit[i]._extraTenPercentReward;
        }

        totalNormalReward += normalreward;

        totalNormalReward = (totalNormalReward *
            (staking[msg.sender]._stakeAmount / 10 ** 18));

        totalNormalReward += staking[msg.sender]._reward;

        totalExtraFourPercentReward += staking[msg.sender]._extraReward;
        totalExtraTenPercentReward += staking[msg.sender]._extraReward;
        if (
            staking[msg.sender]._stakeAmount >= 400000 * 10 ** 18 &&
            staking[msg.sender]._stakeAmount < 1000000 * 10 ** 18
        ) {
            totalExtraFourPercentReward += extraFourPercentReward;
            totalExtraTenPercentReward = 0;

            fourLakhsStakers--;
        } else if (staking[msg.sender]._stakeAmount >= 1000000 * 10 ** 18) {
            totalExtraTenPercentReward += extraTenPercentReward;
            totalExtraFourPercentReward = 0;

            oneMillionStakers--;
        } else {
            totalExtraFourPercentReward = 0;
            totalExtraTenPercentReward = 0;
            totalNoOfStakers--;
        }

        totalReward = (totalNormalReward +
            totalExtraFourPercentReward +
            totalExtraTenPercentReward);

        totalAmt = staking[msg.sender]._stakeAmount;

        staking[msg.sender]._stakingEndtime = block.timestamp;
        staking[msg.sender]._stakeAmount = 0;
        staking[msg.sender]._reward = 0;
        staking[msg.sender]._extraReward = 0;
        staking[msg.sender]._eligibleForExtraReward = false;
        staking[msg.sender]._claimed = true;
        staking[msg.sender]._depositNo = 0;
        staking[msg.sender]._canWithdrawOndepositNo = 0;
        staking[msg.sender]._poolBalance = 0;
        existingPoolBalance -= totalReward;

        _burn(msg.sender, totalAmt);
        require(
            tokenAddress.transfer(msg.sender, totalAmt),
            "INX transfer failed"
        );

        (bool sent, ) = msg.sender.call{value: totalReward}("");
        require(sent, "Failed to send Rewards");

        emit unStakeEvent(msg.sender, totalAmt, totalReward);
        return true;
    }
    /**
    * @notice Claims rewards for the caller from the staking pool.
    * @dev This function allows stakers to claim their accumulated rewards from the staking pool.
    * It checks if the caller is a staker and has rewards to claim, and ensures that the contract
    * has sufficient ETH balance to fulfill the reward payment. The total reward includes both
    * the base reward and any extra reward earned by the staker. After claiming rewards, the staker's
    * reward and extra reward balances are reset to zero, and the claimed amount is subtracted from
    * the existing pool balance. The claimed rewards are transferred to the staker's address.
    * @return A boolean indicating the success of the reward claim operation.
    */
    function claimRewards() public returns (bool) {
        require(staking[msg.sender]._stakeAmount > 0, "You are not a staker");
        require(staking[msg.sender]._reward > 0, "No rewards claim");
        require(
            address(this).balance > staking[msg.sender]._reward,
            "No rewards in pool"
        );
        uint256 totalReward;
        totalReward = (staking[msg.sender]._reward +
            staking[msg.sender]._extraReward);

        staking[msg.sender]._reward = 0;
        staking[msg.sender]._extraReward = 0;
        existingPoolBalance -= totalReward;

        (bool sent, ) = msg.sender.call{value: totalReward}("");
        require(sent, "Failed to send Rewards");

        emit claimedRewards(msg.sender, totalReward);

        return true;
    }

    /**
    * @notice Calculates the rewards for stakers based on the current contract ETH deposit.
    * @dev This internal function calculates the rewards to be distributed among stakers based on the difference
    * between the current contract balance and the previous balance, and the number of stakers meeting certain thresholds.
    * It considers extra rewards for stakers holding certain amounts of tokens.
    * @return A tuple containing the calculated rewards: (normalReward, extraFourPercentReward, extraTenPercentReward).
    * - normalReward: The portion of rewards distributed equally among all stakers.
    * - extraFourPercentReward: Additional reward allocated for stakers holding at least four lakhs of tokens.
    * - extraTenPercentReward: Additional reward allocated for stakers holding at least one million tokens.
    */
    function calculateRewards()
        internal
        view
        returns (uint256, uint256, uint256)
    {
        uint256 extraFourPercentReward = 0;
        uint256 extraTenPercentReward = 0;
        uint256 normalReward = 0;
        uint256 stakebalance = 0;
        if (tokenAddress.balanceOf(address(this)) > 0) {
            stakebalance = tokenAddress.balanceOf(address(this));

            uint256 diffrenceInPoolBalance = address(this).balance -
                existingPoolBalance;

            if (fourLakhsStakers > 0) {
                extraFourPercentReward =
                    (diffrenceInPoolBalance / (stakebalance / 10 ** 18)) *
                    4;

                extraFourPercentReward = (extraFourPercentReward /
                    fourLakhsStakers);
            }
            if (oneMillionStakers > 0) {
                extraTenPercentReward =
                    (diffrenceInPoolBalance / (stakebalance / 10 ** 18)) *
                    10;

                extraTenPercentReward =
                    extraTenPercentReward /
                    oneMillionStakers;
            }
            normalReward =
                diffrenceInPoolBalance -
                ((extraFourPercentReward) + (extraTenPercentReward));

            normalReward = (normalReward / (stakebalance / 10 ** 18));
        }
        return (
            (normalReward),
            (extraFourPercentReward),
            (extraTenPercentReward)
        );
    }

    /**
    * @notice Transfers tokens to a specified address.
    * @dev This function is disabled in this contract and will always revert with an UnauthorizedTransfer error.
    * @param to The address to which the tokens will be transferred.
    * @param value The amount of tokens to be transferred.
    * @return Always reverts with an UnauthorizedTransfer error.
    */
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        revert UnauthorizedTransfer();
    }

    /**
    * @notice Transfers tokens from one address to another using an approved allowance.
    * @dev This function is disabled in this contract and will always revert with an UnauthorizedTransfer error.
    * @param from The address from which the tokens will be transferred.
    * @param to The address to which the tokens will be transferred.
    * @param value The amount of tokens to be transferred.
    * @return Always reverts with an UnauthorizedTransfer error.
    */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        revert UnauthorizedTransfer();
    }

  
    receive() external payable {}
}
