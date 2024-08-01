// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
contract USDCtoEAISwap is Ownable(msg.sender) {
    // Addresses for USDC, EAI tokens, and Uniswap router
    address public usdcTokenAddress;
    address public eaiTokenAddress;
    address public uniswapRouterAddress;
    address public treasuryWallet;
    address public operationWallet;
    uint256 public swapPercentage;
    mapping(address => bool) public excludedWallets;

    IUniswapV2Router02 public uniswapRouter;

    // Event emitted after a successful swap and send operation
    event SwapAndSend(uint256 usdcAmount, uint256 eaiAmount);

    /**
     * @dev Constructor to initialize the contract with required addresses and parameters.
     * @param _usdcTokenAddress Address of the USDC token contract.
     * @param _eaiTokenAddress Address of the EAI token contract.
     * @param _uniswapRouterAddress Address of the Uniswap V2 router contract.
     * @param _operationWallet Address where remaining USDC will be sent after swap.
     * @param _treasuryWallet Address where EAI tokens will be sent after swap.
     * @param _swapPercentage Percentage of USDC to be swapped to EAI.
     */
    constructor(
        address _usdcTokenAddress,
        address _eaiTokenAddress,
        address _uniswapRouterAddress,
        address _operationWallet,
        address _treasuryWallet,
        uint256 _swapPercentage
    ) {
        usdcTokenAddress = _usdcTokenAddress;
        eaiTokenAddress = _eaiTokenAddress;
        uniswapRouterAddress = _uniswapRouterAddress;
        treasuryWallet = _treasuryWallet;
        operationWallet = _operationWallet;
        swapPercentage = _swapPercentage;
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
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
        treasuryWallet = _treasuryWallet;
    }

    /**
     * @dev Function to update the operation wallet for remaining USDC.
     * @param _operationWallet New address to receive remaining USDC.
     */
    function updateOperationWallet(address _operationWallet) external onlyOwner {
        operationWallet = _operationWallet;
    }

    /**
     * @dev Function to update the exclusion status of a wallet.
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
        IERC20(usdcTokenAddress).approve(uniswapRouterAddress, swapAmount);

        // Define the Uniswap swap path (USDC -> EAI)
        address[] memory path = new address[](2);
        path[0] = usdcTokenAddress;
        path[1] = eaiTokenAddress;

        // Perform the token swap on Uniswap
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
