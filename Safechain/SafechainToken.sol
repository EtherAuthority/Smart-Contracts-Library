/** 
                            ███████╗ █████╗ ███████╗███████╗ ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗
                            ██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝██║  ██║██╔══██╗██║████╗  ██║
                            ███████╗███████║█████╗  █████╗  ██║     ███████║███████║██║██╔██╗ ██║
                            ╚════██║██╔══██║██╔══╝  ██╔══╝  ██║     ██╔══██║██╔══██║██║██║╚██╗██║
                            ███████║██║  ██║██║     ███████╗╚██████╗██║  ██║██║  ██║██║██║ ╚████║
                            ╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝                                                                 
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

contract SafeChainToken is Context, IERC20, Ownable {

    mapping (address => uint256) public _rOwned;
    mapping (address => uint256) public _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 21 * 10**6 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "SafeChain";
    string private _symbol = "SFC";
    uint8 private _decimals = 18;
    
    uint256 public _taxFee = 250; //  0.25%
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 250; // 0.25%
    uint256 private _previousLiquidityFee = _liquidityFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
  
    uint256 public taxThreshold = 5 * 10**6 * 10**18;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    /**
    * @dev Constructor function that initializes the contract.
    * - Assigns the total reflection tokens to the owner (initial supply).
    * - Initializes UniswapV2Router with the address of the router on Binance Smart Chain Testnet (modify for mainnet).
    * - Creates a Uniswap pair for this token and WETH.
    * - Excludes the owner and this contract from fees.
    * - Excludes the Uniswap pair and this contract from rewards.
    * - Emits a Transfer event indicating the initial supply allocation.
    */
    constructor ()  {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);// BSC testnet Router >>here you can change accroding your network.
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        excludeFromReward(uniswapV2Pair);
        excludeFromReward(address(this));
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
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _rTotal = _rTotal-(rAmount);
        _tFeeTotal = _tFeeTotal + (tAmount);
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
            (uint256 rAmount,,,,,) = _getValues(tAmount);
             return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
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
        return rAmount / (currentRate);
    }

    /**
    * @notice Grants the owner the ability to exclude an address from earning reflections.
    * @dev Reflections are often used in tokenomics to distribute rewards to holders.
    * This function excludes the specified address from receiving reflections.
    * @param account The address to be excluded from earning reflections.
    */
    function excludeFromReward(address account) public onlyOwner() {
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
    * @dev Allows the owner to set the tax fee percentage.
    * @param taxFee The new tax fee percentage to be applied to transactions.
    * - This function can only be called by the contract owner.
    */
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
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
        // emit UpatedTaxThreshold(taxThreshold);
    }
    
    /**
    * @dev Allows the owner to set the liquidity fee percentage.
    * @param liquidityFee The new liquidity fee percentage to be applied to transactions.
    * - This function can only be called by the contract owner.
    */
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }
   
    /**
    * @dev Enables or disables swap and liquify.
    */
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
    
    /**
    * @dev Applies reflection by reducing the total reflection supply and increasing the total fee.
    */
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - (rFee);
        _tFeeTotal = _tFeeTotal + (tFee);
    }
    
    /**
    * @dev Calculates the reflection and transfer values for a given token amount.
    * 
    * @param tAmount The total token amount for which values are to be calculated.
    * @return rAmount The corresponding reflection amount.
    * @return rTransferAmount The reflection amount after fees.
    * @return rFee The reflection fee amount.
    * @return tTransferAmount The token amount to be transferred after fees.
    * @return tFee The fee amount in tokens.
    * @return tLiquidity The liquidity amount in tokens.
    */
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount - (tFee) - (tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    /**
    * @dev Calculates the transfer values for a given token amount.
    * 
    * @param tAmount The total token amount for which values are to be calculated.
    * @return tTransferAmount The token amount to be transferred after fees.
    * @return tFee The fee amount in tokens.
    * @return tLiquidity The liquidity amount in tokens.
    */
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * (currentRate);
        uint256 rFee = tFee * (currentRate);
        uint256 rLiquidity = tLiquidity * (currentRate);
        uint256 rTransferAmount = rAmount - (rFee) - (rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    /**
    * @dev Calculates the current reflection rate based on the supply.
    * 
    * @return The reflection rate, calculated as the ratio of reflection supply to token supply.
    */
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / (tSupply);
    }

    /**
    * @dev Calculates the current reflection and token supply, adjusting for excluded accounts.
    * 
    * @return rSupply The adjusted reflection supply after excluding certain accounts.
    * @return tSupply The adjusted token supply after excluding certain accounts.
    */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - (_rOwned[_excluded[i]]);
            tSupply = tSupply - (_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal / (_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    /**
    * @dev Takes liquidity by updating the reflection and token balances for the contract.
    * 
    * @param tLiquidity The amount of liquidity to be taken (in tokens).
    */
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * (currentRate);
        _rOwned[address(this)] = _rOwned[address(this)] + (rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + (tLiquidity);
    }
    
    /**
    * @dev Calculates the tax fee based on the given amount.
    * 
    * @param _amount The amount on which the tax fee is to be calculated.
    * @return The calculated tax fee.
    */
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount * (_taxFee)/(
            10**5
        );
    }
 
    /**
    * @dev Calculates the liquidity fee based on the given amount.
    * 
    * @param _amount The amount on which the liquidity fee is to be calculated.
    * @return The calculated liquidity fee.
    */
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount*(_liquidityFee)/(
            10**5
        );  
    }
    
    /**
    * @dev Temporarily removes all fees by setting tax and liquidity fees to zero.
    * 
    * This function saves the previous fee values so they can be restored later.
    */
    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        
        _taxFee = 0;
        _liquidityFee = 0;
    }
    
    /**
    * @dev Restores the previous tax and liquidity fees.
    * 
    * This function is used to revert the fees to their values before they were removed.
    */
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }
  
    /**
    * @dev Checks if a given account is excluded from fees.
    * 
    * @param account The address to check for fee exclusion.
    * @return A boolean indicating whether the account is excluded from fees.
    */
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    /**
    * @dev Sets the allowance of a spender for a specified owner.
    * 
    * This function is used to approve a spender to spend a certain amount of tokens on behalf of the owner.
    * 
    * @param owner The address of the token owner.
    * @param spender The address of the account that will be allowed to spend the tokens.
    * @param amount The amount of tokens to be approved for spending.
    */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
    * @dev Handles the transfer of tokens from one address to another.
    * 
    * This function checks various conditions, manages fees, and performs the transfer.
    * 
    * @param from The address sending the tokens.
    * @param to The address receiving the tokens.
    * @param amount The amount of tokens to be transferred.
    */
    function _transfer( address from, address to, uint256 amount ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        uint256 contractTokenBalance = balanceOf(address(this));
           
        bool overMinTokenBalance = contractTokenBalance >= taxThreshold;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = taxThreshold;
            // auto liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }
    
    /**
    * @dev Swaps a portion of the contract's tokens for ETH and adds liquidity to Uniswap.
    * 
    * This function splits the contract's token balance into two halves: 
    * one half is swapped for ETH, and the other half is added as liquidity.
    * 
    * @param contractTokenBalance The total token balance held by the contract.
    */
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance/(2);
        uint256 otherHalf = contractTokenBalance - (half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - (initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    
    /**
    * @dev Swaps a specified amount of tokens for ETH using Uniswap.
    * 
    * This function approves the Uniswap router to spend the tokens and performs
    * the token-to-ETH swap, allowing for any amount of ETH to be accepted.
    * 
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
    * @dev Adds liquidity to Uniswap by depositing a specified amount of tokens and ETH.
    * 
    * This function approves the Uniswap router to spend the tokens and adds
    * the specified amounts of tokens and ETH as liquidity to the pool.
    * 
    * @param tokenAmount The amount of tokens to be added as liquidity.
    * @param ethAmount The amount of ETH to be added as liquidity.
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
    * @dev Manages the transfer of tokens between accounts, applying fees based on exclusions.
    * 
    * @param sender The address sending the tokens.
    * @param recipient The address receiving the tokens.
    * @param amount The amount of tokens to transfer.
    * @param takeFee Indicates whether to apply fees.
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
        
        if(!takeFee)
            restoreAllFee();
    }

    /**
    * @dev Transfers tokens between two excluded addresses, updates balances,
    * takes liquidity, reflects fees, and emits a transfer event.
    *
    * @param sender Address sending the tokens.
    * @param recipient Address receiving the tokens.
    * @param tAmount Amount of tokens to transfer.
    */
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - (tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _tOwned[recipient] = _tOwned[recipient] + (tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    /**
    * @dev Handles the standard transfer of tokens between two addresses,
    * updating balances, taking liquidity, reflecting fees, and emitting a transfer event.
    *
    * @param sender Address sending the tokens.
    * @param recipient Address receiving the tokens.
    * @param tAmount Amount of tokens to transfer.
    */
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
    * @dev Transfers tokens from an included account to an excluded account,
    * updating balances, taking liquidity, reflecting fees, and emitting a transfer event.
    *
    * @param sender Address sending the tokens.
    * @param recipient Address receiving the tokens (excluded).
    * @param tAmount Amount of tokens to transfer.
    */
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _tOwned[recipient] = _tOwned[recipient] + (tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**
    * @dev Transfers tokens from an excluded account to an included account,
    * updating balances, taking liquidity, reflecting fees, and emitting a transfer event.
    *
    * @param sender Address sending the tokens (excluded).
    * @param recipient Address receiving the tokens.
    * @param tAmount Amount of tokens to transfer.
    */
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - (tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}