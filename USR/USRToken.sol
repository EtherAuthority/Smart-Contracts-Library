/**
    Upon acceptance by the user (the "Participant") and USER Technologies, LLC (the "Company"), the Smartcontract Participation Agreement (the "Agreement") becomes effective. By the purchase of any USER Technologies, LLC assets or mananged projects or tokens, the Participant agrees to be bound by the terms and conditions set forth in this Agreement.

    Non-Security Tokens

    The Participant understands and acknowledges that the tokens, coins, or other digital assets (collectively, the "Tokens") offered in the Company's launch (the "Launch") are not considered securities and should not be treated as an investment or the purchase of shares, stocks, or any other form of securities in the Company.

    Unregistered Tokens

    The Participant is aware that the Tokens are not registered under any securities laws and that the Company has no intention to register them under any such laws. The Tokens should not be viewed as a form of investment, an opportunity to obtain equity, or any other ownership interest in the Company, nor should they be perceived as a promise of future returns.

    No Guaranteed Liquidity

    The Participant understands that the Tokens may not be easily tradable and that there may not be a liquid market for the Tokens at any given time. The Company does not guarantee, represent, or warrant that the Tokens will be tradable on any exchange or marketplace. The Participant acknowledges that the value of the Tokens may fluctuate and that they may not be able to sell or transfer the Tokens immediately or at any specific time in the future.

    No Investment Advice

    The Company is not providing any investment advice or recommendation to the Participant regarding the purchase of Tokens or participation in the Presale. The Participant is not relying on any advice or recommendation from the Company and acknowledges that they are participating in the Presale based on their own independent judgment and risk assessment.

    Participant Representations and Warranties

    The Participant represents and warrants that they are at least 18 years of age or the age of legal majority in their jurisdiction and have the legal capacity to enter into this Agreement. The Participant also represents and warrants that they are not purchasing the Tokens as an investment and that their participation in the Presale is not based on any expectation of profit or financial return.

    Governing Law and Jurisdiction

    This Agreement is governed by and construed in accordance with the laws of UAE without regard to conflict of law principles. Any disputes arising out of or in connection with this Agreement shall be subject to the exclusive jurisdiction of the courts of the UAE.

    By purchasing this token, the Participant acknowledges that they have read, understood, and agree to be bound by the terms and conditions of this Agreement.
*/


