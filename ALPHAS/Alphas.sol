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
 
contract ALPHAS is Ownable {
 
    string private constant _name = "AlphasElephantCoin";
    string private constant _symbol = "ALPHAS";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 1000000000000 * 10**uint256(_decimals);
 
    uint256 public maxAmount; // Max Buy/Sell Limit
    uint256 public maxWallet; // Max tokens in wallet
 
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
  
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public _isExcludedFromFee;
    
    uint256 private launchTime;
    bool public updateFeesActive = true;
    bool public updateMaxLimitActive = true;
 
    address public marketingWallet;
    address public devWallet;
    address public charityWallet;
    address public lotteryWallet;
    address public burnWallet;
 
    uint256 public buyFee;
    uint256 public sellFee;       
 
    uint256 public marketingPercent = 20000;        //20000 = 20%
    uint256 public devPercent = 20000;              //20000 = 20%
    uint256 public charityPercent = 20000;          //20000 = 20%
    uint256 public lotteryPercent = 20000;          //20000 = 20%
    uint256 public burnPercent = 20000;             //20000 = 20%

    uint256 public marketingShare = 25000;          //25000 = 25%
    uint256 public devShare = 25000;                //25000 = 25%
    uint256 public charityShare = 25000;            //25000 = 25%
    uint256 public lotteryShare = 25000;            //25000 = 25%
 
    uint256 public _taxThreshold = 10000 * 10**uint256(_decimals); // Threshold for sending eth to wallets
 
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable _uniswapPair;
 
    bool private swapping;
    bool public swapEnabled = true;
 
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
 
 
 
    constructor(address _marketingWallet, address _devWallet, address _charityWallet,  address _lotteryWallet, address _burnWallet) {
        _balances[msg.sender] = _totalSupply;
 
        IUniswapV2Router02 _uniswapV2Router;
    
        if (block.chainid == 56) {
            _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } 
        else if (block.chainid == 97) {
            _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } 
        else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } 
        else if (block.chainid == 43114) {
            _uniswapV2Router = IUniswapV2Router02(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
        } 
        else if (block.chainid == 250) {
            _uniswapV2Router = IUniswapV2Router02(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
        } 
        else {
            revert("Chain not valid");
        }

        uniswapV2Router = _uniswapV2Router;
        
        _uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
 
        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(address(_uniswapPair), true);
 
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
        charityWallet = _charityWallet;
        lotteryWallet = _lotteryWallet;
        burnWallet = _burnWallet;
 
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[msg.sender] = true;
 
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
 
     function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != _uniswapPair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
    }

    function setExcludedFromFee(address account, bool excluded) external onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

    function setMarketingWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Marketing wallet cannot be zero address");
        marketingWallet = wallet;
    }

    function setCharityWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Charity wallet cannot be zero address");
        charityWallet = wallet;
    }

    function setLotteryWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Lottery wallet cannot be zero address");
        lotteryWallet = wallet;
    }
 
    function setDevWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Dev wallet cannot be zero address");
        devWallet = wallet;
    }

    function setBurnWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Burn wallet cannot be zero address");
        burnWallet = wallet;
    }

     function updateShares() internal {

        uint256 totalTaxPercent = marketingPercent + devPercent + charityPercent + lotteryPercent;
 
        marketingShare = (marketingPercent * 100000)/totalTaxPercent;     
        devShare = (devPercent * 100000)/totalTaxPercent;
        charityShare = (charityPercent * 100000)/totalTaxPercent;    
        lotteryShare = (lotteryPercent * 100000)/totalTaxPercent;            

    }
 
    function setBurnTaxPercentage(uint256 taxPercentage) external onlyOwner {
        require(marketingPercent + devPercent + charityPercent + lotteryPercent + burnPercent <= 100000, "Tax percentage cannot exceed 100%");
        burnPercent = taxPercentage;
    }
 
    function setMarketingPercentage(uint256 taxPercentage) external onlyOwner {
        require(marketingPercent + devPercent + charityPercent + lotteryPercent + burnPercent <= 100000, "Tax percentage cannot exceed 100%");
        marketingPercent = taxPercentage;
        updateShares();
    }

    function setDevPercentage(uint256 taxPercentage) external onlyOwner {
        require(marketingPercent + devPercent + charityPercent + lotteryPercent + burnPercent <= 100000, "Tax percentage cannot exceed 100%");
        devPercent = taxPercentage;
        updateShares();
    }

    function setCharityPercentage(uint256 taxPercentage) external onlyOwner {
        require(marketingPercent + devPercent + charityPercent + lotteryPercent + burnPercent <= 100000, "Tax percentage cannot exceed 100%");
        charityPercent = taxPercentage;
        updateShares();
    }

    function setLotteryPercentage(uint256 taxPercentage) external onlyOwner {
        require(marketingPercent + devPercent + charityPercent + lotteryPercent + burnPercent <= 100000, "Tax percentage cannot exceed 100%");
        lotteryPercent = taxPercentage;
        updateShares();
    }
 
    function setTaxThreshold(uint256 threshold) external onlyOwner {
        require(_taxThreshold <= (totalSupply() * 1000)/100000, "Tax threshold cannot be more than 1% of total supply");
        _taxThreshold = threshold;
    }


    function updateFees() internal {
        // Only run for the 24 hours after launch
        if (updateFeesActive && block.timestamp <= launchTime + 1440 minutes) {
 
            if(block.timestamp <= launchTime + 5 minutes){
                buyFee = 7000;
                sellFee = 9000;
            }
 
            else if(block.timestamp > launchTime + 5 minutes && block.timestamp <= launchTime + 15 minutes){
                buyFee = 6000;
                sellFee = 8000;
            }
 
            else if(block.timestamp > launchTime + 15 minutes && block.timestamp <= launchTime + 30 minutes){
                buyFee = 5000;
                sellFee = 7000;
            }
            else if(block.timestamp > launchTime + 30 minutes && block.timestamp <= launchTime + 120 minutes){
                buyFee = 4000;
                sellFee = 6000;      
            }
            else if(block.timestamp > launchTime + 120 minutes && block.timestamp <= launchTime + 1440 minutes){
                buyFee = 3000;
                sellFee = 5000;      
            }
            else{
                buyFee = 2000;
                sellFee = 3000; 
            }

            // Stop updating fees after 1440 minutes
            if (block.timestamp > launchTime + 1440 minutes) {
                updateFeesActive = false;
            }

        }
    }

    function updateMaxLimit() internal {
        // Only run for the 30 minutes after launch
        if (updateMaxLimitActive && block.timestamp <= launchTime + 30 minutes) {
 
            if(block.timestamp <= launchTime + 10 minutes){
                maxAmount = (totalSupply() * 280)/100000;
                maxWallet = (totalSupply() * 280)/100000;
            }
 
            else if(block.timestamp > launchTime + 10 minutes && block.timestamp <= launchTime + 20 minutes){
                maxAmount = (totalSupply() * 550)/100000;
                maxWallet = (totalSupply() * 550)/100000;
            }
 
            else if(block.timestamp > launchTime + 20 minutes && block.timestamp <= launchTime + 30 minutes){
                maxAmount = (totalSupply() * 1110)/100000;
                maxWallet = (totalSupply() * 1110)/100000;
            }
            else{
                maxAmount = totalSupply();
                maxWallet = totalSupply(); 
            }

            // Stop updating max limit after 30 minutes
            if (block.timestamp > launchTime + 30 minutes) {
                updateMaxLimitActive = false;
            }

        }
    }

    // Withdraw ERC20 tokens that are potentially stuck in Contract
    function recoverTokensFromContract(
        address _tokenAddress,
        uint256 percent
    ) external onlyOwner {
        require(
            _tokenAddress != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
 
        uint256 _tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
 
        uint256 _tokenAmount = _tokenBalance * percent / 100000;
 
        bool succ = IERC20(_tokenAddress).transfer(msg.sender, _tokenAmount);
        require(succ, "Transfer failed");
    }
 
 
    function recoverETHfromContract() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
 
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
 
    function swapTokens() internal {
 
        uint256 contractTokenBalance = balanceOf(address(this));

        uint256 initialBalance = address(this).balance;
 
        swapTokensForEth(contractTokenBalance);
 
        uint256 newBalance = address(this).balance - (initialBalance);
 
        uint256 marketingAmount = (newBalance * marketingShare)/100000;
        uint256 devAmount = (newBalance * devShare)/100000;
        uint256 charityAmount = (newBalance * charityShare)/100000;
        uint256 lotteryAmount = (newBalance * lotteryShare)/100000;

        bool success;
        bool success1;
        bool success2;
        bool success3;
 
        (success,) = marketingWallet.call{value: marketingAmount, gas: 35000}("");
        (success1,) = devWallet.call{value: devAmount, gas: 35000}("");
        (success2,) = charityWallet.call{value: charityAmount, gas: 35000}("");
        (success3,) = lotteryWallet.call{value: lotteryAmount, gas: 35000}("");
 
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
            address(this),
            block.timestamp
        );
    }
 
 function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
 
        //If it's the owner, do a normal transfer
        if (sender == owner() || recipient == owner() || sender == address(this)) {
            if(launchTime == 0 && recipient == _uniswapPair){
                launchTime = block.timestamp;
                updateFees();
                updateMaxLimit();
            }
            _transferTokens(sender, recipient, amount);
            return;
        }

        updateFees();
        updateMaxLimit();
 
        bool isBuy = sender == _uniswapPair;
        bool isSell = recipient == _uniswapPair;
 
        uint256 burnTax;
        uint256 buyTax;
        uint256 sellTax;
 
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= _taxThreshold;
 
        if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[sender] &&
            !_isExcludedFromFee[sender] &&
            !_isExcludedFromFee[recipient]
        ) {
            swapping = true;
            swapTokens();
            swapping = false;
 
        }
 
        bool takeFee = !swapping;
 
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }
 
        uint256 fees = 0;
 
        if (takeFee) {
            if (automatedMarketMakerPairs[sender] && isBuy) {
                if (!_isExcludedFromFee[recipient]){
                    require (amount <= maxAmount, "Cannot buy more than max limit");
                    require(balanceOf(recipient) <= maxWallet, "Cannot hold more tokens than limit");
                    buyTax = _calculateTax(amount, buyFee);
                    burnTax = _calculateTax(buyTax, burnPercent);
                    _transferTokens(sender, address(this), buyTax - burnTax); 
                    _burnTokens(sender, burnWallet, burnTax);
                }
                fees = buyTax;
 
            } 
            else if (automatedMarketMakerPairs[recipient] && isSell) {
                if (!_isExcludedFromFee[sender]){
                    require (amount <= maxAmount, "Cannot sell more than max limit");
                    require(balanceOf(recipient) <= maxWallet, "Cannot hold more tokens than limit");
                    sellTax = _calculateTax(amount, sellFee);
                    burnTax = _calculateTax(sellTax, burnPercent);
                    _transferTokens(sender, address(this), sellTax - burnTax); 
                    _burnTokens(sender, burnWallet, burnTax);
                }
                fees = sellTax;
            }
            amount -= fees;
        }
        _transferTokens(sender, recipient, amount);
 
    }
 
    function _calculateTax(uint256 amount, uint256 taxPercentage) internal pure returns (uint256) {
        return amount * (taxPercentage) / (100000);
    }
 
    fallback() external payable {}
 
    receive() external payable {}
}
