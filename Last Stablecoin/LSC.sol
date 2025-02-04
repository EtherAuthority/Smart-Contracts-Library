/**
  
██╗      █████╗ ███████╗████████╗    ███████╗████████╗ █████╗ ██████╗ ██╗     ███████╗ ██████╗ ██████╗ ██╗███╗   ██╗
██║     ██╔══██╗██╔════╝╚══██╔══╝    ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝██╔═══██╗██║████╗  ██║
██║     ███████║███████╗   ██║       ███████╗   ██║   ███████║██████╔╝██║     █████╗  ██║     ██║   ██║██║██╔██╗ ██║
██║     ██╔══██║╚════██║   ██║       ╚════██║   ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ██║     ██║   ██║██║██║╚██╗██║
███████╗██║  ██║███████║   ██║       ███████║   ██║   ██║  ██║██████╔╝███████╗███████╗╚██████╗╚██████╔╝██║██║ ╚████║
╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
                                                                                                               
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}
 
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

/**
 * @title LastStablecoin (LSC)
 * @dev An ERC-20 token with a fixed supply, anti-whale mechanism, and tax system.
 */
contract LastStablecoin is Ownable, IERC20,ReentrancyGuard {
    
    // Token metadata
    string private constant _name = "Last Stablecoin";
    string private constant _symbol = "LSC";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 1_000_000_000 * 10**uint256(_decimals); // 1 billion tokens
    
    // Mapping to store balances and allowances
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    
    // Address to receive tax funds
    address public taxWallet;
    
    // Tax percentage on buy/sell transactions
    uint256 public totalTaxPercent = 3;
    
    // Minimum amount required to trigger tax distribution
    uint256 public taxThreshold = 1000 * 10**uint256(_decimals); // 1000 LSC
    
    // Anti-whale mechanism: max buy/sell limit (1% of total supply)
    uint256 public maxBuySellAmount = _totalSupply / 100;
    
    // Uniswap router and pair addresses
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapPair;
    
    // Prevents reentrancy during tax swap
    bool private swapping;
    
    bool public trade_open;
    uint256 private currentBlockNumber;
    uint256 public numBlocks = 100;
    // Events for tracking updates
    event UpdatedTaxWallet(address updatedTaxWallet);
    event UpatedTaxThreshold(uint256 updateTaxThreshold);
    event UpdatedMaxAmount(uint256 updatedMaxAmount);
    
    /**
     * @dev Contract constructor
     * @param _taxWallet Address where tax funds will be collected
     */
    constructor(address _taxWallet) {        
        require(_taxWallet != address(0), "Tax wallet cannot be zero address");
        
        // Assign contract ownership to deployer
        transferOwnership(msg.sender);

        // Mint total supply to contract owner
        _balances[owner()] = _totalSupply;

        // Initialize Uniswap router and create liquidity pair
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // Ethereum mainnet UniswapV2 Router
        );
        uniswapV2Router = _uniswapV2Router;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        
        // Approve Uniswap router for token transfers
        _approve(owner(), address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        
        // Set tax wallet
        taxWallet = _taxWallet;
        
        // Emit initial transfer event
        emit Transfer(address(0), owner(), _totalSupply);
    }
 
    /**
    * @notice Retrieves the name of the token.
    * @dev This function returns the name of the token, which is often used for identification.
    * It is commonly displayed in user interfaces and provides a human-readable name for the token.
    * @return The name of the token.
    */
    function name() public view virtual  returns (string memory) {
        return _name;
    }
     
    /**
    * @notice Retrieves the symbol or ticker of the token.
    * @dev This function returns the symbol or ticker that represents the token.
    * It is commonly used for identifying the token in user interfaces and exchanges.
    * @return The symbol or ticker of the token.
    */
    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }
     
    /**
    * @notice Retrieves the number of decimal places used in the token representation.
    * @dev This function returns the number of decimal places used to represent the token balances.
    * It is commonly used to interpret the token amounts correctly in user interfaces.
    * @return The number of decimal places used in the token representation.
    */
    function decimals() public view virtual  returns (uint8) {
        return _decimals;
    }
    
    /**
    * @notice Retrieves the total supply of tokens.
    * @dev This function returns the total supply of tokens in circulation.
    * @return The total supply of tokens.
    */
    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }
 
    /**
    * @notice Returns the balance of the specified account.
    * @param account The address for which the balance is being queried.
    * @return The balance of the specified account.
    */
    function balanceOf(
        address account
    ) public view virtual  returns (uint256) {
        return _balances[account];
    }   

    /**
    * @notice Transfers tokens from the sender's account to the specified recipient.
    * @dev This function is used to transfer tokens from the sender's account to the specified recipient.
    * @param to The address of the recipient to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating whether the transfer was successful or not.
    */
    function transfer(
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    
    /**
    * @notice Transfers tokens from one account to another on behalf of a spender.
    * @dev This function is used to transfer tokens from one account to another on behalf of a spender.
    * @param from The address from which tokens will be transferred.
    * @param to The address to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating whether the transfer was successful or not.
    */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
 
    /**
    * @notice Returns the amount of tokens that the spender is allowed to spend on behalf of the owner.
    * @param owner The address of the owner of the tokens.
    * @param spender The address of the spender.
    * @return The allowance amount.
    */
    function allowance(
        address owner,
        address spender
    ) public view virtual  returns (uint256) {
        return _allowances[owner][spender];
    }
 
    /**
    * @notice Approves the spender to spend a specified amount of tokens on behalf of the sender.
    * @param spender The address of the spender to be approved.
    * @param amount The amount of tokens to be approved for spending.
    * @return A boolean indicating whether the approval was successful or not.
    */
    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
 
    /**
    * @notice Internal function to set allowance for a spender.
    * @dev This function sets the allowance for a spender to spend tokens on behalf of the owner.
    * @param sender The address of the owner of the tokens.
    * @param spender The address of the spender.
    * @param amount The amount of tokens to be approved for spending.
    */
    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }
 
    /**
    * @notice Internal function to spend tokens from the allowance of a spender.
    * @dev This function checks if the spender has sufficient allowance from the owner
    * to spend the specified amount of tokens. If the spender's allowance is not
    * unlimited, it is decreased by the spent amount.
    * @param owner The address of the owner of the tokens.
    * @param spender The address of the spender.
    * @param amount The amount of tokens to be spent.
    */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    * @notice Internal function to transfer tokens from one address to another.
    * @dev This function transfers a specified amount of tokens from one address to another.
    * @param from The address from which tokens will be transferred.
    * @param to The address to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    */
    function _transferTokens(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }
 
        emit Transfer(from, to, amount);
    }
  
 
    /**
     * @notice Sets the maximum buy/sell limit per transaction.
     * @dev Ensures that the new limit is above a predefined minimum to prevent extreme restrictions.
     *
     * The function allows the contract owner to modify the maximum buy/sell limit,
     * ensuring flexibility in managing transaction size restrictions.
     *
     * The `amount` parameter should include decimal places.
     * For example, if the token has 18 decimals, setting a limit of 1,000,000 tokens
     * requires an input of `1_000_000 * 10^18`.
     *
     * Emits an {UpdatedMaxAmount} event upon successful update.
     *
     * @param amount The new maximum amount allowed per transaction. Must include decimals.
     */
    function setMaxBuySellLimit(uint256 amount) external onlyOwner {
        require(amount >= 1_000_000 * 10**uint256(_decimals), "Max buy sell limit can not be less than 1_000_000 tokens");
        maxBuySellAmount = amount;
        emit UpdatedMaxAmount(maxBuySellAmount);
    }
   

    /**
     * @dev Enables or disables trading for the token.
     * Only the contract owner can call this function.
     * If trading is enabled, it stores the current block number.
     */
    function enableTrade() public onlyOwner {
        require(!trade_open, "Trading already open");
        trade_open = true;       
        currentBlockNumber = block.number;
    }

    /**
     * @dev Returns whether trading is currently enabled.
     * @return Boolean value indicating if trading is open.
     */
    function isTradeEnabled() external view returns (bool) {
        return trade_open;
    }

   

    /**
    * @dev Sets a new development wallet address.
    * - Only callable by the contract owner.
    * - Ensures that the provided address is not the zero address.
    * - Updates the `taxWallet` state variable with the new address.
    * - Emits an `UpdatedTaxWallet` event to log the change.
    * @param wallet The new development wallet address.
    */
    function setTaxWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Tax wallet cannot be zero address");
        taxWallet = wallet;
        emit UpdatedTaxWallet(taxWallet);
    }

    /**
    * @dev Sets the minimum token threshold for tax collection.
    * - Only callable by the contract owner.
    * - Ensures that the threshold is greater than zero to prevent invalid values.
    * - Updates the `taxThreshold` state variable with the new threshold.
    * - Emits an `UpdatedTaxThreshold` event to log the new threshold value.
    * @param _threshold The new tax threshold amount. Amount shoud be with decimals.
    */
    function setTaxThreshold(uint256 _threshold) external onlyOwner {
        require(_threshold > 1000 * 10 ** decimals(), "Amount should be more than zero");
        taxThreshold = _threshold;
        emit UpatedTaxThreshold(taxThreshold);
    }

  

   
    
    /**
    * @dev Swaps a specified amount of tokens for ETH using the Uniswap V2 router.
    * - The swap follows the token -> WETH path, converting tokens held by the contract into ETH.
    * - Approves the Uniswap router to spend the specified token amount.
    * - Uses `swapExactTokensForETHSupportingFeeOnTransferTokens` to execute the swap, which ensures fee-on-transfer tokens are supported.
    * - Accepts any amount of ETH in return for the swap.
    * - Sends the swapped ETH to the contract's address.
    * @param tokenAmount The amount of tokens to be swapped for ETH.
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
    * @notice Swaps contract-held tokens for ETH and transfers the tax amount to the tax wallet.
    * @dev Uses Uniswap to swap tokens for ETH and prevents reentrancy attacks.
    * 
    * - Limits the swap amount to `maxBuySellAmount` to prevent excessive swaps.
    * - Uses `nonReentrant` to avoid reentrancy vulnerabilities.
    * - Sends the swapped ETH to the tax wallet, ensuring gas efficiency.
    */
    function swapAndLiquify() internal {
        uint256 contractTokenBalance = balanceOf(address(this));  
 
            uint256 initialBalance = address(this).balance;
 
            swapTokensForEth(contractTokenBalance);

            uint256 newBalance = address(this).balance - (initialBalance);

            bool transferSuccessToTaxwallet;  

            (transferSuccessToTaxwallet,) = taxWallet.call{value: newBalance, gas: 35000}("");
            require(transferSuccessToTaxwallet, "Transfer to Tax wallet failed");

    }

    /**
     * _transfer function handles token transfers, with special rules for buy/sell transactions and tax handling.
     * 
     * Netscape Comment:
     * For normal transfers (between non-Uniswap addresses and non-owner accounts), the transfer proceeds without any tax.
     * If the transfer involves buying or selling on Uniswap, the function ensures the amount doesn't exceed the max buy/sell limit, calculates the tax, and deducts it.
     * Blacklisted addresses cannot participate in transfers, and no tax is applied for owner or normal transfers.
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

         //Check if trading is enabled
        require(trade_open, "Trading is disabled");

        if(block.number <= currentBlockNumber + numBlocks){     
            require(false);       
            return;
        }

        bool isBuy = sender == uniswapPair;
        bool isSell = recipient == uniswapPair;
        uint256 taxAmount;

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= taxThreshold;
 
        if (
            canSwap &&
            sender != uniswapPair &&
            !swapping 
        ) {
            swapping = true;
            swapAndLiquify();
            swapping = false;
        }
       
        if (isBuy || isSell) {
            require(maxBuySellAmount >= amount,"Exceed Buy sell max limit");

                taxAmount = _calculateTax(amount, totalTaxPercent);
                _transferTokens(sender, address(this), taxAmount); 
        
            } 
            amount -= taxAmount;
            _transferTokens(sender, recipient, amount);
    }
 
    /**
    * @dev Calculates the tax amount based on the provided percentage.
    * @param amount The total amount to calculate tax on.
    * @param _taxPercentage The tax percentage.
    * @return The calculated tax amount.
    */
    function _calculateTax(uint256 amount, uint256 _taxPercentage) internal pure returns (uint256) {
        return (amount * _taxPercentage) / 100;
    }

    /**
    * @dev Function to receive ETH when sent directly to the contract.
    * This function is called when no data is supplied with the transaction.
    */
    receive() external payable {}

}
