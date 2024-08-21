/**
 *Submitted for verification at testnet.bscscan.com on 2024-07-05
*/

// SPDX-License-Identifier: MIT
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

interface IImplementation {
    function tokenToSwap() external view returns (address);
    function totalGeneratedTax() external view returns(uint256);
}

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

contract Implementation is Ownable {
    address public feeWallet;
    IUniswapV2Router02 public immutable uniswapRouter;
    address public tokenToSwap;
    uint256 public constant FEEPRECENT = 1;
    address public immutable factory;
    uint256 public totalGeneratedTax;

    //event
    event UpdateTokenToSwap(address updatedToken);
    event UpdateFeeWallet(address feeWallet);
    event TokensSwapped(uint256 ethAmount, uint256 tokenAmount,address tokenReciver,address mainOwnerFeeWallet,uint256 feeToMainOwner,address feeWallet,uint256 feeToFeeWallet,uint256 totalGeneratedFee);

    /**
     * @dev Constructor to initialize the contract with the provided addresses.
     * @param _feeWallet The address to receive 0.5% of the fee.
     * @param _tokenToSwap The address of the token to swap.
     * @param _owner The address of the owner who deploys this contract.
     * @param _factory The address of the factory contract.
     * 
     * This constructor sets up the contract by assigning values to key addresses and initializes the contract owner.
     */
    constructor(address _feeWallet, address _tokenToSwap, address _owner, address _factory) Ownable(_owner) {
        feeWallet = _feeWallet;
        uniswapRouter = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);  //change router address according to your network
        tokenToSwap = _tokenToSwap;
        factory = _factory;
    }

    /**
     * @dev Fallback function to receive ETH and trigger the swap.
     * This function is automatically called when the contract receives ETH.
     * It calls the internal function `swapAndSend` to perform the swap and distribute fees.
     */
    receive() external payable {
        swapAndSend(msg.value);
    }

    /**
     * @dev Internal function to swap ETH for tokens on Uniswap and distribute fees.
     * @param amount The amount of ETH to swap.
     * This function calculates the fee, performs the swap, and distributes the fees.
     * The event 'TokensSwapped' is emitted with details of the swap and fee distribution.
     */
    function swapAndSend(uint256 amount) internal {
        uint256 fee = (amount * FEEPRECENT) / 100;
        uint256 swapAmount = amount - fee;

        // Perform the token swap on Uniswap
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = tokenToSwap;

       uint[] memory amounts = uniswapRouter.swapExactETHForTokens{value: swapAmount}(
            0,
            path,
            msg.sender,
            block.timestamp
        );
        uint256 tokensReceived = amounts[1];
        totalGeneratedTax += fee;
        uint256 feeToMainOwner = fee / 2;
        uint256 feeToImplementationFeeWallet = fee - feeToMainOwner;
        address mainOwnerFeeWallet = getMainOwnerFeeWallet();
        payable(mainOwnerFeeWallet).transfer(feeToMainOwner);
        payable(feeWallet).transfer(feeToImplementationFeeWallet);
        emit TokensSwapped(amount, tokensReceived,msg.sender,mainOwnerFeeWallet,feeToMainOwner,feeWallet,feeToImplementationFeeWallet,totalGeneratedTax);
    }

    /**
     * @dev Updates the fee wallet address.
     * @param newFeeWallet The new address to set as the fee wallet.
     * Only the contract owner can call this function.
     * Emits an event `UpdateFeeWallet` after updating the fee wallet address.
     */
    function updateFeeWallet(address newFeeWallet) external onlyOwner {
        require(newFeeWallet != address(0),"feeWallet can not be zero!");
        feeWallet = newFeeWallet;
        emit UpdateFeeWallet(feeWallet);
    }

    /**
     * @dev Updates the token to swap address.
     * @param tokenAddress The new address of the token to set as the token to swap.
     * Only the contract owner can call this function.
     * Emits an event `UpdateTokenToSwap` after updating the token to swap address.
     */
    function updateTokenToSwap(address tokenAddress) external onlyOwner {
        tokenToSwap = tokenAddress;
        emit UpdateTokenToSwap(tokenToSwap);
    }

    function getMainOwnerFeeWallet() public view returns (address) {
        Factory factoryContract = Factory(factory);
        return factoryContract.mainOwnerFeeWallet();
    }
}

contract Factory is Ownable {

    struct DeployedContractInfo {
        address contractAddress;
        address tokenContract;
    }
    mapping(address=>address[]) private deployedContracts;
    address public mainOwnerFeeWallet;

    //event
    event ContractCreated(address newContract, address implementationOwner);
    event UpdateMainOwnerFeeWallet(address mainOwnerFeeWallet);

    constructor(address _mainOwnerFeeWallet) Ownable(msg.sender) {
        mainOwnerFeeWallet = _mainOwnerFeeWallet;
    }

    /**
     * @notice Returns an array of DeployedContractInfo for the contracts associated with a given wallet address.
     * @param walletAddress The address of the wallet to query deployed contracts for.
     * @return An array of DeployedContractInfo containing the contract address and token contract address for each deployed contract.
     */
    function deployedContractInformation(address walletAddress) external view returns (DeployedContractInfo[] memory) {
        address[] memory contracts = deployedContracts[walletAddress];
        DeployedContractInfo[] memory contractInfos = new DeployedContractInfo[](contracts.length);

        for (uint256 i = 0; i < contracts.length; i++) {
            IImplementation implementationContract = IImplementation(contracts[i]);
            address tokenToSwap = implementationContract.tokenToSwap();
            contractInfos[i] = DeployedContractInfo({
                contractAddress: contracts[i],
                tokenContract: tokenToSwap
            });
        }

        return contractInfos;
    }

    /**
     * @dev Creates a new instance of the Implementation contract.
     * @param feeWallet The address to receive 0.5% of the fee.
     * @param tokenToSwap The address of the token to swap.
     * This function deploys a new Implementation contract with the provided fee wallet and token to swap addresses.
     * Emits a ContractCreated event after deploying the new contract.
     */
    function createContract(address feeWallet, address tokenToSwap) external {
        Implementation newContract = new Implementation(feeWallet, tokenToSwap, msg.sender, address(this));
        deployedContracts[msg.sender].push(address(newContract));
        emit ContractCreated(address(newContract),msg.sender);
    }

    /**
    * @dev Updates the address of the main owner fee wallet.
    * @param newFeeWallet The new address to set as the main owner fee wallet.
    * Only the contract owner can call this function.
    * Emits an UpdateMainOwnerFeeWallet event after updating the main owner fee wallet address.
    */
    function updateMainOwnerFeeWallet(address newFeeWallet) external onlyOwner {
        require(newFeeWallet != address(0),"mainOwnerFeeWallet can not be zero!");
        mainOwnerFeeWallet = newFeeWallet;
        emit UpdateMainOwnerFeeWallet(mainOwnerFeeWallet);
    }
}
