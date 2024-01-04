/**
 *Submitted for verification at testnet.bscscan.com on 2024-01-02
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * 
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  public{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin, 
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract CATCH is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) public _rOwned;
    mapping (address => uint256) public _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 90 * 10**6 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
   

    string private _name = "CATCH";
    string private _symbol = "CATCH";
    uint8 private _decimals = 18;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public _maxTxAmount = 1 * 10**6 * 10**18;
    uint256 private numTokensSellToAddToLiquidity = 5 * 10**5 * 10**18;

    //taxShare 
    uint256 refAmt;
    uint256 coinOperation;
    uint256 liquidty;
    uint256 burn;

    //coin operation wallet
    address public fundWallet;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    // event addLiquidit(uint256 tokenAmount,uint256 etherAmount);
    event thresholdUpdated(uint256 amount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

  /**
 * @dev Constructor function for initializing the contract.
 * @param _fundWallet The address of the wallet where funds will be managed.
 * 
 * Initializes the contract with the total supply allocated to the contract deployer.
 * Sets up the Uniswap pair and router for liquidity provision on the Ethereum network.
 * Excludes the owner and the contract itself from transaction fees.
 * 
 * @param _fundWallet The wallet address for managing funds and fees.
 * 
 * @notice This constructor is designed for deployment on the Ethereum network.
 * To deploy on the Binance Smart Chain Testnet, you may uncomment the appropriate Uniswap router address.
 * 
 * Emits a Transfer event representing the initial transfer of the total supply to the contract deployer.
 */
    
    constructor (address _fundWallet) public {
        _rOwned[_msgSender()] = _rTotal;
        fundWallet = _fundWallet;
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //BSC Testnet
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Ethereum
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

 /**
    * @notice Retrieves the name of the token.
    * @dev This function returns the name of the token, which is often used for identification.
    * It is commonly displayed in user interfaces and provides a human-readable name for the token.
    * @return The name of the token.
    */
    function name() public view returns (string memory) {
        return _name;
    }

  /**
    * @notice Retrieves the symbol or ticker of the token.
    * @dev This function returns the symbol or ticker that represents the token.
    * It is commonly used for identifying the token in user interfaces and exchanges.
    * @return The symbol or ticker of the token.
    */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

  /**
    * @notice Retrieves the number of decimal places used in the token representation.
    * @dev This function returns the number of decimal places used to represent the token balances.
    * It is commonly used to interpret the token amounts correctly in user interfaces.
    * @return The number of decimal places used in the token representation.
    */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

 /**
    * @notice Retrieves the total supply of tokens.
    * @dev This function returns the total supply of tokens in circulation.
    * @return The total supply of tokens.
    */
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

   /**
    * @notice Retrieves the token balance of a specified account.
    * @dev This function returns the token balance of the specified account.
    * If the account is excluded, it directly returns the token balance.
    * If the account is not excluded, it converts the reflection balance to token balance using the current rate.
    * @param account The address of the account whose token balance is being queried.
    * @return The token balance of the specified account.
    */
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];//exculded
        return tokenFromReflection(_rOwned[account]);//not excluded
    }

   /**
    * @notice Transfers a specified amount of tokens to a recipient.
    * @dev This function transfers tokens from the sender's account to the specified recipient.
    * If successful, it returns true.
    * @param recipient The address of the recipient to whom tokens are being transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating the success of the transfer operation.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
    * @notice Retrieves the remaining allowance for a spender to spend tokens on behalf of an owner.
    * @dev This function returns the current allowance set for the specified spender to spend tokens
    * from the specified owner's account.
    * @param owner The address of the owner whose allowance is being queried.
    * @param spender The address of the spender for whom the allowance is queried.
    * @return The remaining allowance for the specified spender to spend tokens on behalf of the owner.
    */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

  /**
    * @notice Approves a spender to spend a specified amount of tokens on behalf of the owner.
    * @dev This function sets or updates the allowance for a spender to spend tokens
    * from the owner's account. If successful, it returns true.
    * @param spender The address of the spender to be approved.
    * @param amount The amount of tokens to approve for spending.
    * @return A boolean indicating the success of the approval operation.
    */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

 /**
    * @notice Transfers tokens from one address to another on behalf of a third-party.
    * @dev This function allows a designated spender to transfer tokens from the sender's account
    * to the recipient's account. It also ensures that the allowance is updated correctly.
    * If successful, it returns true.
    * @param sender The address from which tokens are being transferred.
    * @param recipient The address to which tokens are being transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating the success of the transfer operation.
    */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

   /**
    * @notice Increases the allowance granted to a spender by a specified amount.
    * @dev This function increases the allowance for the specified spender by the given value.
    * It ensures that the updated allowance is correctly set. If successful, it returns true.
    * @param spender The address of the spender whose allowance is being increased.
    * @param addedValue The amount by which to increase the allowance.
    * @return A boolean indicating the success of the operation.
    */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

   /**
    * @notice Reduces the allowance granted to a spender by a specified amount.
    * @dev This function decreases the allowance for the specified spender by the given value.
    * It ensures that the allowance does not go below zero. If successful, it returns true.
    * @param spender The address of the spender whose allowance is being reduced.
    * @param subtractedValue The amount by which to reduce the allowance.
    * @return A boolean indicating the success of the operation.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

 /**
    * @notice Checks if the specified address is excluded from earning reflections.
    * @dev Excluded addresses do not receive reflections in certain tokenomics designs.
    * This function returns true if the address is excluded, and false otherwise.
    * @param account The address to check for exclusion from reflections.
    * @return A boolean indicating whether the address is excluded from earning reflections.
    */
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

 /**
    * @notice Retrieves the total amount of fees collected in tokens.
    * @dev This function returns the cumulative sum of fees collected during transactions.
    * The fees are often used for various purposes like liquidity provision, rewards, or burns.
    * @return The total amount of fees collected in tokens.
    */
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

 /**
    * @notice Distributes the specified amount of tokens as reflections to the reward pool.
    * @dev This function is typically used to convert a portion of tokens into reflections
    * and add them to a reward pool. Excluded addresses cannot call this function.
    * @param tAmount The amount of tokens to be converted and added to reflections.
    */
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,) = _getValue(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

       /**
    * @notice Converts the given token amount to its equivalent reflection amount.
    * @dev Reflections are often used in tokenomics to calculate rewards or balances.
    * This function converts a token amount to its corresponding reflection amount
    * based on the current rate. Optionally, it deducts the transfer fee from the calculation.
    * @param tAmount The token amount to be converted to reflections.
    * @param deductTransferFee A boolean indicating whether to deduct the transfer fee from the calculation.
    * @return The equivalent reflection amount corresponding to the given token amount.
    */

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,) = _getValue(tAmount);
             return rAmount;
        } else {
            (,uint256 rTransferAmount) = _getValue(tAmount);
             return rTransferAmount;
        }
    }

       /**
    * @notice Converts the given reflection amount to its equivalent token amount.
    * @dev Reflections are often used in tokenomics to calculate rewards or balances.
    * This function converts a reflection amount to its corresponding token amount
    * based on the current rate.
    * @param rAmount The reflection amount to be converted to tokens.
    * @return The equivalent token amount corresponding to the given reflection amount.
    */

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

  /**
    * @notice Grants the owner the ability to exclude an address from earning reflections.
    * @dev Reflections are often used in tokenomics to distribute rewards to holders.
    * This function excludes the specified address from receiving reflections.
    * @param account The address to be excluded from earning reflections.
    */
    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

