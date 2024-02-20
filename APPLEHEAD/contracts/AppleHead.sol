/**
          █████╗ ██████╗ ██████╗ ██╗     ███████╗██╗  ██╗███████╗ █████╗ ██████╗ 
         ██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝██║  ██║██╔════╝██╔══██╗██╔══██╗
         ███████║██████╔╝██████╔╝██║     █████╗  ███████║█████╗  ███████║██║  ██║
         ██╔══██║██╔═══╝ ██╔═══╝ ██║     ██╔══╝  ██╔══██║██╔══╝  ██╔══██║██║  ██║
         ██║  ██║██║     ██║     ███████╗███████╗██║  ██║███████╗██║  ██║██████╔╝
         ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
                                                                        
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
 
/**
 * @title Context
 * @dev The base contract that provides information about the message sender
 * and the calldata in the current transaction.
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
 
contract AppleHead is Ownable {
 
    string private constant NAME = "Applehead";
    string private constant SYMBOL = "APXD";
    uint8  private constant DECIMAL= 18;
    uint256 private _totalSupply = 10* 10**9 *10**uint256(DECIMAL);
 
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whiteList;
    mapping(address => uint256) private _timeLimit;
    
    //coin operation wallet
    address public developmentWallet;
    address public marketingWallet;
    address public reserveWallet;

    uint256 public holder1SellTaxPercent = 6;
    uint256 public holder2SellTaxPercent = 7;
    uint256 public otherHolderSellTaxPercentage = 8;
    
    uint256 public constant WALLETTAXSHARE = 28;   
    uint256 public constant LIQUIDITYTAXSHARE = 28; 
    
    // Threshold for performing swapandliquify
    uint256 public taxThreshold = 100 * 10**uint256(DECIMAL); 

    //5 Minutes time delay
    uint256 private  constant TIMEDELAY= 300; 
 
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapPair;
 
    bool private swapping;

    modifier onlyWhitelisted() {
        require(whiteList[msg.sender], "Caller is not whitelisted");
        _;
    }
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event SniperDetected(address  sniper);
    event ModifyWallet(address wallet);
    event ThresholdUpdated(uint256 amount); 
    event SellTaxUpdated(uint256 otherHolderTaxPer,uint256 holder1TaxPer,uint256 holder2TaxPer);
    event TokenSweep(uint256 amount);
    event RecoverETH(uint256 amount);
    event Whitelisted(address user);
    event RemoveWhitelisted(address user);
  
    /** 
    * @notice Initializes the contract with initial token allocations and sets up Uniswap V2 router.
    * @param _developmentWallet The address of the development wallet.
    * @param _marketingWallet The address of the marketing wallet.
    * @param _reserveWallet The address of the reserve wallet.
    */
    constructor(address _developmentWallet, address _marketingWallet, address _reserveWallet) {
        require(_developmentWallet != address(0),"Development wallet can not be zero");
        require(_marketingWallet != address(0),"Marketing wallet can not be zero");
        require(_reserveWallet != address(0),"Reserve wallet can not be zero");
        // Set the initial balance of the deployer to the total supply of tokens
        _balances[msg.sender] = _totalSupply;
        
        // Initialize Uniswap V2 router
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D //Ethereum
        );
        uniswapV2Router = _uniswapV2Router;
        
        // Create Uniswap V2 pair for the token
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        
        // Approve Uniswap router to spend tokens
        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        
        // Assign wallet addresses
        developmentWallet = _developmentWallet;
        marketingWallet = _marketingWallet;
        reserveWallet = _reserveWallet;
        
        // Whitelist contract deployer and contract itself
        whiteList[address(this)] = true;
        whiteList[msg.sender] = true;
    
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
    * @notice Retrieves the name of the token.
    * @dev This function returns the name of the token, which is often used for identification.
    * It is commonly displayed in user interfaces and provides a human-readable name for the token.
    * @return The name of the token.
    */
    function name() external pure returns (string memory) {
        return NAME;
    }

    /**
    * @notice Retrieves the symbol or ticker of the token.
    * @dev This function returns the symbol or ticker that represents the token.
    * It is commonly used for identifying the token in user interfaces and exchanges.
    * @return The symbol or ticker of the token.
    */
    function symbol() external pure returns (string memory) {
        return SYMBOL;
    }

    /**
    * @notice Retrieves the number of decimal places used in the token representation.
    * @dev This function returns the number of decimal places used to represent the token balances.
    * It is commonly used to interpret the token amounts correctly in user interfaces.
    * @return The number of decimal places used in the token representation.
    */
    function decimals() external pure returns (uint8) {
        return DECIMAL;
    }

    /**
    * @notice Retrieves the total supply of tokens.
    * @dev This function returns the total supply of tokens in circulation.
    * @return The total supply of tokens.
    */
    function totalSupply() external view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
    * @notice Returns the balance of the specified account.
    * @param account The address for which the balance is being queried.
    * @return The balance of the specified account.
    */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
    * @notice Transfers tokens from the sender's account to the specified recipient.
    * @dev This function is used to transfer tokens from the sender's account to the specified recipient.
    * @param to The address of the recipient to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating whether the transfer was successful or not.
    */
    function transfer(address to, uint256 amount) public virtual returns (bool) {
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
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
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
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    
    /**
    * @notice Approves the spender to spend a specified amount of tokens on behalf of the sender.
    * @param spender The address of the spender to be approved.
    * @param amount The amount of tokens to be approved for spending.
    * @return A boolean indicating whether the approval was successful or not.
    */
    function approve(address spender, uint256 amount) external returns (bool) {
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
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
    * @notice Internal function to calculate tax amount based on a given percentage.
    * @dev This function calculates the tax amount by applying the specified tax percentage to the given amount.
    * @param amount The amount to apply the tax to.
    * @param taxPercentage The percentage of tax to be applied.
    * @return The calculated tax amount.
    */
    function _calculateTax(uint256 amount, uint256 taxPercentage) internal pure returns (uint256) {
        return amount * taxPercentage / 100;
    }

    /**
    * @notice Internal function to burn tokens from a specified account.
    * @dev This function burns a specified amount of tokens from the specified account.
    * @param account The address of the account from which tokens will be burned.
    * @param amount The amount of tokens to be burned.
    */
    function _burnTokens(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] -= amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
    }

    /**
    * @notice Burns a specified amount of tokens from the sender's account.
    * @dev This function burns a specified amount of tokens from the sender's account.
    * @param amount The amount of tokens to be burned.
    */
    function burn(uint256 amount) external {
        _burnTokens(msg.sender, amount);
    }

    /**
    * @notice Internal function to transfer tokens from one address to another.
    * @dev This function transfers a specified amount of tokens from one address to another.
    * @param from The address from which tokens will be transferred.
    * @param to The address to which tokens will be transferred.
    * @param amount The amount of tokens to be transferred.
    */
    function _transferTokens(address from, address to, uint256 amount) internal virtual {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    /**
    * @notice Adds an address to the whitelist.
    * @dev This function adds the specified account to the whitelist, allowing it to access certain functionalities.
    * @param account The address to be added to the whitelist.
    * @dev Only the owner of the contract can call this function.
    */
    function addToWhitelist(address account) external onlyOwner {
        require(!whiteList[account], "already whitelisted");
        whiteList[account] = true;
        emit Whitelisted(account);
    }

    /**
    * @notice Removes an address from the whitelist.
    * @dev This function removes the specified account from the whitelist, restricting its access to certain functionalities.
    * @param account The address to be removed from the whitelist.
    * @dev Only the owner of the contract can call this function.
    */
    function removeFromWhitelist(address account) external onlyOwner {
        require(whiteList[account], "already removed from whitelist");
        whiteList[account] = false;
        emit RemoveWhitelisted(account);
    }
    
    /**
    * @dev Retrieves the maximum limit for a certain calculation.
    * This external view function returns a uint256 value, representing 0.5% (5/1000) of the total supply.
    * @return The calculated maximum limit.
    */
    function maxLimit() external view returns(uint256) {
        return 5 * _totalSupply / 1000;
    }

    /**
    * @notice Sets the development wallet address.
    * @dev This function updates the development wallet address to the specified address.
    * @param wallet The new address for the development wallet.
    * @dev Only the owner of the contract can call this function.
    */
    function setDevelopmentWallet(address wallet) external onlyOwner {
        require(wallet != address(0), "Development wallet cannot be zero address");
        developmentWallet = wallet;
        emit ModifyWallet(wallet);
    }
    
    /**
    * @notice Sets the marketing wallet address.
    * @dev This function updates the marketing wallet address to the specified address.
    * @param wallet The new address for the marketing wallet.
    * @dev Only the owner of the contract can call this function.
    * @dev The marketing wallet address cannot be set to the zero address.
    */
    function setMarketingWallet(address wallet) external onlyOwner {
        require(wallet != address(0), "Marketing wallet cannot be zero address");
        marketingWallet = wallet;
        emit ModifyWallet(wallet);
    }

    /**
    * @notice Sets the reserve wallet address.
    * @dev This function updates the reserve wallet address to the specified address.
    * @param wallet The new address for the reserve wallet.
    * @dev Only the owner of the contract can call this function.
    * @dev The reserve wallet address cannot be set to the zero address.
    */
    function setReserveWallet(address wallet) external onlyOwner {
        require(wallet != address(0), "Reserve wallet cannot be zero address");
        reserveWallet = wallet;
        emit ModifyWallet(wallet);
    }

    /**
     * @notice Sets the sell tax percentage for transactions initiated by holders other than holder1 and holder2.
     * @dev The sell tax percentage cannot exceed 14%. If the provided taxPercentage is greater than 1%, 
     *      the sell tax percentages for holder1 and holder2 will be adjusted accordingly.
     * @param taxPercentage The new sell tax percentage to be set. It must be between 0 and 14.
     */
    function setSellTaxPercentage(uint256 taxPercentage) external onlyOwner {
        require(taxPercentage <= 14, "Tax percentage cannot exceed 14%");
        otherHolderSellTaxPercentage = taxPercentage;
        if(taxPercentage > 1){
           
            holder1SellTaxPercent = taxPercentage - 2;
            holder2SellTaxPercent = taxPercentage - 1;
        }
        else {
            holder1SellTaxPercent = 0;
            holder2SellTaxPercent = 0;
        }
        emit SellTaxUpdated(otherHolderSellTaxPercentage,holder1SellTaxPercent,holder2SellTaxPercent);
    }

    /**
    * @notice Sets the tax threshold.
    * @dev This function updates the threshold amount above which the sell tax is applied.
    * @param threshold The new threshold amount.
    * @dev Only the owner of the contract can call this function.
    * @dev The threshold amount must be more than zero and less than or equal to 500,000 tokens.
    */
    function setTaxThreshold(uint256 threshold) external onlyOwner {
        require(threshold > 0 && threshold <= 5 * 10**5 * 10**18, "Amount should be more than zero and less than 500k tokens");
        taxThreshold = threshold;
        emit ThresholdUpdated(threshold);
    }
    
    /**
    * @notice Sweeps tokens from the contract to the owner's address.
    * @dev This function allows the owner to sweep tokens from the contract to the owner's address.
    * @param tokenAddress The address of the token to be swept.
    * @param amount The amount of tokens to be swept.
    * @dev Only the owner of the contract can call this function.
    * @dev The owner cannot claim the contract's balance of its own tokens.
    * @dev The function checks the contract's balance of the specified token and ensures that it is sufficient for the sweep.
    * @dev If the sweep is successful, emits a TokenSweep event.
    * @param tokenAddress The address of the token to be swept.
    * @param amount The amount of tokens to be swept.
    */
    function sweepTokensFromContract(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(this), "Owner can't claim contract's balance of its own tokens");
    
        uint256 _tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
       
        require(amount <= _tokenBalance, "Insufficient balance for sweep");
    
        bool success = IERC20(tokenAddress).transfer(msg.sender, amount);
        require(success, "Transfer failed");
        emit TokenSweep(amount);
    }

    /**
    * @notice Recovers native ETH stuck in the contract.
    * @dev This function allows the owner to recover native ETH stuck in the contract.
    * @dev Only the owner of the contract can call this function.
    * @dev The function checks if there is a non-zero balance of native ETH in the contract and transfers it to the owner's address.
    * @dev If the recovery is successful, emits a RecoverETH event.
    */
    function recoverETHfromContract() external onlyOwner {
        uint256 recoverBalance = address(this).balance;
        require(recoverBalance > 0, "Insufficient balance for recover ETH");
        payable(msg.sender).transfer(recoverBalance);
        emit RecoverETH(recoverBalance);
    }

    /**
    * @notice Swaps tokens for ETH using the Uniswap V2 Router.
    * @dev This function swaps the specified amount of tokens for ETH using the Uniswap V2 Router.
    * @param tokenAmount The amount of tokens to swap for ETH.
    * @dev This function is private and can only be called internally.
    * @dev It approves the Uniswap V2 Router to spend the token amount, then performs the swap by calling the
    * swapExactTokensForETHSupportingFeeOnTransferTokens function of the Uniswap V2 Router.
    */
    function swapTokensForEth(uint256 tokenAmount) private {
        // Generate the Uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
    
        // Approve the Uniswap V2 Router to spend the token amount
        _approve(address(this), address(uniswapV2Router), tokenAmount);
    
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    /**
    * @notice Swaps tokens for ETH and adds liquidity to the Uniswap pool.
    * @dev This function swaps a portion of the contract's token balance for ETH using the Uniswap V2 Router,
    * Get the contract's token balance
    * Calculate the amount of tokens to be swapped and the amount of tokens for liquidity
    * Record the initial balance of the contract's address
    * Swap tokens for ETH
    * Calculate the new ETH balance after the swap
    * then splits the resulting ETH between the marketing, reserve, and development wallets according to specified shares.
    * Finally, it adds liquidity to the Uniswap pool using the remaining token balance and the received ETH.
    * @dev This function is internal and can only be called internally.
    */
    function swapAndLiquify() internal {
        uint256 contractTokenBalance = balanceOf(address(this));
    
        uint256 liqHalf = (contractTokenBalance * LIQUIDITYTAXSHARE) / (100 * 2);
        uint256 otherLiqHalf = (contractTokenBalance * LIQUIDITYTAXSHARE) / 100 - liqHalf;
        uint256 tokensToSwap = contractTokenBalance - liqHalf; 
    
        uint256 initialBalance = address(this).balance;
    
        swapTokensForEth(tokensToSwap);
    
        uint256 newBalance = address(this).balance - initialBalance;
        uint256 walletTax = (newBalance * WALLETTAXSHARE) / 100;

        payable(marketingWallet).transfer(walletTax);
        newBalance -= walletTax; 
        payable(reserveWallet).transfer(walletTax);
        newBalance -= walletTax;
        payable(developmentWallet).transfer(walletTax);
        newBalance -= walletTax;

        if (newBalance > 0) {
            addLiquidity(otherLiqHalf, newBalance);
        }
    }
    
    /**
    * @notice Adds liquidity to the Uniswap V2 pool using the provided token and ETH amounts.
    * @dev This function approves the transfer of the specified token amount to the Uniswap V2 Router, then adds liquidity to the Uniswap V2 pool using the provided token and ETH amounts.
    * @param tokenAmount The amount of tokens to provide as liquidity.
    * @param ethAmount The amount of ETH to provide as liquidity.
    * @dev This function is private and can only be called internally.
    */
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
    
        // Add liquidity to the Uniswap V2 pool
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    /**
    * @dev Internal function for token transfers with additional checks and fees.
    * @param sender The address sending the tokens.
    * @param recipient The address receiving the tokens.
    * @param amount The amount of tokens to be transferred.
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
    
        // If it's the owner, do a normal transfer
        if (sender == owner() || recipient == owner() || sender == address(this)) {
            _transferTokens(sender, recipient, amount);
            return;
        }
    
        // Check for buy or sell transactions
        bool isBuy = sender == uniswapPair;
        bool isSell = recipient == uniswapPair;
    
        // Additional checks and actions for buy and sell transactions
        if (isBuy) {
            // 0.5% max buy amount
            require(amount <= 5 * _totalSupply / 1000, "Can not buy more than max limit 0.5%");
            uint256 balanceOfBuyer = balanceOf(recipient) + amount;
            require(_totalSupply / 100 >= balanceOfBuyer, "You cannot buy more than 1% of total supply");
            _timeLimit[recipient] = block.timestamp + TIMEDELAY;
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= taxThreshold;
        if (canSwap && !swapping && sender != uniswapPair && !whiteList[sender] && !whiteList[recipient]) {
            swapping = true;
            swapAndLiquify();
            swapping = false;
        }
    
        bool takeFee = !swapping;
    
        if (whiteList[sender] || whiteList[recipient]) {
            takeFee = false;
        }
        // Apply fees if required
        if (takeFee) {
            uint256 sellTax;
            if (isSell) {
                // 0.5% max sell amount
                require(amount <= 5 * _totalSupply / 1000, "Can not sell more than max limit 0.5%");
                if (_timeLimit[sender] >= block.timestamp) {
                    emit SniperDetected(sender);
                    return;
                }
                if (!whiteList[sender]) {
                    // 0.01% holder wallet amount
                    if ( _totalSupply / 10000 <= balanceOf(sender)) {
                        sellTax = _calculateTax(amount, holder1SellTaxPercent);
                        _transferTokens(sender, address(this), sellTax); 
                        //0.005% holder wallet amount
                    } else if (5 * _totalSupply / 100000 <= balanceOf(sender)) {
                        sellTax = _calculateTax(amount, holder2SellTaxPercent);
                        _transferTokens(sender, address(this), sellTax); 
                    } else {
                        sellTax = _calculateTax(amount, otherHolderSellTaxPercentage);
                        _transferTokens(sender, address(this), sellTax); 
                    }
                }
            }
            amount -= sellTax;
        }
        _transferTokens(sender, recipient, amount);
    }
    
   fallback() external payable {}
   
   receive() external payable {}
}