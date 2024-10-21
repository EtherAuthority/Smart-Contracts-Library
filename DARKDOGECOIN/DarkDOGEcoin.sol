/**
                    

                     ██████╗  █████╗ ██████╗ ██╗  ██╗    ██████╗  ██████╗  ██████╗ ███████╗     ██████╗ ██████╗ ██╗███╗   ██╗
                     ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝    ██╔══██╗██╔═══██╗██╔════╝ ██╔════╝    ██╔════╝██╔═══██╗██║████╗  ██║
                     ██║  ██║███████║██████╔╝█████╔╝     ██║  ██║██║   ██║██║  ███╗█████╗      ██║     ██║   ██║██║██╔██╗ ██║
                     ██║  ██║██╔══██║██╔══██╗██╔═██╗     ██║  ██║██║   ██║██║   ██║██╔══╝      ██║     ██║   ██║██║██║╚██╗██║
                     ██████╔╝██║  ██║██║  ██║██║  ██╗    ██████╔╝╚██████╔╝╚██████╔╝███████╗    ╚██████╗╚██████╔╝██║██║ ╚████║
                     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝     ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
                                                                                                        

                                                                                                                    
*/

/**
                                   website:-   Www.darkdogecoin.org  
                                   Telegram:-  t.me/darkdogecoineth

*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
 
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

contract DARKDOGECOIN is Ownable , IERC20 {
 
    string private constant _name = "DarkDOGEcoin";
    string private constant _symbol = "DDOGE";
    uint8  private constant _decimals = 18;
    uint256 private _totalSupply = 47069 * 10**10 *10**uint256(_decimals);
 
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public blacklisted;
   
    address public charityWallet;
    address public marketingWallet;
   
    uint256 public totalTaxPercent = 1;
    uint256 public  taxThreshold = 1000 * 10**uint256(_decimals); // Threshold for performing tax distribution 
    uint256 public  maxBuySellAmount = 2212243 * 10**6 *10**uint256(_decimals); // Max Buy Limit 

    //Tax share
    uint256 public  charityTaxShare = 47; //47% charity tax share
    uint256 public marketingTaxShare = 53; // 53% marketing tax share

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapPair;

    bool private swapping;
 
    //-------------events------------------ 
    event UpdatedCharityWallet(address updatedCharityWallet);
    event UpdatedMarketingWallet(address updatedMarketingWallet);
    event UpatedTaxThreshold(uint256 updateTaxThreshold);
    event UpdatedMaxAmount(uint256 updatedMaxAmount);
    event Burn(address indexed burner, uint256 amount);
    event RemoedBlacklist(address unBlockUser);
    event Blacklisted(address blockedUser);
    
 
    constructor(address _charityWallet, address _marketingWallet,address _initialOwner) {
        require(_charityWallet != address(0),"Charity wallet cannot be zero address");
        require(_marketingWallet != address(0),"Marketing wallet cannot be zero address");
        transferOwnership(_initialOwner);

        _balances[owner()] = _totalSupply;
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // Ethereum mainnet
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // Binance testnet
        );
        uniswapV2Router = _uniswapV2Router;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
 
        _approve(owner(), address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        charityWallet = _charityWallet;
        marketingWallet = _marketingWallet;
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
    * @dev Burns a specific amount of tokens from the caller's address.
    * @param amount The amount of tokens to be burned.
    */
    function burn(uint256 amount) external  {
        _burn(msg.sender, amount);
    }