/**
 * @dev External function for including an account in the reward distribution.
 * @param account The address to be included in the reward distribution.
 * 
 * The function can only be called by the owner of the contract.
 * Requires that the specified account is currently excluded.
 * Iterates through the list of excluded accounts, finds the specified account, and removes it from the exclusion list.
 * Resets the token balance of the specified account to 0 and updates the exclusion status.
 * 
 * @notice Only the owner of the contract can call this function.
 * @notice Requires that the specified account is currently excluded.
 */
    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    /**
 * @dev Internal function for transferring tokens between two excluded addresses.
 * @param sender The address from which the tokens are being sent.
 * @param recipient The address to which the tokens are being sent.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * Retrieves token values, including transfer amount, fees, and liquidity, and updates both token balances.
 * Takes liquidity and reflects fees based on specified values.
 * Emits a `Transfer` event with details about the transfer.
 * 
 * @param sender The sender's address.
 * @param recipient The recipient's address.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */
     function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCoinOperation, uint256 tBurn) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tCoinOperation, tBurn);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee, tBurn);
        _takeCoinFund(tCoinOperation);
        emit Transfer(sender, recipient, tTransferAmount);
    }

  /**
    * @notice Grants the owner the ability to exclude an address from transaction fees.
    * @dev Transaction fees are often applied in decentralized finance (DeFi) projects
    * to support various mechanisms like liquidity provision, rewards, or token burns.
    * @param account The address to exclude from transaction fees.
    */
     function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

     /**
    * @notice Grants the owner the ability to include an address in transaction fees.
    * @dev Transaction fees are often applied in decentralized finance (DeFi) projects
    * to support various mechanisms like liquidity provision, rewards, or token burns.
    * @param account The address to include in transaction fees.
    */
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
   
   /**
 * @dev External function for setting the maximum transaction percentage of the total supply.
 * @param maxTxPercent The new maximum transaction percentage to be set.
 * 
 * The function can only be called by the owner of the contract.
 * Calculates the new maximum transaction amount (_maxTxAmount) based on the provided percentage.
 * 
 * @notice Only the owner of the contract can call this function.
 */
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
    }                                                                                                                   

  /**
    * @notice Allows the owner to enable or disable the swap and liquify feature.
    * @dev The swap and liquify feature is a mechanism often used in decentralized finance (DeFi)
    * projects to automatically swap a portion of tokens for liquidity and add them to a liquidity pool.
    * @param _enabled A boolean indicating whether to enable (true) or disable (false) the feature.
    */
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

