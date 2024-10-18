/* 
                        
                        ██████╗  ██████╗  ██████╗ ███████╗ ██████╗ █████╗ ████████╗
                        ██╔══██╗██╔═══██╗██╔════╝ ██╔════╝██╔════╝██╔══██╗╚══██╔══╝
                        ██║  ██║██║   ██║██║  ███╗█████╗  ██║     ███████║   ██║   
                        ██║  ██║██║   ██║██║   ██║██╔══╝  ██║     ██╔══██║   ██║   
                        ██████╔╝╚██████╔╝╚██████╔╝███████╗╚██████╗██║  ██║   ██║   
                        ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   
                                                           
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

contract DogeCatToken is Ownable,IERC20 {

    string private constant _name = "DogeCat Token";
    string private constant _symbol = "DOGECAT";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 300 * 10**12 * 10**uint256(_decimals);

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public marketingWallet;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public  buyTaxPercentage = 0;         
    uint256 public  marketingPercentage = 5;   
    uint256 public  burnTaxPercentage = 1;  

    //event
    event UpdatedMarketingWallet(address updatedMarketingWallet);
    event UpdatedBuyTax(uint256 updatedBuyTax);
    event UpdatedSellTax(uint256 updatedSellTax);
    event UpdatedMarketingTax(uint256 updatedMarketingTax);
    event UpdatedBurnTax(uint256 updatedBurnTax);

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapPair;

    constructor(address _marketingWallet) {
        _balances[msg.sender] = _totalSupply;
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //BSC Testnet

        );
        uniswapV2Router = _uniswapV2Router;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        
        marketingWallet = _marketingWallet;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
    * @notice Retrieves the name of the token.
    * @dev This function returns the name of the token, which is often used for identification.
    * It is commonly displayed in user interfaces and provides a human-readable name for the token.
    * @return The name of the token.
    */
    function name() external view virtual  returns (string memory) {
        return _name;
    }
 
    /**
    * @notice Retrieves the symbol or ticker of the token.
    * @dev This function returns the symbol or ticker that represents the token.
    * It is commonly used for identifying the token in user interfaces and exchanges.
    * @return The symbol or ticker of the token.
    */
    function symbol()external view virtual  returns (string memory) {
        return _symbol;
    }
 
    /**
    * @notice Retrieves the number of decimal places used in the token representation.
    * @dev This function returns the number of decimal places used to represent the token balances.
    * It is commonly used to interpret the token amounts correctly in user interfaces.
    * @return The number of decimal places used in the token representation.
    */
    function decimals()external view virtual  returns (uint8) {
        return _decimals;
    }
  
    /**
    * @notice Retrieves the total supply of tokens.
    * @dev This function returns the total supply of tokens in circulation.
    * @return The total supply of tokens.
    */
    function totalSupply() external view virtual  returns (uint256) {
        return _totalSupply;
    }
 
    /**
    * @notice Returns the balance of the specified account.
    * @param account The address for which the balance is being queried.
    * @return The balance of the specified account.
    */   
    function balanceOf(
        address account
    ) external view virtual  returns (uint256) {
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
    ) external virtual  returns (bool) {
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
    ) external virtual  returns (bool) {
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
    * @dev Internal function to burn tokens from an account and transfer them to a designated 'dead' address.
    * This reduces the total supply of the token.
    * 
    * @param account The address from which the tokens are burned.
    * @param dead The designated address where the burned tokens will be sent.
    * @param amount The number of tokens to be burned.
    */
    function _burnTokens(address account, address dead, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] -= amount;
            _balances[dead] += amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

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
    * @dev External function to calculate and return the total sell tax.
    * The total sell tax is the sum of the marketing percentage and the burn tax percentage.
    * 
    * @return The total sell tax as a percentage.
    */    
    function totalSellTax()external view returns(uint256){
        uint256 totalTax= marketingPercentage + burnTaxPercentage;
        return totalTax;
    }

    /**
    * @dev External function to set the marketing wallet address. 
    * Only the contract owner can call this function.
    * 
    * @param wallet The new address for the marketing wallet. It cannot be the zero address.
    */
    function setMarketingWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Marketing wallet cannot be zero address");
        marketingWallet = wallet;
        emit UpdatedMarketingWallet(wallet);
    }

    /**
    * @dev External function to set the buy tax percentage.
    * Only the contract owner can call this function.
    * 
    * @param taxPercentage The new buy tax percentage. It cannot exceed 25%.
    */
    function setBuyTaxPercentage(uint256 taxPercentage) external onlyOwner {
        require(taxPercentage <= 25, "Tax percentage cannot exceed 25%");
        buyTaxPercentage = taxPercentage;
        emit UpdatedBuyTax(taxPercentage);
    }

    function setMarketingPercentage(uint256 taxPercentage) external onlyOwner {
        require(taxPercentage <= 25, "Tax percentage cannot exceed 25%");
        marketingPercentage = taxPercentage;
        emit UpdatedMarketingTax(taxPercentage);
    }

    /**
    * @dev External function to set the marketing tax percentage.
    * Only the contract owner can call this function.
    * 
    * @param taxPercentage The new marketing tax percentage. It cannot exceed 25%.
    */
    function setBurnTaxPercentage(uint256 taxPercentage) external onlyOwner {
        require(taxPercentage <= 25, "Tax percentage cannot exceed 25%");
        burnTaxPercentage = taxPercentage;
        emit UpdatedBurnTax(taxPercentage);
    }

    /**
    * @dev Internal function to handle token transfers, applying taxes during buys and sells.
    * 
    * This function distinguishes between normal transfers, buy operations (when tokens are purchased from a Uniswap pair),
    * and sell operations (when tokens are sold to a Uniswap pair). During sell operations, it applies marketing and burn
    * taxes, transferring the appropriate amounts to the marketing wallet and a dead address for token burning.
    * 
    * Special cases include transfers involving the contract owner or the contract itself, which bypass tax calculations.
    * 
    * @param sender The address sending the tokens. Must not be the zero address.
    * @param recipient The address receiving the tokens. Must not be the zero address.
    * @param amount The number of tokens being transferred. Must be greater than zero.
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

        bool isBuy = sender == uniswapPair;
        bool isSell = recipient == uniswapPair;

        uint256 buyTax;
        uint256 marketingTax;
        uint256 burnTax;

        if(isBuy){

            buyTax = _calculateTax(amount, buyTaxPercentage);

        }else if(isSell){
            marketingTax = _calculateTax(amount, marketingPercentage);
            burnTax = _calculateTax(amount, burnTaxPercentage);
            _transferTokens(sender, marketingWallet, marketingTax); // send marketing tax to marketingWallet
            _burnTokens(sender, DEAD, burnTax); // send burn tax to dead wallet
        }

        uint256 transferAmount = amount - (buyTax) - (marketingTax)- (burnTax);
        _transferTokens(sender, recipient, transferAmount); // send to recipient        

    }

    /**
    * @dev Calculates the tax based on the amount and tax percentage.
    * @param amount The amount to apply the tax on.
    * @param taxPercentage The tax rate as a percentage.
    * @return The calculated tax.
    */
    function _calculateTax(uint256 amount, uint256 taxPercentage) internal pure returns (uint256) {
        return amount * (taxPercentage) / (100);
    }

    /**
    * @dev Allows the contract to receive Ether. 
    * This function is called when Ether is sent directly to the contract.
    */
    receive() external payable {}
}