/**
 * @dev Destroys `amount` tokens from `account`, reducing the total supply.
 * 
 * This is an internal function that can only be called within the contract or 
 * by derived contracts. It checks that the account is not the zero address and 
 * that the account holds sufficient balance to burn the requested `amount` of tokens.
 * 
 * Emits a {Burn} event.
 * 
 * Requirements:
 * - `account` cannot be the zero address.
 * - `account` must have at least `amount` tokens.
 * 
 * @param account The address of the token holder whose tokens will be burned.
 * @param amount The number of tokens to be destroyed from the account's balance.
 */
    function _burn(address account, uint256 amount) internal {
       require(account != address(0), "ERC20: burn from the zero address");
   
       uint256 accountBalance = _balances[account];
       require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
       unchecked {
           _balances[account] = accountBalance - amount;
           _totalSupply = _totalSupply - amount;
       }
   
       emit Burn(account, amount);
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
     * @dev Sets the maximum buy limit per transaction. Can only be called by the contract owner.
     * 
     * The `amount` entered should include the token's decimal places.
     * For example, if the token has 18 decimals, to set a limit of 500,000 tokens,
     * the `amount` should be entered as 500,000 * 10^18 (i.e., 500k tokens with decimals).
     * 
     * The function enforces a minimum buy limit of 500,000 tokens (accounting for decimals).
     * 
     * @param amount The new maximum amount allowed per transaction. This value must include decimals.
     * Emits an {UpdatedMaxAmount} event indicating the new maximum buy amount.
     */
    function setMaxBuySellLimit(uint256 amount) external onlyOwner {
        require(amount >= 5*10**5*uint256(_decimals),"You can not set max buy limit less then 500k");
        maxBuySellAmount = amount;
        emit UpdatedMaxAmount(maxBuySellAmount);
    }
   
    /**
    * @dev Sets a new development wallet address.
    * - Only callable by the contract owner.
    * - Ensures that the provided address is not the zero address.
    * - Updates the `charityWallet` state variable with the new address.
    * - Emits an `UpdatedCharityWallet` event to log the change.
    * @param wallet The new development wallet address.
    */
    function setCharityWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Charity wallet cannot be zero address");
        charityWallet = wallet;
        emit UpdatedCharityWallet(charityWallet);
    }

        /**
    * @dev Sets a new development wallet address.
    * - Only callable by the contract owner.
    * - Ensures that the provided address is not the zero address.
    * - Updates the `marketingWallet` state variable with the new address.
    * - Emits an `UpdatedMarketingWallet` event to log the change.
    * @param wallet The new development wallet address.
    */
    function setMarketingWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Charity wallet cannot be zero address");
        marketingWallet = wallet;
        emit UpdatedMarketingWallet(marketingWallet);
    }

    /**
    * @dev Sets the minimum token threshold for tax collection.
    * - Only callable by the contract owner.
    * - Ensures that the threshold is greater than zero to prevent invalid values.
    * - Updates the `taxThreshold` state variable with the new threshold.
    * - Emits an `UpdatedTaxThreshold` event to log the new threshold value.
    * @param _threshold The new tax threshold amount.
    */
    function setTaxThreshold(uint256 _threshold) external onlyOwner {
        require(_threshold > 0 , "Amount should be more than zero");
        taxThreshold = _threshold;
        emit UpatedTaxThreshold(taxThreshold);
    }

   /**
    * @dev Adds an address to the blacklist, preventing them from participating in token transfers.
    * 
    * This function is restricted to the contract owner and can only be called by the owner.
    * It ensures that the account is not already blacklisted before adding it.
    * 
    * @param account The address to be blacklisted.
    * Reverts if the account is already blacklisted.
    * 
    * @notice The blacklist is used to block suspicious or malicious addresses, often referred to as sniper bots.
    */
    function addBlackList(address account) external onlyOwner {
        require(!blacklisted[account],"User already blacklisted");
        blacklisted[account]= true;
        emit Blacklisted(account);

    }

    /**
     * @dev Removes an address from the blacklist, allowing them to participate in token transfers again.
     * 
     * This function is restricted to the contract owner and ensures that the account is currently blacklisted 
     * before removing it.
     * 
     * @param account The address to be removed from the blacklist.
     * Reverts if the account is not in the blacklist.
     * 
     * @notice This function allows the contract owner to lift the blacklist restriction on an address.
     */
    function removeBlackList(address account) external onlyOwner {
        require(blacklisted[account],"User not in blacklist");
        blacklisted[account]= false;
        emit RemoedBlacklist(account);
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
     * @dev Swaps the contract's token balance for ETH and distributes it between charity and marketing wallets.
     * 
     * The function performs the following steps:
     * - Retrieves the contract's current token balance and the ETH balance before swapping.
     * - Swaps all tokens held by the contract for ETH by calling `swapTokensForEth`.
     * - After the swap, calculates the new ETH balance by subtracting the initial ETH balance from the current balance.
     * - The ETH received is split into two equal portions for charity and marketing purposes.
     * - Transfers the respective amounts to the charity and marketing wallets, ensuring the success of the transfer.
     * 
     * @notice The function uses a gas limit of 35,000 for each wallet transfer.
     * 
     * Reverts if either the charity or marketing wallet transfer fails.
     */
    function swapAndLiquify() internal {
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance > maxBuySellAmount){
            contractTokenBalance = maxBuySellAmount;
        }
 
            uint256 initialBalance = address(this).balance;
 
            swapTokensForEth(contractTokenBalance);

            uint256 newBalance = address(this).balance - (initialBalance);

            bool transferSuccessToCharity;
            bool transferSuccessToMarketing;


            uint256 charityTaxAmount = (newBalance  * charityTaxShare) / 100;
            uint256 marketingTaxAmount = newBalance - charityTaxAmount;

            (transferSuccessToCharity,) = charityWallet.call{value: charityTaxAmount, gas: 35000}("");
            require(transferSuccessToCharity, "Transfer to charity wallet failed");

            (transferSuccessToMarketing,) = marketingWallet.call{value: marketingTaxAmount, gas: 35000}("");
            require(transferSuccessToMarketing, "Transfer to marketing wallet failed");

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
        require(!blacklisted[sender], "Sender is blacklisted");
        require(!blacklisted[recipient], "Recipient is blacklisted");
 
        //If it's the owner, do a normal transfer
        if (sender == owner() || recipient == owner() || sender == address(this)) {
            _transferTokens(sender, recipient, amount);
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