/**
 * @dev External function for updating the threshold amount required for triggering liquidity addition.
 * @param _amount The new threshold amount.
 * 
 * The function can only be called by the owner of the contract.
 * Requires that the provided threshold amount (_amount) is greater than 0.
 * Updates the numTokensSellToAddToLiquidity with the new threshold amount.
 * @notice Only the owner of the contract can call this function.
 * @notice Requires a positive _amount for successful execution.
 */
    //set numTokensSellToAddToLiquidity value
    function updateThreshold(uint256 _amount) external onlyOwner {
        require(_amount > 0,"amount is not valid");
        numTokensSellToAddToLiquidity = _amount;
        emit thresholdUpdated(_amount);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}


/**
 * @dev Private function for reflecting fees in the total supply and fee tracking variables.
 * @param rFee The reflection equivalent of the fee amount.
 * @param tFee The actual fee amount in tokens.
 * @param tBurn The amount of tokens designated for burning.
 * 
 * Calls the internal `_getRate` function to get the current conversion rate.
 * Calculates the reflection equivalent of the burn amount using the current rate.
 * Updates the total reflection supply by subtracting the reflection fees and burn reflection.
 * Updates the total fee tracking variable by adding the actual fee amount.
 * Updates the total token supply by subtracting the burn amount.
 * 
 * @notice Internal use only.
 */
    function _reflectFee(uint256 rFee, uint256 tFee, uint256 tBurn) private {
         uint256 currentRate = _getRate();
         uint256 rBurn = tBurn.mul(currentRate);
     
        _rTotal = _rTotal.sub(rFee).sub(rBurn);
        _tFeeTotal = _tFeeTotal.add(tFee);

        _tTotal = _tTotal.sub(tBurn);
        
    }


/**
 * @dev Private function for transferring tokens designated for coin operations to a specified wallet.
 * @param tCoinOperation The amount of tokens designated for coin operations.
 * 
 * Calls the internal `_getRate` function to get the current conversion rate.
 * Calculates the reflection equivalent of the token amount for coin operations using the current rate.
 * Transfers the reflection equivalent to the specified wallet for coin operations.
 * 
 * @param tCoinOperation The amount of tokens designated for coin operations.
 * 
 * @notice Internal use only.
 */
       function _takeCoinFund(uint256 tCoinOperation) private {
           uint256 currentRate =  _getRate();
        uint256 rCoinOperation = tCoinOperation.mul(currentRate);
        _rOwned[fundWallet] = _rOwned[fundWallet].add(rCoinOperation);
        if(_isExcluded[fundWallet])
            _tOwned[fundWallet] = _tOwned[fundWallet].add(tCoinOperation);
    }

   /**
 * @dev Private function for calculating various token values based on a specified total token amount.
 * @param tAmount The total amount of tokens in the transaction.
 * @return tTransferAmount The token amount after deducting fees.
 * @return tFee The amount of tokens designated for fees.
 * @return tLiquidity The amount of tokens designated for liquidity.
 * @return tCoinOperation The amount of tokens designated for coin operations.
 * @return tBurn The amount of tokens designated for burning.
 * 
 * Calls the internal `_getTValues` function to calculate token values for fees, liquidity, coin operation, and burning.
 * 
 * @notice Internal use only.
 */

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCoinOperation, uint256 tBurn) = _getTValues(tAmount); 
        return ( tTransferAmount, tFee, tLiquidity, tCoinOperation, tBurn);
    }

