// SPDX-License-Identifier:MIT
pragma solidity 0.8.24;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @dev Interface for Uniswap V2 Router01.
 */
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
    
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    
    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

/**
 * @dev Interface for Uniswap V2 Router02, extends Router01 with additional functions.
 */
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

/**
 * @dev Contract to swap USDC to EAI tokens using Uniswap, with configurable parameters.
 */
contract USDCtoEAISwap is Ownable{
    // Addresses for USDC, EAI tokens, and Uniswap router
    address public usdcTokenAddress;
    address public eaiTokenAddress;
    address public treasuryWallet;
    address public operationWallet;
    uint256 public swapPercentage;
    mapping(address => bool) public excludedWallets;

    IUniswapV2Router02 public uniswapRouter;

    // Event emitted after a successful swap and send operation
    event SwapAndSend(uint256 usdcAmount, uint256 eaiAmount);

   
    constructor(
        address _usdcTokenAddress,
        address _eaiTokenAddress,
        address _operationWallet,
        address _treasuryWallet
    )Ownable(msg.sender) {
        usdcTokenAddress = _usdcTokenAddress;
        eaiTokenAddress = _eaiTokenAddress;
        treasuryWallet = _operationWallet;
        operationWallet = _treasuryWallet;
        swapPercentage = 50;
        uniswapRouter = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    }

    /**
     * @dev Modifier to restrict access to non-excluded wallets.
     */
    modifier onlyNonExcluded() {
        require(!excludedWallets[msg.sender], "Excluded wallet");
        _;
    }

    /**
     * @dev Function to update the swap percentage.
     * @param _swapPercentage New percentage of USDC to be swapped to EAI.
     */
    function updateSwapPercentage(uint256 _swapPercentage) external onlyOwner {
        require(_swapPercentage <= 100, "Invalid percentage");
        swapPercentage = _swapPercentage;
    }

    /**
     * @dev Function to update the treasury wallet for EAI tokens.
     * @param _treasuryWallet New address to receive EAI tokens.
     */
    function updateTreasuryWallet(address _treasuryWallet) external onlyOwner {
         require(_treasuryWallet !=address(0),"TreasuryWallet wallet can not be zero");
        treasuryWallet = _treasuryWallet;
    }

    /**
     * @dev Function to update the operation wallet for remaining USDC.
     * @param _operationWallet New address to receive remaining USDC.
     */
    function updateOperationWallet(address _operationWallet) external onlyOwner {
        require(_operationWallet !=address(0),"OperationWallet wallet can not be zero");
        operationWallet = _operationWallet;
    }

    /**
     * @dev Function to update the 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 exclusion status of a wallet.
     * @param _wallet Address of the wallet to be updated.
     * @param _isExcluded New exclusion status for the wallet.
     */
    function updateExcludedWallet(address _wallet, bool _isExcluded) external onlyOwner {
        excludedWallets[_wallet] = _isExcluded;
    }

    /**
     * @dev Function to swap USDC to EAI tokens and send remaining USDC.
     * @param usdcAmount Amount of USDC to be swapped.
     */
    function swapAndSend(uint256 usdcAmount) external onlyNonExcluded {
        
        uint256 swapAmount = (usdcAmount * swapPercentage) / 100;
        uint256 sendAmount = usdcAmount - swapAmount;

        // Transfer USDC from the sender to this contract
        IERC20(usdcTokenAddress).transferFrom(msg.sender, address(this), usdcAmount);

        // Approve the Uniswap router to spend the specified swap amount

        IERC20(usdcTokenAddress).approve(address(uniswapRouter), swapAmount);
        
        // Define the Uniswap swap path (USDC -> EAI)
        address[] memory path = new address[](2);
        path[0] = usdcTokenAddress;
        path[1] = eaiTokenAddress;

        // // Perform the token swap on Uniswap
        uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(
            swapAmount,
            0, // Accept any amount of EAI
            path,
            treasuryWallet,
            block.timestamp
        );

        // Transfer the remaining USDC to the operation wallet
        IERC20(usdcTokenAddress).transfer(operationWallet, sendAmount);

        // Emit the SwapAndSend event
        emit SwapAndSend(swapAmount, amounts[1]);
    }
}
