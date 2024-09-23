                              
/**
        ███████╗ ██████╗  ██████╗ ██████╗     ███████╗ ██████╗ ██████╗      █████╗ ██╗     ██╗     
        ██╔════╝██╔═══██╗██╔═══██╗██╔══██╗    ██╔════╝██╔═══██╗██╔══██╗    ██╔══██╗██║     ██║     
        █████╗  ██║   ██║██║   ██║██║  ██║    █████╗  ██║   ██║██████╔╝    ███████║██║     ██║     
        ██╔══╝  ██║   ██║██║   ██║██║  ██║    ██╔══╝  ██║   ██║██╔══██╗    ██╔══██║██║     ██║     
        ██║     ╚██████╔╝╚██████╔╝██████╔╝    ██║     ╚██████╔╝██║  ██║    ██║  ██║███████╗███████╗
        ╚═╝      ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝      ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚══════╝                                                                                       
*/   
// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

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
 * @title Context
 * @dev The base contract that provides information about the message sender
 * and the calldata in the current transaction.
 */

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Locked(address owner, address newOwner,uint256 lockTime);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
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
}

/**
 * @title IUniswapV2Factory
 * @dev Interface for the Uniswap V2 Factory contract.
 */

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

/**
 * @title IUniswapV2Router01
 * @dev Interface for the Uniswap V2 Router version 01 contract.
*/
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    //WETH function that return const value,  rather than performing some state-changing operation. 
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