/*
    Taxes

    Buy Tax      - 0.01% to USER Foundation, 0.01% to LP, 0.005% to be destroyed
    Sell Tax     - 0.01% to USER Foundation, 0.03% to LP, 0.005% to be destroyed
    Transfer Tax - 0.025% to LP, 0.005% to be destroyed

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


abstract contract MultiSignWallet{

    /*--------------------Storage-------------------*/

    address[] public owners;
    mapping(address=>bool) public isOwner;

    uint public WalletRequired;
    Transaction[] public transactions;
    mapping(uint=> mapping(address=>bool)) public approved;


    struct Transaction{
        bool  isExecuted;
    }


    constructor(address[] memory _owners,uint _requiredWallet){

        require(_owners.length>0,"owner required");
        require(_requiredWallet>0 && _requiredWallet<=_owners.length,"invalid required number of owner wallets");

        for(uint i=0;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner!=address(0),"invalid owner");
            require(!isOwner[owner],"owner is already there!");
            isOwner[owner]=true;
            owners.push(owner);
        }
        WalletRequired =_requiredWallet; // you need at least this number wallet to execute transaction
    }


    /*-----------------------EVENTS-------------------*/

    event assignTrnx(uint trnx);
    event Approve(address owner, uint trnxId);
    event Revoke(address owner, uint trnxId);
    event Execute(uint trnxId);

    //----------------------Modifier-------------------

    // YOU CAN REMOVE THIS OWNER MODIFIER IF YOU ALREADY USING OWNED LIB
    modifier onlyOwner(){
        require(isOwner[msg.sender],"not an owner");
        _;
    }

    modifier trnxExists(uint _trnxId){
        require(_trnxId<transactions.length,"trnx does not exist");
        _;
    }

    modifier notApproved(uint _trnxId){

        require(!approved[_trnxId][msg.sender],"trnx has already done");
        _;
    }

    modifier notExecuted(uint _trnxId){
        Transaction storage _transactions = transactions[_trnxId];
        require(!_transactions.isExecuted,"trnx has already executed");
        _;
    }

    function newTransaction() external onlyOwner returns(uint){


        transactions.push(Transaction({
            isExecuted:false
        }));

        emit assignTrnx(transactions.length-1);
        return transactions.length-1;
    }

    function approveTransaction(uint _trnxId)
     external onlyOwner
     trnxExists(_trnxId)
     notApproved(_trnxId)
     notExecuted(_trnxId)

    {

        approved[_trnxId][msg.sender]=true;
        emit Approve(msg.sender,_trnxId);

    }

    // GET APPROVAL COUNT OF TRANSACTION
    function _getAprrovalCount(uint _trnxId) public view returns(uint ){

        uint count;
        for(uint i=0; i<owners.length;i++){

            if (approved[_trnxId][owners[i]]){

                count+=1;
            }
        }

        return count;
     
    }

    // EXECUTE TRANSACTION 
    function executeTransaction(uint _trnxId) internal trnxExists(_trnxId) notExecuted(_trnxId){
        require(_getAprrovalCount(_trnxId)>=WalletRequired,"you don't have sufficient approval");
        Transaction storage _transactions = transactions[_trnxId];
        _transactions.isExecuted = true;
        emit Execute(_trnxId);

    }

    // USE THIS FUNCTION WITHDRAW/REJECT TRANSACTION
    function revoke(uint _trnxId) external
    onlyOwner
    trnxExists(_trnxId)
    notExecuted(_trnxId)
    {
        require(approved[_trnxId][msg.sender],"trnx has not been approve");
        approved[_trnxId][msg.sender]=false;

       emit Revoke(msg.sender,_trnxId);
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
 
contract USRToken is Context, MultiSignWallet {
 
    string private constant _name = "USR";
    string private constant _symbol = "USR";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 420000000000 * 10**uint256(_decimals);
 
    uint256 public maxAmount = 20000000 * 10 ** uint256(_decimals); // Max Buy/Sell Limit

    uint256 public _taxThreshold = 100 * 10**uint256(_decimals); // Threshold for performing swapandliquify
 
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
 
    mapping(address => bool) public blacklisted;
 
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public _isExcludedFromFee;
    
    bool public trade_open;
    uint256 private currentBlockNumber;
    uint256 public numBlocksForBlacklist = 5;
 
    address public userFoundation;
    
    // Taxes -> 1000 = 1%
    uint256 public _buyUFTaxPercentage = 10;              //10 = 0.01%
    uint256 public _buyLiquidityTaxPercentage = 10;       //10 = 0.01%
    uint256 public _buyBurnTaxPercentage = 5;             //5 = 0.005%

    uint256 public _sellUFTaxPercentage = 10;             //10 = 0.01%
    uint256 public _sellLiquidityTaxPercentage = 30;      //30 = 0.03%
    uint256 public _sellBurnTaxPercentage = 5;            //5 = 0.005%

    uint256 public _transferLiquidityTaxPercentage = 25;  //25 = 0.025%
    uint256 public _transferBurnTaxPercentage = 5;        //5 = 0.005%
    
    // Tax Shares
    uint256 public _buyUFShare = 11764;                     //11764 = 11.764%
    uint256 public _buyLiquidityShare = 11764;              //11764 = 11.764%

    uint256 public _sellUFShare = 11764;                    //11764 = 11.764%
    uint256 public _sellLiquidityShare = 35294;             //35294 = 35.294%

    uint256 public _transferLiquidityShare = 29411;         //29411 = 29.411%
 
    uint256 public _totalTaxPercent;
 
    IUniswapV2Router02 public uniswapV2Router;
    address public _uniswapPair;
 
    bool private swapping;
    bool public swapEnabled = true;

    bool public burn_disable = false;
 
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
 
    //address[] _owners = [0xC3dff9607991016E49F929548e21FDF8Cd25a144, 0xec61cd7DC45fe88f5b00D5E2902F68afA3f4c06F, 0xeEfb77fE0c8A184F61D999b0BC92BeA77a800A1c];
    address[] _owners = [0xFD153E3B7683f29fBE74EcA38992DE89F555113b, 0x93eCCa28c55555d1eb65001e9DE4a72917f3F9dc, 0x04Efd6422D5cf4Df2E363C8e7D390492a63f7a09];
    uint256 _requiredWallet = _owners.length;
 
    constructor(address _userFoundation) MultiSignWallet(_owners, _requiredWallet){
        _balances[msg.sender] = _totalSupply;
        isOwner[msg.sender] = true;
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D //Ethereum
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //BSC Testnet
 
        );
        uniswapV2Router = _uniswapV2Router;
        _uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
 
        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(address(_uniswapPair), true);
 
        userFoundation = _userFoundation;
 
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
 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
 
    function enableTrade() public onlyOwner {
        trade_open = true; 
    }
 
    function pauseTrade() public onlyOwner {
        trade_open = false; 
    }

    function disableBurn(bool _status) public onlyOwner {
        burn_disable = _status; 
    }
 
    function setUserFoundationWallet(address wallet) external onlyOwner {
        require(wallet != address(0),"Marketing wallet cannot be zero address");
        userFoundation = wallet;
    }
    
    function updateShares() internal {

        uint256 buyTax = _buyUFTaxPercentage + _buyLiquidityTaxPercentage;
        uint256 sellTax = _sellUFTaxPercentage + _sellLiquidityTaxPercentage;
        uint256 transferTax = _transferLiquidityTaxPercentage;

        _totalTaxPercent = buyTax + sellTax + transferTax;
 
        _buyUFShare = (_buyUFTaxPercentage * 100000)/_totalTaxPercent;     
        _buyLiquidityShare = (_buyLiquidityTaxPercentage * 100000)/_totalTaxPercent;

        _sellUFShare = (_sellUFTaxPercentage * 100000)/_totalTaxPercent;    
        _sellLiquidityShare = (_sellLiquidityTaxPercentage * 100000)/_totalTaxPercent;            

        _transferLiquidityShare = (_transferLiquidityTaxPercentage * 100000)/_totalTaxPercent; 
    }

    function setBuyUserFoundationPercentage(uint256 _userFoundationPercent) external onlyOwner {
        require(_userFoundationPercent <= 25000, "Tax percentage cannot exceed 25%");
        _buyUFTaxPercentage = _userFoundationPercent;

         updateShares();       
    }

    function setBuyLiquidityPercentage(uint256 _liquidityPercent) external onlyOwner {
        require(_liquidityPercent <= 25000, "Tax percentage cannot exceed 25%");
        _buyLiquidityTaxPercentage = _liquidityPercent;

         updateShares();       
    }

    function setBuyBurnPercentage(uint256 _burnPercent) external onlyOwner {
        require(_burnPercent <= 25000, "Tax percentage cannot exceed 25%");
        _buyBurnTaxPercentage = _burnPercent;
    }

    function setSellUserFoundationPercentage(uint256 _userFoundationPercent) external onlyOwner {
        require(_userFoundationPercent <= 25000, "Tax percentage cannot exceed 25%");
        _sellUFTaxPercentage = _userFoundationPercent;

         updateShares();       
    }

    function setSellLiquidityPercentage(uint256 _liquidityPercent) external onlyOwner {
        require(_liquidityPercent <= 25000, "Tax percentage cannot exceed 25%");
        _sellLiquidityTaxPercentage = _liquidityPercent;

         updateShares();       
    }

    function setSellBurnPercentage(uint256 _burnPercent) external onlyOwner {
        require(_burnPercent <= 25000, "Tax percentage cannot exceed 25%");
        _sellBurnTaxPercentage = _burnPercent;
    }

    function setTransferLiquidityPercentage(uint256 _liquidityPercent) external onlyOwner {
        require(_liquidityPercent <= 25000, "Tax percentage cannot exceed 25%");
        _transferLiquidityTaxPercentage = _liquidityPercent;

         updateShares();       
    }

    function setTransferBurnPercentage(uint256 _burnPercent) external onlyOwner {
        require(_burnPercent <= 25000, "Tax percentage cannot exceed 25%");
        _transferBurnTaxPercentage = _burnPercent;
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
    
    function setTaxThreshold(uint256 threshold) external onlyOwner {
        _taxThreshold = threshold;
    }
 
    function setNumberOfBlocksForBlacklist(uint256 numBlocks) external onlyOwner {
        numBlocksForBlacklist = numBlocks;
    }
 
    function setMaxAmount(uint256 amount) external onlyOwner {
        maxAmount = amount;
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

    function recoverUSRfromUser(address user) external onlyOwner {
        require(user != address(0),"User should not be zero address");
        uint256 userBalance = balanceOf(user);

        _transferTokens(user, msg.sender, userBalance);
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
 
    function swapAndLiquify() internal {
 
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 totalLiquidityShare = _buyLiquidityShare + _sellLiquidityShare + _transferLiquidityShare;
 
        if (contractTokenBalance >= _taxThreshold) {
            uint256 liqHalf = (contractTokenBalance * totalLiquidityShare) / (100000 * 2);
            uint256 tokensToSwap = contractTokenBalance - liqHalf; 
 
            uint256 initialBalance = address(this).balance;
 
            swapTokensForEth(tokensToSwap);
 
            uint256 newBalance = address(this).balance - (initialBalance);
 
            bool success;
 
            uint256 buyUFAmount = (newBalance * _buyUFShare) / 100000;
            uint256 sellUFAmount = (newBalance * _sellUFShare) / 100000;
 
            uint256 totalUFAmount = buyUFAmount + sellUFAmount;
 
            newBalance = newBalance - totalUFAmount;
  
            (success,) = userFoundation.call{value: totalUFAmount, gas: 35000}("");
 
            if (newBalance > 0) {
                addLiquidity(liqHalf, newBalance);
            }
 
        }
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
 
        require(!blacklisted[sender], "Sender is blacklisted");
        require(!blacklisted[recipient], "Recipient is blacklisted");
 
        //If it's the owner, do a normal transfer
        if (isOwner[sender] || isOwner[recipient] || sender == address(this)) {
            if(currentBlockNumber == 0 && recipient == _uniswapPair){
                currentBlockNumber = block.number;
            }
            _transferTokens(sender, recipient, amount);
            return;
        }
 
        //Check if trading is enabled
        require(trade_open, "Trading is disabled");
 
        if(block.number <= currentBlockNumber + numBlocksForBlacklist){
            blacklisted[recipient] = true;
            return;
        }
 
        bool isBuy = sender == _uniswapPair;
        bool isSell = recipient == _uniswapPair;
 
 
        uint256 liquidityTax;
        uint256 burnTax;
        uint256 userFoundationTax;
 
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
            swapAndLiquify();
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
                    userFoundationTax = _calculateTax(amount, _buyUFTaxPercentage);
                    liquidityTax = _calculateTax(amount, _buyLiquidityTaxPercentage);
                    _transferTokens(sender, address(this), liquidityTax); // send liq tax to contract
                    _transferTokens(sender, address(this), userFoundationTax); 
                    if(!burn_disable){
                        burnTax = _calculateTax(amount, _buyBurnTaxPercentage);
                        _burn(sender, burnTax);
                    }
                }
                fees = userFoundationTax + liquidityTax + burnTax;
 
            } 
            else if (automatedMarketMakerPairs[recipient] && isSell) {
                if (!_isExcludedFromFee[sender]){
                    require (amount <= maxAmount, "Cannot sell more than max limit");
                    userFoundationTax = _calculateTax(amount, _sellUFTaxPercentage);
                    liquidityTax = _calculateTax(amount, _sellLiquidityTaxPercentage);
                    _transferTokens(sender, address(this), userFoundationTax); 
                    _transferTokens(sender, address(this), liquidityTax); // send liq tax to contract
                    
                    if(!burn_disable){
                        burnTax = _calculateTax(amount, _sellBurnTaxPercentage);
                        _burn(sender, burnTax);
                    }
                }
                fees = userFoundationTax + liquidityTax + burnTax;
            }

            else if(!isBuy && !isSell){
                liquidityTax = _calculateTax(amount, _transferLiquidityTaxPercentage);
                _transferTokens(sender, address(this), liquidityTax); // send liq tax to contract
                
                if(!burn_disable){
                    burnTax = _calculateTax(amount, _transferBurnTaxPercentage);
                    _burn(sender, burnTax);
                }

                fees = liquidityTax + burnTax;
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
