// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)


/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Treasury is Ownable {
    using Address for address;
    using Address for address payable;
    using Address for IERC20;
    using SafeERC20 for IERC20;
    

    string public MEME;

    IERC20 public XDC;

    uint256 public userCount;
    uint256 public MAX_USER_LIMIT = 500000;

    
    uint256 public MaintainenceFee;
    uint256 public DeadFee;
    uint256 public FirstWinnerShare = 1000;     /*10%*/
    uint256 public SecondWinnerShare = 500;     /*5%*/
    uint256 public ThirdWinnerShare = 250;      /*2.5%*/
    uint256 public constant PERCENT_DIVIDER = 1e4;
    uint256 public RewardDistributionTimesThreshold;

    address public MaintainenceWallet;
    address public DeadWallet;
    address public Signer;

    address internal FirstWinner;
    address internal SecondWinner;
    address internal ThirdWinner;
    
    uint256 public totalDeposit;
    uint256 public rewardPool;
    uint256 public rewardPoolCheckpoint;

    struct data {
        uint256 _amount;
        uint256 _index;
        uint256 totalWithdrawals;
        uint256 totalWithdrawables;
    }
    mapping(address => data) public userRecord;
    mapping (address => uint256) public UserToId; 
    mapping (uint256 => address) public IdToUser;
    address[] public users;

    event Deposit(address indexed MadeBy, uint256 indexed ForAmount, uint256 indexed LeftAfterTax);
    event Withdraw(address indexed DoneBy, uint256 indexed OfAmount);
    event SignerChanged(address indexed PreviousSigner, address indexed NewSigner);
    event MaintainenceWalletChanged(address indexed PreviousWallet, address indexed NewWallet);
    event DeadWalletChanged(address indexed PreviousWallet, address indexed NewWallet);
    event MaintainenceFeeChanged(uint256 indexed PreviousFee, uint256 indexed NewFee);
    event DeadFeeChanged(uint256 indexed PreviousFee, uint256 indexed NewFee);
    event TokenChanged(address indexed PreviousToken, address indexed NewToken);
    event MemeChanged(string indexed previousMeme, string indexed newMeme);
    event RewardDistributionTimesThresholdChanged(uint256 indexed OldThreshold, uint256 indexed NewThreshold);
    event FirstWinnerShareChanged(uint256 indexed PreviousShare, uint256 indexed NewShare);
    event SecondWinnerShareChanged(uint256 indexed PreviousShare, uint256 indexed NewShare);
    event ThirdWinnerShareChanged(uint256 indexed PreviousShare, uint256 indexed NewShare);
    event MaxUserLimitChanged(uint256 indexed PreviousUserLimit, uint256 indexed NewUserLimit);

    modifier onlySigner(){
        require(_msgSender() == Signer, "error: Not Signer");
        _;
    }

    constructor(address _token, address _signer) {
        require(_token != address(0) && _token.isContract(), "error: Invalid token address");
        require(_signer != address(0), "error: Zero Value");
        XDC = IERC20(_token); 
        emit TokenChanged(address(0), _token);
        Signer = _signer;
        emit SignerChanged(address(0), Signer);
        MaintainenceFee = 400;
        emit MaintainenceFeeChanged(0, MaintainenceFee);
        DeadFee = 3000;
        emit DeadFeeChanged(0, DeadFee);
        RewardDistributionTimesThreshold = 3000; /* upto 3000 users*/
    }
    
    function deposit(uint _amount) external {

        require(_amount > 0,"Error: Invalid Amount");

        address _to = msg.sender;
        uint256 currentLength = users.length;
        createUserIdList(_to);

        uint256 beforeTokenBalance = XDC.balanceOf(address(this));
        XDC.safeTransferFrom(_to, address(this), _amount);
        uint256 afterTokenBalance = XDC.balanceOf(address(this));

        _amount = afterTokenBalance - beforeTokenBalance;

        if (userRecord[_to]._amount == 0) {
            maxUserChecker();
            userRecord[_to] = data({
                _amount: 0,
                _index: currentLength,
                totalWithdrawals: 0,
                totalWithdrawables: 0 
            });
            users.push(_to);
            userCount++;
        }

        userRecord[_to]._amount += _amount;
        totalDeposit = totalDeposit + _amount;
        
        uint256 _afterTax = deductTax(_amount);
        rewardPool += _afterTax;
        emit Deposit(_to, _amount, _afterTax);      

    }

    function deductTax(uint256 _beforeTax) internal returns(uint256 _afterTax){
        /*4% goes to Maintainence Wallet*/
        uint256 toMaintainence = (_beforeTax * MaintainenceFee) / PERCENT_DIVIDER;
        XDC.safeTransfer(MaintainenceWallet, toMaintainence);

        /*30% goes to Dead Wallet*/
        uint256 toDead = (_beforeTax * DeadFee) / PERCENT_DIVIDER;
        XDC.safeTransfer(DeadWallet, toDead);
        
        _afterTax = _beforeTax - (toMaintainence + toDead);
    }

    function maxUserChecker() internal view {
        if(userCount + 1 > MAX_USER_LIMIT) {
            revert("Error: Max User Limit Exceeded!!");
        }
    }

    function settleRewardDistribution() external onlySigner {

        /* Call this function to settle rewards, 
        Loop will run upto a maximum for the value of RewardDistributionTimesThreshold(can be set by owner)*/

        uint256 userLength = users.length;
        if(userLength > RewardDistributionTimesThreshold){
            userLength = RewardDistributionTimesThreshold;
        }
        require(userLength > 4, "revert: not enough users");
        
        uint256 lot = rewardPool - rewardPoolCheckpoint;
        require(lot > 0, "revert: not enough deposits to distribute");

        uint256 tAmount;
        uint256 topWinnerAmounts;

        for(uint256 count;count < userLength;count++){
            if(count == 0) {tAmount = (lot * FirstWinnerShare) / PERCENT_DIVIDER; topWinnerAmounts += tAmount;}
            else if(count == 1) {tAmount = (lot * SecondWinnerShare) / PERCENT_DIVIDER; topWinnerAmounts += tAmount;}
            else if(count == 2) {tAmount = (lot * ThirdWinnerShare) / PERCENT_DIVIDER; topWinnerAmounts += tAmount;}
            else {
                uint256 remaining = userLength - count;
                tAmount = (lot - topWinnerAmounts) / remaining;
                
            }
            address randomPicked = randomPicker(userLength);
            updateUserReward(randomPicked, tAmount);
        }
        rewardPoolCheckpoint = rewardPool;
    }

    function getUserLength() external view returns(uint256 length) {
        length = users.length;
    }

    function getTopThreeWinner() external view returns(address _first, address _second, address _third) {
        _first = FirstWinner;
        _second = SecondWinner;
        _third = ThirdWinner;
    }

    function updateUserReward(address _user, uint256 _reward) internal returns(uint256 rewardAfterUpdate){
        userRecord[_user].totalWithdrawables += _reward;
        rewardAfterUpdate = userRecord[_user].totalWithdrawables;
    }

    function withdraw() external returns(uint256 claimed) {
        address owner = _msgSender();
        uint256 rewards = userRecord[owner].totalWithdrawables;
        
        
        if(XDC.balanceOf(address(this)) < rewards){
            rewards = XDC.balanceOf(address(this));
        }
        userRecord[owner].totalWithdrawables -= rewards;
        userRecord[owner].totalWithdrawals += rewards;

        XDC.safeTransfer(owner, rewards);
        emit Withdraw(owner, rewards);
        claimed = rewards;
    }

    /*
    * Get random user*/
    function randomPicker(uint256 limit) onlySigner internal view returns(address _randomlyPicked) {
        uint256 randomId = randomNumberGenerator(limit);
        _randomlyPicked = IdToUser[randomId];
    }

    /*
    * Create user id list*/
    function createUserIdList(address userAddress) internal{
        uint256 userId = UserToId[userAddress];
        uint256 incr = userCount + 1;
        if(userId == 0){
            UserToId[userAddress] = incr;
            IdToUser[incr] = userAddress;
        }
    }

    /*
    *   Cool random user generator*/
    function randomNumberGenerator(uint256 _upto) internal view returns(uint256){
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        uint256 randomNumber = seed - ((seed * _upto) / _upto);
        if(randomNumber == 0){
            randomNumber++;
        }
        return randomNumber;
    }

    /*
    *    These Function are for emergency senarios
    */

    

   

    function setMaxUserLimit(uint _newLimit) external onlyOwner {
        require(_newLimit > 0, "error: zero value");
        uint256 previousLimit = MAX_USER_LIMIT;
        MAX_USER_LIMIT = _newLimit;
        emit MaxUserLimitChanged(previousLimit, MAX_USER_LIMIT);
    }

    function setMaintainenceFee(uint256 _fee) external onlyOwner returns(uint256 _maintainenceFee){
        require(_fee > 0, "error: zero value");
        require(_fee + DeadFee <= PERCENT_DIVIDER, "error: Sum of all fees exceed denominator");
        uint256 previousFee = MaintainenceFee;
        MaintainenceFee = _fee;
        emit MaintainenceFeeChanged(previousFee, MaintainenceFee);
        _maintainenceFee = MaintainenceFee;
    }
    function setDeadWalletFee(uint256 _fee) external onlyOwner returns(uint256 _deadFee){
        require(_fee > 0, "error: zero value");
        require(MaintainenceFee + _fee <= PERCENT_DIVIDER, "error: Sum of all fees exceed denominator");
        uint256 previousFee = DeadFee;
        DeadFee = _fee;
        emit DeadFeeChanged(previousFee, DeadFee);
        _deadFee = DeadFee;
    }
    
    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "error: zero address");
        require(_token.isContract(), "error: Token mmust be a contract");
        XDC = IERC20(_token);
        emit TokenChanged(address(XDC), _token);
    }

    function setSigner(address _address) external onlyOwner returns(address _signer) {
        require(_address != address(0), "error: zero address");
        address previousSigner = Signer;
        Signer = _address;
        emit SignerChanged(previousSigner, Signer);
        _signer = Signer;
    }

    function setMaintainenceWallet(address _address) external onlyOwner returns(address maintainence){
        require(_address != address(0), "error: zero address");
        address previousWallet = MaintainenceWallet;
        MaintainenceWallet = _address;
        emit MaintainenceWalletChanged(previousWallet, MaintainenceWallet);
        maintainence = MaintainenceWallet;
    }

    function setDeadWallet(address _address) external onlyOwner returns(address deadWallet) {
        require(_address != address(0), "error: zero address");
        address previousWallet = DeadWallet;
        DeadWallet = _address;
        emit DeadWalletChanged(previousWallet, DeadWallet);
        deadWallet = DeadWallet;
    }

    function setmem(string memory _str) external onlyOwner returns(string memory _newMeme){
        string memory previousMeme = MEME;
        MEME = _str;
        emit MemeChanged(previousMeme, MEME);
        _newMeme = MEME;
    }

    function setRewardDistributionTimesThreshold(uint256 newValue) external onlyOwner returns(uint256 newThreshold){
        /* Sets upto how many user rewards should be distrubuted*/
        uint256 previousThreshold = RewardDistributionTimesThreshold;
        require(newValue != 0, "revert: Zero Value");
        require(previousThreshold != newValue, "revert: Same Value");
        RewardDistributionTimesThreshold = newValue;
        emit RewardDistributionTimesThresholdChanged(previousThreshold, newThreshold);
        newThreshold = RewardDistributionTimesThreshold;
    }

    function setFirstWinnerShare(uint256 newValue) external onlyOwner returns(uint256 newShare){
        require(newValue > 0, "error: zero value");
        require(SecondWinnerShare + ThirdWinnerShare + newValue <= PERCENT_DIVIDER, "error: Sum of all fees exceed denominator");
        uint256 previousShare = FirstWinnerShare;
        FirstWinnerShare = newValue;
        emit FirstWinnerShareChanged(previousShare, FirstWinnerShare);
        newShare = FirstWinnerShare;
    }

    function setSecondWinnerShare(uint256 newValue) external onlyOwner returns(uint256 newShare){
        require(newValue > 0, "error: zero value");
        require(FirstWinnerShare + ThirdWinnerShare + newValue <= PERCENT_DIVIDER, "error: Sum of all fees exceed denominator");
        uint256 previousShare = SecondWinnerShare;
        SecondWinnerShare = newValue;
        emit SecondWinnerShareChanged(previousShare, SecondWinnerShare);
        newShare = SecondWinnerShare;
    }

    function setThirdWinnerShare(uint256 newValue) external onlyOwner returns(uint256 newShare){
        require(newValue > 0, "error: zero value");
        require(SecondWinnerShare + FirstWinnerShare + newValue <= PERCENT_DIVIDER, "error: Sum of all fees exceed denominator");
        uint256 previousShare = ThirdWinnerShare;
        ThirdWinnerShare = newValue;
        emit ThirdWinnerShareChanged(previousShare, ThirdWinnerShare);
        newShare = ThirdWinnerShare;
    }

}