/**
 * @dev Private function for calculating both reflection and transfer amounts based on a specified total token amount.
 * @param tAmount The total amount of tokens in the transaction.
 * @return rAmount Reflection equivalent of the total token amount.
 * @return rTransferAmount Reflection equivalent of the transfer amount (after deducting fees).
 * 
 * Calls the internal functions to calculate token values for fees, liquidity, coin operation, and burning.
 * Utilizes the calculated values to get both reflection and transfer amounts.
 * 
 * @notice Internal use only.
 */
    function _getValue(uint256 tAmount) private view returns(uint256, uint256){
        (, uint256 tFee, uint256 tLiquidity, uint256 tCoinOperation, uint256 tBurn) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount,) = _getRValues(tAmount, tFee, tLiquidity, tCoinOperation, tBurn);
         return (rAmount, rTransferAmount);

    }

/**
 * @dev Private function for calculating token values based on a specified total token amount.
 * @param tAmount The total amount of tokens in the transaction.
 * @return tTransferAmount The token amount after deducting fees.
 * @return tFee The amount of tokens designated for fees.
 * @return tLiquidity The amount of tokens designated for liquidity.
 * @return tCoinOperation The amount of tokens designated for coin operations.
 * @return tBurn The amount of tokens designated for burning.
 * 
 * Calls the internal functions to calculate fees for tax, liquidity, coin operation, and burning.
 * Calculates the total fee amount and deducts it from the total token amount to get the transfer amount.
 * 
 * @notice Internal use only.
 */
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tCoinOperation = calculateCoinOperartionTax(tAmount);
        uint256 tBurn = calculateBurnTax(tAmount);
        uint256 allTax = tFee+tLiquidity+tCoinOperation+tBurn;
        uint256 tTransferAmount = tAmount.sub(allTax);
        return (tTransferAmount, tFee, tLiquidity, tCoinOperation, tBurn);
    }

/**
 * @dev Private function for calculating reflection values based on specified token amounts.
 * @param tAmount The total amount of tokens in the transaction.
 * @param tFee The amount of tokens designated for fees.
 * @param tLiquidity The amount of tokens designated for liquidity.
 * @param tCoinOperation The amount of tokens designated for coin operations.
 * @param tBurn The amount of tokens designated for burning.
 * @return rAmount Reflection equivalent of the total token amount.
 * @return rTransferAmount Reflection equivalent of the transfer amount (after deducting fees).
 * @return rFee Reflection equivalent of the fee amount.
 * 
 * Calls the internal `_getRate` function to get the current conversion rate.
 * Calculates reflection values for the total amount, transfer amount, and fees by multiplying token amounts with the rate.
 * 
 * @notice Internal use only.
 */
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tCoinOperation, uint256 tBurn) private view returns (uint256, uint256, uint256) {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rCoinOperation = tCoinOperation.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 allTax = rFee+rCoinOperation+rBurn+rLiquidity;
        uint256 rTransferAmount = rAmount.sub(allTax);
        return (rAmount, rTransferAmount, rFee);
    }

/**
 * @dev Private function for retrieving the current conversion rate between reflection and token balances.
 * @return rate Current conversion rate.
 * 
 * @notice Internal use only.
 */
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

/**
 * @dev Private function for retrieving the current supply of both reflection and token balances.
 * @return rSupply Current reflection supply.
 * @return tSupply Current token supply.
 * 
 * @notice Internal use only.
 */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    /**
 * @dev Private function for handling the transfer of liquidity to the contract.
 * @param tLiquidity The amount of liquidity tokens to be taken.
 * 
 * @notice Internal use only.
 */
    function _takeLiquidity(uint256 tLiquidity) private {
           uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

/**
 * @dev Calculates the tax fee for reflection based on a specified amount.
 * @param _amount Amount for tax fee calculation.
 * @return Calculated tax fee amount.
 * 
 * @notice Internal use only.
 */
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(refAmt).div(
            10**2
        );
    }