/**
 * @title IUniswapV2Router02
 * @dev Interface for the Uniswap V2 Router version 02 contract.
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

contract FoodToken is Context, IERC20, Ownable {
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 500 * 10**6 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
   
    string  private constant NAME = "Food For All";
    string  private  constant SYMBOL = "FOOD";
    uint8   private constant DECIMALS = 18;
    uint256 private refAmt;

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    //Buy tax percentage
    uint256 public constant BUYREFLECTIONTAX=0;
    //sell tax percentage
    uint256 public  constant SELLREFLECTIONTAX = 50;
 
    event ReflectedFee(uint256 totalReflectFee);
    event Burn(address,uint256);

    /**
    * @dev Constructor that initializes the total supply of tokens.
    * The total reflection supply (_rTotal) is assigned to the contract deployer (_msgSender()).
    * An initial Transfer event is emitted from the zero address to the contract deployer
    * for the total token supply (_tTotal).
    */
    constructor ()
    {
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }   
    
    /**
    * @dev Sets the Uniswap router and creates a pair for this token if it doesn't already exist.
    * If the pair already exists, it will use the existing pair instead of creating a new one.
    *
    * @param _router The address of the UniswapV2 router.
    */
    function setRouter(address _router)external  onlyOwner{
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
         // Check if the pair is already created
        address pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .getPair(address(this), _uniswapV2Router.WETH());
    
        // If the pair doesn't exist, create it
        if (pair == address(0)) {
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        } else {
            // Pair already exists, use the existing pair
            uniswapV2Pair = pair;
        }
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        excludeFromReward(uniswapV2Pair);
        _isExcludedFromFee[address(this)] = true;
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
        return DECIMALS;
    }

    /**
    * @notice Retrieves the total supply of tokens.
    * @dev This function returns the total supply of tokens in circulation.
    * @return The total supply of tokens.
    */
    function totalSupply() external view override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) external override returns (bool) {
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
    function allowance(address owner, address spender) external view override returns (uint256) {
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
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]-amount);
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
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]-subtractedValue);
        return true;
    }
     
    /**
    * @dev Function that allows the caller to burn a specified amount of tokens.
    * This permanently reduces the total supply of tokens. The caller's balance is reduced
    * by the burn amount, and both the total token supply and the reflection supply are adjusted.
    * 
    * @param amount The amount of tokens to burn.
    */ 
    function burn(uint256 amount) external {
        address sender = _msgSender();
        
        // Ensure the sender has enough tokens to burn
        require(balanceOf(sender) >= amount, "Insufficient balance to burn");
        
        uint256 burnAmount = amount;
        uint256 rAmount = burnAmount * _getRate();
        
        // Directly adjust the sender's balance and the total token supply
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tTotal = _tTotal - burnAmount;
         
        // Emit the burn event
        emit Burn(sender, burnAmount);
    }

    /**
    * @dev Function that returns the total amount of fees collected.
    * This tracks the cumulative fees that have been deducted from all token transactions.
    * 
    * @return The total amount of fees collected in tokens.
    */
    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    /**
    * @dev Function that allows a non-excluded address to deliver tokens and reduce the reflection supply.
    * The tokens are deducted from the sender's balance and added to the total fees collected, 
    * effectively reducing the total reflection supply.
    * 
    * @param tAmount The amount of tokens to deliver.
    */
    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,) = _getValue(tAmount);
        _rOwned[sender] = _rOwned[sender]-rAmount;
        _rTotal = _rTotal-rAmount;
        _tFeeTotal = _tFeeTotal+tAmount;
    }

    /**
    * @dev Function to convert a given amount of tokens to the corresponding amount of reflections.
    * It returns the reflection value based on whether the transfer fee should be deducted or not.
    * 
    * @param tAmount The amount of tokens to convert to reflections.
    * @param deductTransferFee A boolean indicating whether to deduct the transfer fee or not.
    * @return The corresponding amount of reflections.
    */
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {
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
    * @dev Function to convert a given amount of reflections to the corresponding amount of tokens.
    * This is the inverse operation of the reflectionFromToken function. It calculates the token amount
    * based on the current reflection rate.
    * 
    * @param rAmount The amount of reflections to convert to tokens.
    * @return The corresponding amount of tokens.
    */
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }
    
    /**
    * @dev Excludes an account from receiving rewards.
    * If the account holds tokens, it converts their reflection balance
    * to the actual token balance before exclusion.
    * The account is then marked as excluded, and added to the list of excluded accounts.
    *
    * @param account The address of the account to be excluded from rewards.
    */
    function excludeFromReward(address account) private {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    
    /**
    * @dev Excludes the specified account from transaction fees.
    * Only the contract owner can call this function.
    * 
    * @param account The address of the account to exclude from fees.
    */
    function excludeFromFee(address account) external  onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    /**
    * @dev Includes the specified account in transaction fees.
    * Only the contract owner can call this function.
    * 
    * @param account The address of the account to include in fees.
    */
    function includeInFee(address account) external  onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    /**
    * @dev Checks if the specified account is excluded from transaction fees.
    * This function can be called by anyone.
    * 
    * @param account The address of the account to check.
    * @return bool Returns true if the account is excluded from fees, false otherwise.
    */
    function isExcludedFromFee(address account) external  view returns(bool) {
        return _isExcludedFromFee[account];
    }
    /**
    * @dev Internal function to handle the reflection of fees. 
    * It updates the total reflection supply and total fees collected. 
    * This function is used to adjust the reflection and fee totals after a transaction.
    * 
    * @param rFee The amount of reflections to deduct from the total reflection supply.
    * @param tFee The amount of tokens to add to the total fees collected.
    */
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee ;
        _tFeeTotal = _tFeeTotal + tFee ;
       
        emit ReflectedFee(tFee);
    }

    /**
    * @dev Internal function to calculate and return the token transfer amount and fee.
    * It calls the _getTValues function to obtain the transfer amount and fee based on the 
    * specified token amount.
    * 
    * @param tAmount The amount of tokens to process.
    * @return tTransferAmount The amount of tokens to be transferred after fees.
    * @return tFee The amount of fees to be deducted from the total token amount.
    */
    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount); 
        return ( tTransferAmount, tFee);
    }

    /**
    * @dev Internal function to calculate and return the reflection amounts corresponding to a given token amount.
    * It first determines the fee associated with the token amount, and then calculates the reflection values
    * based on that fee. This function uses _getTValues to get the fee and _getRValues to get the reflection amounts.
    * 
    * @param tAmount The amount of tokens to process.
    * @return rAmount The corresponding reflection amount before fees.
    * @return rTransferAmount The corresponding reflection amount after fees.
    */
    function _getValue(uint256 tAmount) private view returns(uint256, uint256){
        (, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount,) = _getRValues(tAmount, tFee);
         return (rAmount, rTransferAmount);
    }

    /**
    * @dev Internal function to calculate and return the token transfer amount and tax fee.
    * It computes the fee based on the total token amount and then determines the amount
    * of tokens that will be transferred after deducting the tax fee.
    * 
    * @param tAmount The total amount of tokens to process.
    * @return tTransferAmount The amount of tokens to be transferred after deducting the tax fee.
    * @return tFee The amount of tax fee deducted from the total token amount.
    */
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee;
        return (tTransferAmount, tFee);
    }

    /**
    * @dev Internal function to calculate reflection amounts based on a token amount and fee.
    * It returns the total reflection amount, the amount after deducting the fee, and the reflection fee.
    * 
    * @param tAmount The token amount.
    * @param tFee The token fee.
    * @return rAmount Total reflection amount.
    * @return rTransferAmount Reflection amount after fee.
    * @return rFee Reflection fee amount.
    */
    function _getRValues(uint256 tAmount, uint256 tFee) private view returns (uint256, uint256, uint256) {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rTransferAmount = rAmount - rFee;
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
        return rSupply / tSupply;
    }

    /**
    * @dev Internal function to calculate the current reflection and token supplies.
    * It adjusts for excluded addresses by subtracting their reflection and token balances.
    * If the adjusted supplies are less than the initial values, it returns the original total supplies.
    * 
    * @return rSupply The current reflection supply.
    * @return tSupply The current token supply.
    */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    /**
    * @dev Calculates the tax fee for reflection based on a specified amount.
    * @param amount Amount for tax fee calculation.
    * @return Calculated tax fee amount.
    * 
    * @notice Internal use only.
    */
    function calculateTaxFee(uint256 amount) private view returns (uint256) {
        return amount * refAmt / 10**2;
    }
    
    /**
    * @dev Internal function to reset all fee-related values.
    * This function sets the reference amount (refAmt) to zero.
    */
    function removeAllFee() private {
            refAmt = 0; 
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
    * @notice This function is intended for internal use and should not be called directly.
    */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
    * @dev Internal function to handle the transfer of tokens between addresses.
    * It includes checks for the validity of addresses and transfer amount,
    * manages fees based on the sender and receiver, and invokes the 
    * _tokenTransfer function to complete the transfer.
    * 
    * @param from The address sending the tokens.
    * @param to The address receiving the tokens.
    * @param amount The amount of tokens to transfer.
    */
    function _transfer( address from, address to, uint256 amount ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        //if takeFee is true then set sell or buy tax percentage
        if(takeFee)
        _sellBuyTax(from,to); 
       _tokenTransfer(from,to,amount,takeFee);
    }
    
    /**
    * @dev Internal function to apply the appropriate tax based on whether the transaction is a buy or a sell.
    * It adjusts the reflection tax percentage based on the type of transaction and whether it is a buy,
    * a sell, or a regular transfer.
    * 
    * @param from The address sending the tokens.
    * @param to The address receiving the tokens.
    */
    function _sellBuyTax(address from, address to) private {
        //sell and buy logic
        bool isBuy = from == uniswapV2Pair;
        bool isSell = to == uniswapV2Pair;
              
            if (isBuy) {    
              refAmt = BUYREFLECTIONTAX; //0
            } 
            else if (isSell) {
              refAmt = SELLREFLECTIONTAX; //50%           
            }
            else {
              removeAllFee();
            }
    } 

    /**
    * @dev Internal function to handle token transfers, including applying fees and handling exclusions.
    * It delegates the transfer to different methods based on whether the sender and recipient are excluded
    * from fees and whether fees should be applied.
    * 
    * @param sender The address sending the tokens.
    * @param recipient The address receiving the tokens.
    * @param amount The amount of tokens to transfer.
    * @param takeFee Boolean indicating whether fees should be applied.
    */
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
    * @dev Internal function to handle token transfers between two excluded addresses.
    * It calculates the reflection and token values, updates the balances of both sender and recipient,
    * reflects the fee, and emits the transfer event.
    * 
    * @param sender The address sending the tokens.
    * @param recipient The address receiving the tokens.
    * @param tAmount The amount of tokens to transfer.
    */
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee);
        _tOwned[sender] = _tOwned[sender]-tAmount;
        _rOwned[sender] = _rOwned[sender]-rAmount;
        _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient]+rTransferAmount;        
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
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
    * @notice This function is intended for internal use and should not be called directly.
    */
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee);
        _rOwned[sender] = _rOwned[sender]-rAmount;
        _rOwned[recipient] = _rOwned[recipient]+rTransferAmount;
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    /**
    * @dev Internal function to handle token transfers from a regular address to an excluded address.
    * It calculates the reflection and token values, updates the balances of the sender and excluded recipient,
    * reflects the fee, and emits the transfer event.
    * 
    * @param sender The address sending the tokens.
    * @param recipient The excluded address receiving the tokens.
    * @param tAmount The amount of tokens to transfer.
    */
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee);
        _rOwned[sender] = _rOwned[sender]-rAmount;
        _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient]+rTransferAmount;           
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
    * @dev Internal function to handle token transfers from an excluded address to a regular address.
    * It calculates the reflection and token values, updates the balances of the excluded sender and regular recipient,
    * reflects the fee, and emits the transfer event.
    * 
    * @param sender The excluded address sending the tokens.
    * @param recipient The regular address receiving the tokens.
    * @param tAmount The amount of tokens to transfer.
    */
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee);
        _tOwned[sender] = _tOwned[sender]-tAmount;
        _rOwned[sender] = _rOwned[sender]-rAmount;
        _rOwned[recipient] = _rOwned[recipient]+rTransferAmount;   
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
}
