// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
 
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
    function renounceOwnership() external  virtual onlyOwner {
        _transferOwnership(address(0));
    }
 
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
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
 
/**
 * @dev Interface of the ERC-20 standard
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
 
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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
 
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

/**
 * @title IUniswapV2Factory
 * @dev Interface for the Uniswap V2 Factory contract.
 */  
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
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

/**
 * @title IUniswapV2Router02
 * @dev Interface for the Uniswap V2 Router version 02 contract.
 */  
interface IUniswapV2Router02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}
 
contract MTBCoin is Ownable {
 
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
 
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
 
    address public constant TREASURYWALLET=0x2841E6DFE43527Fa071C2A2EecED1D54FA91c189;
    uint256 public constant TAX = 2;        
    IUniswapV2Router02 public immutable uniswapV2Router;
    address private immutable _uniswapPair;

    // Emitted when `value` tokens are moved from one account (`from`) to
     event Transfer(address indexed from, address indexed to, uint256 value);
 
    // Emitted when the allowance of a `spender` for an `owner` is set by
     event Approval(address indexed owner, address indexed spender, uint256 value);  
 
    /**
     * @dev Constructor function to initialize the contract.
     * This constructor sets up the initial token distribution, initializes the Uniswap router, 
     * creates a Uniswap pair for the token, approves unlimited token transfer to and from the Uniswap router
     */
    constructor() {

        name = "MTBCoin";
        symbol = "MTBC";
        decimals = 18;
        totalSupply = 2000* 10**6 *10**uint256(decimals);
        _balances[msg.sender] = totalSupply;
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            // 0x9fa6182C041c52b714d8b402C4e358881a53067d // SCAI MAINNET
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //BSC Testnet 
        );

        uniswapV2Router = _uniswapV2Router;
        _uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
 
        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
 
        emit Transfer(address(0), msg.sender, totalSupply);
    }
 
    /**
     * @dev Returns the balance of the specified account.
     * This function retrieves and returns the balance of the specified account.
     * @param account The address for which to retrieve the balance.
     * @return uint256 representing the balance of the specified account.
     */
    function balanceOf(address account) external  view virtual  returns (uint256) {
        return _balances[account];
    }
 
    /**
     * @dev Transfers tokens from the sender's account to the specified recipient.
     * Moves `amount` tokens from the caller's account to `to`.
     * @param to The address of the recipient to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transfer(address to,uint256 amount) external  virtual  returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    
    /**
     * @dev Transfers tokens from one account to another.
     * Moves `amount` tokens from `from` account to `to` account, given the allowance.
     * @param from The address of the sender's account.
     * @param to The address of the recipient's account.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transferFrom(address from,address to,uint256 amount) external  virtual  returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    /**
     * @dev Returns the amount of tokens that `spender` is allowed to spend on behalf of `owner`.
     * Retrieves and returns the allowance set by `owner` for `spender`.
     * @param owner The address of the token owner.
     * @param spender The address of the spender.
     * @return uint256 representing the allowance.
     */
    function allowance(address owner, address spender) public view virtual  returns (uint256) {
        return _allowances[owner][spender];
    }
 
    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Emits an Approval event.
     * @param spender The address of the spender to approve.
     * @param amount The allowance amount to approve.
     * @return A boolean indicating whether the approval was successful or not.
     */
    function approve(address spender, uint256 amount) external   returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
 
    /**
     * @dev Internal function to set an allowance for a spender.
     * Emits an Approval event.
     * @param sender The address of the token owner.
     * @param spender The address of the spender to set the allowance for.
     * @param amount The allowance amount to set.
     */
    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }
 
    /**
     * @dev Internal function to spend allowance from the owner's account.
     * If allowance is not set to unlimited, it ensures that the spender is allowed to spend the specified amount.
     * Emits an Approval event if the allowance is reduced.
     * @param owner The address of the token owner.
     * @param spender The address of the spender.
     * @param amount The amount to spend from the allowance.
     */
    function _spendAllowance(address owner,address spender,uint256 amount)internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Internal function to transfer tokens from one address to another.
     * Moves `amount` tokens from the `from` address to the `to` address.
     * Emits a Transfer event.
     * @param from The address of the sender.
     * @param to The address of the recipient.
     * @param amount The amount of tokens to transfer.
     */ 
    function _transferTokens(address from,address to,uint256 amount)internal virtual {
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    /**
     * @dev Internal function for transferring tokens from one address to another.
     * If the sender, recipient, or token contract itself is the owner, it performs a regular transfer.
     * If the transfer involves buy or sell on Uniswap, a marketing tax is applied before transferring tokens.
     * Emits Transfer events for both the marketing tax and the token transfer.
     * @param sender The address of the sender.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
 
        //If it's the owner, do a normal transfer
        if (sender == owner() || recipient == owner() || sender == address(this)) {
            _transferTokens(sender, recipient, amount);
            return;
        }

        bool isBuy = sender == _uniswapPair;
        bool isSell = recipient == _uniswapPair;

        uint256 Tax;

        if(isBuy || isSell){
            Tax = amount * (TAX) / (100);
            _transferTokens(sender, TREASURYWALLET, Tax);
            amount -= Tax;
        }

        _transferTokens(sender, recipient, amount);
    }
}