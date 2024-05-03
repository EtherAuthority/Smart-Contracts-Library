// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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
     * Returns a boolean value indicating whether the operation succeeded
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

/**
 * @title IRouter01
 * @dev Interface for the  Router version 01 contract.
*/  
interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
        ) external returns (uint amountToken, uint amountETH);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract Presale is Ownable {

    address public immutable WETH;
    address public immutable USDT;
    address public immutable USDC;
    address public immutable DAI;
    IRouter01 private immutable _uniSwapRouter;

    address public paymentWallet;
    
    
    uint256 public currentPrice=300;// $0.0003 * 10**6
    uint256 public lastPriceUpdateTime;
    uint256 private constant PRICEINCREMENT = 1; // $0.000001 * 10**6
 
    mapping(address => bool) public approvedContracts; // Mapping to track approved contract addresses

    //-----------------------EVENTS-------------------
    event TokensBoughtWithEth(address buyer, uint256 ethAmount, uint256 ethPrice, uint256 tokenPrice, uint256 numOfTokens, uint256 timestamp);
    event BoughtWithTokens(address buyer, uint256 usdtAmount, uint256 tokenPrice, uint256 numOfTokens, uint256 timestamp);
    event UpdatePaymentWallet(address newPaymentWallet);
    event ContractApproved(address contractAddress, bool approved);
    event ChangePrice(uint256 currentPrice);   
    event PriceUpdated(uint256 newPrice);

    /**
     * @dev Constructor to initialize the contract with required addresses and settings.
     * @param _payment The address of the payment wallet.
     */
    constructor(address _payment){
        paymentWallet = _payment;
        WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Bsc Mainnet
        USDT = 0x55d398326f99059fF775485246999027B3197955;
        USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; 
        DAI = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;  
        _uniSwapRouter = IRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        lastPriceUpdateTime = block.timestamp;
        
        approvedContracts[USDT] = true;
        approvedContracts[USDC] = true;
        approvedContracts[DAI] = true;
    }

    /**
     * @dev Admin function to approve a contract for buying tokens.
     * @param contractAddress Address of the contract to approve.
     * @param approved Boolean indicating whether to approve or revoke approval.
     */
    function approveContract(address contractAddress, bool approved) external onlyOwner {
        require(contractAddress != address(0), "Address cannot be zero");
        approvedContracts[contractAddress] = approved;
        emit ContractApproved(contractAddress, approved);
    }

    /**
     * @notice Allows users to buy tokens using any ERC20 token.
     * @dev Transfers the specified amount of tokens from the caller to the payment wallet using SafeERC20.
     * @param amount The amount of tokens to transfer.
     * @param token The address of the ERC20 token contract.
     * @return A boolean indicating whether the transaction was successful.
     */
    function buyWithToken(uint256 amount, address token) external returns (bool) {
       require(approvedContracts[token], "Contract not approved for buying tokens"); 
       require(token != address(0), "Address cannot be zero");
       IERC20 tokenContract = IERC20(token);
       uint256 numOfToken;
       uint256 decimalPoint;
       decimalPoint = tokenContract.decimals();
       uint256 currentTokenPrice = updateTokenPrice();
       numOfToken = (amount *10**6 )  / ( currentTokenPrice *10**decimalPoint);
       SafeERC20.safeTransferFrom(tokenContract, msg.sender,paymentWallet, amount);
       emit BoughtWithTokens(_msgSender(), amount,currentTokenPrice,numOfToken,block.timestamp);
       return true;
    }
 
    /**
     * @notice Allows users to buy tokens using Ether.
     * @dev Requires that Ether is sent along with the transaction. Transfers the received Ether to the payment wallet.
     * @return A boolean indicating whether the transaction was successful.
     */
    function buyWithEth() external payable  returns (bool) {
        require(msg.value > 0, "No ETH sent");
        uint256 latestETHPrice = getLatestEthPrice(msg.value);
        uint256 currentTokenPrice = updateTokenPrice();
        uint256 numOfToken =  latestETHPrice / updateTokenPrice();
        payable(paymentWallet).transfer(msg.value);
        emit TokensBoughtWithEth(_msgSender(), msg.value, latestETHPrice ,currentTokenPrice, numOfToken,  block.timestamp);
        return true;
    }

    /**
     * @dev Updates the token price based on the time passed since the last update.
     * @return The updated token price.
     */
    function updateTokenPrice() internal  returns(uint256){
        uint256 daysPassed = (block.timestamp - lastPriceUpdateTime) / 1 days;
        if (daysPassed >= 1) {
            uint256 newPrice = currentPrice + (daysPassed * PRICEINCREMENT);
            currentPrice = newPrice;
            lastPriceUpdateTime = block.timestamp;
        }
        emit PriceUpdated(currentPrice);
        return currentPrice;
    }

    /**
     * @notice Allows the contract owner to change the current token price.
     * @dev Can only be called by the owner of the contract.
     * @param _currentPrice The new token price to set.
     */
    function changePrice(uint256 _currentPrice) external onlyOwner {
        currentPrice = _currentPrice;
        emit ChangePrice(currentPrice);
    }

    /**
     * @notice Allows the contract owner to change the payment wallet address.
     * @dev Can only be called by the owner of the contract.
     * @param _newPaymentWallet The new payment wallet address to set.
     */
    function changePaymentWallet(address _newPaymentWallet) external onlyOwner {
        require(_newPaymentWallet != address(0),"Address can not be zero");
        paymentWallet = _newPaymentWallet;
        emit UpdatePaymentWallet(paymentWallet);
    }
    
    /**
     * @notice Gets the latest price of Ether in terms of USDT.
     * @param ethAmt The amount of Ether for which to get the price.
     * @return The latest price of Ether in USDT.
     */
    function getLatestEthPrice(uint ethAmt) internal view returns (uint){

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = USDT;
     
        uint[] memory amounts = _uniSwapRouter.getAmountsOut(ethAmt, path);
         
        return amounts[1]; // Return the price at index
    }

    /**
     * @dev Withdraws a specified amount of tokens from a token contract to the owner's address.
     * @param tokenContractAddress The address of the token contract.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawToken(address tokenContractAddress, uint256 amount) external onlyOwner {
        IERC20 tokenContract = IERC20(tokenContractAddress);
        SafeERC20.safeTransfer(tokenContract, msg.sender, amount);
    }

    /**
     * @dev Withdraws a specified amount of native tokens (ETH or BNB) to the owner's address.
     * @param amount The amount of native tokens to withdraw.
     */
    function withdrawNative(uint256 amount) external onlyOwner {
        require(address(this).balance > 0,"Not sufficient balance");
        payable(msg.sender).transfer(amount);
    }
    
    receive() external payable {}
}