/**
 * @dev Calculates the liquidity fee based on a specified amount.
 * @param _amount Amount for liquidity fee calculation.
 * @return Calculated liquidity fee amount.
 * 
 * @notice Internal use only.
 */
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(liquidty).div(
            10**2
        );
    }

    /**
 * @dev Calculates the coin operation tax based on a specified amount.
 * @param _amount Amount for coin operation tax calculation.
 * @return Calculated coin operation tax amount.
 * 
 * @notice Internal use only.
 */

        function calculateCoinOperartionTax(uint256 _amount) private view returns (uint256) {
        return _amount.mul(coinOperation).div(
            10**2
        );
    }

 /*
 * @dev Calculates the burn tax based on a specified amount.
 * @param _amount Amount for burn tax calculation.
 * @return Calculated burn tax amount.
 * 
 * Multiplies the amount by the burn percentage and divides by 100.
 * 
 * @param _amount The amount for burn tax calculation.
 * @return Calculated burn tax amount.
 * 
 * @notice Internal use only.
 */
    function calculateBurnTax(uint256 _amount) private view returns (uint256) {
        return _amount.mul(burn).div(
            10**2
        );
    }
    
    /**
 * @dev Private function for removing all fee values.
 * 
 * Sets all fee values (refAmt, coinOperation, liquidity, burn) to zero.
 * This function is typically used to temporarily disable fees during specific operations.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */

    function removeAllFee() private {
         refAmt =   0;
            coinOperation = 0;
            liquidty = 0;
            burn = 0;  
    }
    
  
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

 /**
 * @dev Private function for approving a spender to spend a certain amount on behalf of the owner.
 * @param owner The address that owns the tokens.
 * @param spender The address that is approved to spend the tokens.
 * @param amount The amount of tokens to be approved for spending.
 * 
 * Requires that both the owner and spender addresses are not the zero address.
 * Sets the allowance for the spender on behalf of the owner to the specified amount.
 * Emits an `Approval` event with details about the approval.
 * 
 * @param owner The address that owns the tokens.
 * @param spender The address that is approved to spend the tokens.
 * @param amount The amount of tokens to be approved for spending.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
 * @dev Internal function for transferring tokens between addresses.
 * @param from The address from which the tokens are transferred.
 * @param to The address to which the tokens are transferred.
 * @param amount The amount of tokens to be transferred.
 * 
 * Requirements:
 * - `from` cannot be the zero address.
 * - `to` cannot be the zero address.
 * - `amount` must be greater than zero.
 * - If neither `from` nor `to` is the owner, the transfer amount must not exceed the max transaction amount.
 * 
 * @param from The sender's address.
 * @param to The recipient's address.
 * @param amount The amount of tokens to be transferred.
 * 
 * Emits a `Transfer` event indicating the transfer of tokens from one address to another.
 * 
 * Manages fees, including tax, burn, and liquidity fee, based on specified conditions.
 * If the transfer triggers the conditions for liquidity provision, it swaps and adds liquidity.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */

    function _transfer( address from, address to, uint256 amount ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner())
        require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //if takeFee is true then set set or buy tax share percentage
        if(takeFee)
        _sellBuyTax(from,to);
        //transfer amount, it will take tax, burn, liquidity fee
        

      _tokenTransfer(from,to,amount,takeFee);
    }


/**
 * @dev Internal function for setting buy or sell tax shares based on transaction details.
 * @param from The address from which the tokens are being sent.
 * @param to The address to which the tokens are being sent.
 * 
 * Sets tax shares for buy and sell transactions, including referral amount, coin operation fee,
 * liquidity fee, and burn fee, based on specified percentages.
 * 
 * @param from The sender's address.
 * @param to The recipient's address.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */
    ///set buy or sell tax
      function _sellBuyTax(address from, address to) private {
           //sell and buy logic
        bool isBuy = from == uniswapV2Pair;
        bool isSell = to == uniswapV2Pair;
        
        //buy tax share
        uint256 buyRefAmt=1;
        uint256 buyCoinOperation=1;
        uint256 buyLiquidity=1;
        uint256 buyBurn=0;

        //sell tax share
        uint256 sellRefAmt =2;
        uint256 sellCoin=1;
        uint256 sellLiq =2;
        uint256 sellBurn =1;

            if (isBuy) {    
            refAmt =   buyRefAmt; //1 %
            coinOperation = buyCoinOperation; //1 %
            liquidty = buyLiquidity; //1 %
            burn = buyBurn; //0%
 
            } 
            else if (isSell) {
            refAmt =   sellRefAmt; //2%
            coinOperation = sellCoin; //1%
            liquidty = sellLiq; //2%
            burn = sellBurn;   //1%
               
            }
    } 


/**
 * @dev Private function for performing token swap and liquidity addition on the Uniswap V2 router.
 * @param contractTokenBalance The balance of tokens in the contract to be used for the swap and liquidity.
 * 
 * Splits the contract token balance into halves, swaps one half for ETH, captures the ETH balance,
 * and adds liquidity with the other half. Emits a `SwapAndLiquify` event with details about the swap and liquidity addition.
 * 
 * @param contractTokenBalance The balance of tokens in the contract to be used for the swap and liquidity.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

/**
 * @dev Private function for swapping tokens for ETH on the Uniswap V2 router.
 * @param tokenAmount The amount of tokens to be swapped for ETH.
 * 
 * Generates the Uniswap pair path of token -> WETH and approves token transfer to the Uniswap V2 router.
 * Makes the token-to-ETH swap using the Uniswap V2 router's `swapExactTokensForETHSupportingFeeOnTransferTokens` function.
 * 
 * @param tokenAmount The amount of tokens to be swapped for ETH.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

/**
 * @dev Private function for adding liquidity to the Uniswap V2 router.
 * @param tokenAmount The amount of tokens to be added to the liquidity pool.
 * @param ethAmount The amount of ETH to be added to the liquidity pool.
 * 
 * Approves token transfer to the Uniswap V2 router and adds liquidity with specified amounts.
 * Uses the Uniswap V2 router's `addLiquidityETH` function, specifying the token address, token amount,
 * slippage tolerance, and other parameters.
 * 
 * @param tokenAmount The amount of tokens to be added to the liquidity pool.
 * @param ethAmount The amount of ETH to be added to the liquidity pool.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */

 
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }


/**
 * @dev Internal function for transferring tokens between addresses, applying fees if specified.
 * @param sender The address from which the tokens are being sent.
 * @param recipient The address to which the tokens are being received.
 * @param amount The amount of tokens to be transferred.
 * @param takeFee A boolean indicating whether fees should be applied.
 * 
 * If `takeFee` is false, all fees are removed for the current transfer.
 * Determines the transfer scenario (standard, to/from excluded), and calls the appropriate transfer function accordingly.
 * 
 * @param sender The sender's address.
 * @param recipient The recipient's address.
 * @param amount The amount of tokens to be transferred.
 * @param takeFee A boolean indicating whether fees should be applied.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */
    ///this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
          if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
      
    }

    /**
 * @dev Internal function for transferring tokens between two non-excluded addresses.
 * @param sender The address from which the tokens are being sent.
 * @param recipient The address to which the tokens are being sent.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * Retrieves token values, including transfer amount, fees, and liquidity, and updates reflection balances.
 * Takes liquidity and reflects fees based on specified values.
 * Emits a `Transfer` event with details about the transfer.
 * 
 * @param sender The sender's address.
 * @param recipient The recipient's address.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCoinOperation, uint256 tBurn) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tCoinOperation, tBurn);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee, tBurn);
        _takeCoinFund(tCoinOperation);
        emit Transfer(sender, recipient, tTransferAmount);
    }


/**
 * @dev Internal function for transferring tokens from a non-excluded address to an excluded address.
 * @param sender The address from which the tokens are being sent.
 * @param recipient The address to which the tokens are being sent.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * Retrieves token values, including transfer amount, fees, and liquidity, and updates both token and reflection balances.
 * Takes liquidity and reflects fees based on specified values.
 * Emits a `Transfer` event with details about the transfer.
 * 
 * @param sender The sender's address.
 * @param recipient The recipient's address.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCoinOperation, uint256 tBurn) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tCoinOperation, tBurn);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee, tBurn);
        _takeCoinFund(tCoinOperation);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
 * @dev Internal function for transferring tokens from an excluded address to a non-excluded address.
 * @param sender The address from which the tokens are being sent.
 * @param recipient The address to which the tokens are being sent.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * Retrieves token values, including transfer amount, fees, and liquidity, and updates both token and reflection balances.
 * Takes liquidity and reflects fees based on specified values.
 * Emits a `Transfer` event with details about the transfer.
 * 
 * @param sender The sender's address.
 * @param recipient The recipient's address.
 * @param tAmount The amount of tokens to be transferred.
 * 
 * @notice This function is intended for internal use and should not be called directly.
 */

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCoinOperation, uint256 tBurn) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tCoinOperation, tBurn);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee, tBurn);
        _takeCoinFund(tCoinOperation);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}
