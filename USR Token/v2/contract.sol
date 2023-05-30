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



/**
 *SPDX-License-Identifier: NOLICENSE
*/
pragma solidity 0.8.17;


import "@openzeppelin/contracts@4.5.0/token/ERC721/IERC721.sol";


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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


interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external payable;
    
}

contract USERToken is Context, IERC20, MultiSignWallet {

    

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isBot;

    address[] private _excluded;

    bool public tradingEnabled;
    bool public swapEnabled;
    bool private swapping;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);

    uint256 public HODL_PERIOD = 7 days;
    uint256 public HODL_THRESHOLD = 500000 * (10**_decimals);       /* number of token to reach for it to start */
    uint256 public HODL_STAKING_RATE = 10 * (10**_decimals);  /* meaning 10 tokens per week as reward*/

    uint256 public RANDOM_WALLET_THRESHOLD = 1000;
    uint256 public RANDOM_TOKEN_THRESHOLD = 1000000 * (10**_decimals);
    uint256 public RANDOM_TOKEN_THRESHOLD_FOR_SWAP = 50000000 * (10**_decimals);

    uint256 public USDT_REWARDS_THRESHOLD = 250000 * (10**_decimals);
    uint256 public USDT_REWARDS_PERC = 10; /* meaning a total 0.1% OF CONTRACT BALANCE would be distributed to all existing members who qualifies for USDT rewards*/

    uint256 public PERCENT_DIVIDER = 1e8; 
    /**
    * 100% = 1e8
    * 10% = 1000000
    * 1% = 10000
    * 0.1% = 1000
    * 0.01% = 100
    * 0.001% = 10
    * 0.0001% = 1
    */
    uint256 MAX_AIRDROP_AMOUNT;

    bool randomRewardEnabled;
    bool usdtRewardEnabled;
    bool hodlRewardEnabled;


    uint256 private _tTotal = 21e9 * (10**_decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public antiWhaleAmt = 1000_000_000_000_000 * (10**_decimals);
    uint256 public swapTokensAtAmount = 20_000_000_000_000 * (10**_decimals);
    
    // Anti Dump //
    uint256 public maxSellAmountPerCycle = 1000_000_000_000_000 * (10**_decimals);
    uint256 public antiDumpCycle = 24 hours;
    
    struct UserLastSell  {
        uint256 amountSoldInCycle;
        uint256 lastSellTime;
    }
    mapping(address => UserLastSell) public userLastSell;

    struct UserLastActivity{
        uint256 time;
        uint256 lastHodlClaimTime;
        bool hodlClaimed;
        bool airdropClaimed;
        bool usdtClaimed;
    }

    mapping(address => UserLastActivity) public userLastActivity;
    
    mapping(address => bool) public randomRewards;

    mapping (address => uint256) public UserToId; 
    mapping (uint256 => address) public IdToUser; 

    uint256 public randomUserLength;
    uint256 public totalDepositors;

    /* Marketing, Development, Strategic Parnerships */

    address public marketingAddress = 0xb447849d5323d9E791d667d9B5e583EF4B9A0e99;
    address public developmentAddress = 0xba87B13C019eA635e6A6eb8FafcdEa6Fcc4fb3Ea;
    address public strategicPartnershipAddress = 0xcF63E6f3E83891c394D56A14a72b69A2973386A1;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public NFT_F;
    address public NFT_L1;
    address public NFT_L2;
    address public NFT_L3;

    uint256 public NFT_F_PERC;
    uint256 public NFT_L1_PERC;
    uint256 public NFT_L2_PERC;
    uint256 public NFT_L3_PERC;


    string private constant _name = "USER Token";
    string private constant _symbol = "USR";


    struct Taxes {
      uint256 rfi;
      uint256 marketing;
      uint256 liquidity;
      uint256 burn;
      uint256 development;
      uint256 strategicPartnership;
      uint256 spinovation;
      uint256 usdtBoost;
      uint256 hodl;
      uint256 NFT_F;
      uint256 NFT_L1;
      uint256 NFT_L2;
      uint256 NFT_L3;
    }

    
    Taxes public buyTaxes = Taxes(0,6,10000,25,7,6,25,5,6,9,7,5,4);
    Taxes public sellTaxes = Taxes(0,12,207,25,12,12,25,100,12,15,12,10,8);
    Taxes public taxes = Taxes(0,0,100,100,0,0,0,0,0,0,0,0,0);



    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 burn;
        uint256 development;
        uint256 strategicPartnership;
        uint256 spinovation;
        uint256 usdtBoost;
        uint256 hodl;
        uint256 NFT_F;
        uint256 NFT_L1;
        uint256 NFT_L2;
        uint256 NFT_L3;
    }
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 rBurn;
      uint256 rDevelopment;
      uint256 rStrategicPartnership;
      uint256 rSpinovation;
      uint256 rUsdtBoost;
      uint256 rHodl;
      uint256 rNFT_F;
      uint256 rNFT_L1;
      uint256 rNFT_L2;
      uint256 rNFT_L3;

      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tMarketing;
      uint256 tLiquidity;
      uint256 tBurn;
      uint256 tDevelopment;
      uint256 tStrategicPartnership;
      uint256 tSpinovation;
      uint256 tUsdtBoost;
      uint256 tHodl;
      uint256 tNFT_F;
      uint256 tNFT_L1;
      uint256 tNFT_L2;
      uint256 tNFT_L3;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    modifier onlyWhenRandomRewardEnabled {
        require(randomRewardEnabled, "not permitted");
        _;
    }

    modifier onlyWhenUsdtRewardEnabled {
        require(usdtRewardEnabled, "not permitted");
        _;
    }

    modifier onlyWhenHodlRewardEnabled {
        require(hodlRewardEnabled, "not permitted");
        _;
    }

    address[] _owners = [0xC3dff9607991016E49F929548e21FDF8Cd25a144, 0xec61cd7DC45fe88f5b00D5E2902F68afA3f4c06F, 0xeEfb77fE0c8A184F61D999b0BC92BeA77a800A1c];
    uint256 _requiredWallet = _owners.length;

    constructor (address routerAddress) MultiSignWallet(_owners, _requiredWallet) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        
        excludeFromReward(pair);
        excludeFromReward(deadAddress);

        _rOwned[owners[0]] = _rTotal;
        _isExcludedFromFee[owners[0]] = true;
        _isExcludedFromFee[marketingAddress]=true;
        _isExcludedFromFee[deadAddress] = true;
        _isExcludedFromFee[developmentAddress] = true;
        _isExcludedFromFee[strategicPartnershipAddress] = true;

        taxFreeTransfer(owners[0], 0x15d790609659863dAF4D7791399E0C2564755454, 1155000000 * (10**_decimals));
        taxFreeTransfer(owners[0], 0xba3a4e22aD487cb91B7De6E276a4D09F1d6B4eE0, 1155000000 * (10**_decimals));


        emit Transfer(address(0), owners[0], _tTotal);
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, 3);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, 3);
            return s.rTransferAmount;
        }
    }


    function setTradingStatus(bool state) external onlyOwner{
        tradingEnabled = state;
        swapEnabled = state;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    //@dev kept original RFI naming -> "reward" as in reflection
    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
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


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setTaxes(uint256 _rfi, uint256 _marketing, uint256 _liquidity, uint256 _burn, uint256 _development, uint256 _strategicPartnership, uint256 usdtBoost, uint256 spinovation, uint256 hodl, uint256 nft_f, uint256 nft_l1, uint256 nft_l2, uint256 nft_l3) public onlyOwner {
        
        taxes.rfi = _rfi;
        taxes.marketing = _marketing;
        taxes.liquidity = _liquidity;
        taxes.burn = _burn;
        taxes.development = _development;
        taxes.strategicPartnership = _strategicPartnership;
        taxes.usdtBoost = usdtBoost;
        taxes.spinovation = spinovation;
        taxes.hodl = hodl;
        taxes.NFT_F = nft_f;
        taxes.NFT_L1 = nft_l1;
        taxes.NFT_L2 = nft_l2;
        taxes.NFT_L3 = nft_l3;
        emit FeesChanged();
    }
    
    function setBuyTaxes(uint256 _rfi, uint256 _marketing, uint256 _liquidity, uint256 _burn, uint256 _development, uint256 _strategicPartnership, uint256 usdtBoost, uint256 spinovation, uint256 hodl, uint256 nft_f, uint256 nft_l1, uint256 nft_l2, uint256 nft_l3) public onlyOwner {
        
        buyTaxes.rfi = _rfi;
        buyTaxes.marketing = _marketing;
        buyTaxes.liquidity = _liquidity;
        buyTaxes.burn = _burn;
        buyTaxes.development = _development;
        buyTaxes.strategicPartnership = _strategicPartnership;
        buyTaxes.usdtBoost = usdtBoost;
        buyTaxes.spinovation = spinovation;
        buyTaxes.hodl = hodl;
        buyTaxes.NFT_F = nft_f;
        buyTaxes.NFT_L1 = nft_l1;
        buyTaxes.NFT_L2 = nft_l2;
        buyTaxes.NFT_L3 = nft_l3;
        emit FeesChanged();
    }
    
    function setSellTaxes(uint256 _rfi, uint256 _marketing, uint256 _liquidity, uint256 _burn, uint256 _development, uint256 _strategicPartnership, uint256 usdtBoost, uint256 spinovation, uint256 hodl, uint256 nft_f, uint256 nft_l1, uint256 nft_l2, uint256 nft_l3) public onlyOwner {
       
        sellTaxes.rfi = _rfi;
        sellTaxes.marketing = _marketing;
        sellTaxes.liquidity = _liquidity;
        sellTaxes.burn = _burn;
        sellTaxes.development = _development;
        sellTaxes.strategicPartnership = _strategicPartnership;

        sellTaxes.usdtBoost = usdtBoost;
        sellTaxes.spinovation = spinovation;
        sellTaxes.hodl = hodl;
        sellTaxes.NFT_F = nft_f;
        sellTaxes.NFT_L1 = nft_l1;
        sellTaxes.NFT_L2 = nft_l2;
        sellTaxes.NFT_L3 = nft_l3;
        emit FeesChanged();
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.rfi +=tRfi;
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity +=tLiquidity;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tLiquidity;
        }
        _rOwned[address(this)] +=rLiquidity;
    }

    function _takeSpinovation(uint256 rSpinovation, uint256 tSpinovation) private {
        totFeesPaid.spinovation +=tSpinovation;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tSpinovation;
        }
        _rOwned[address(this)] +=rSpinovation;
    }

    function _takeUsdtBoost(uint256 rUsdtBoost, uint256 tUsdtBoost) private {
        totFeesPaid.usdtBoost +=tUsdtBoost;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tUsdtBoost;
        }
        _rOwned[address(this)] +=rUsdtBoost;
    }

    function _takeHodl(uint256 rHodl, uint256 tHodl) private {
        totFeesPaid.hodl +=tHodl;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tHodl;
        }
        _rOwned[address(this)] +=rHodl;
    }


    /* NFT - Founders Level - Architect's Edition Rewards */
    function _takeNFT_F(uint256 rNFT_F, uint256 tNFT_F) private {
        totFeesPaid.NFT_F +=tNFT_F;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tNFT_F;
        }
        _rOwned[address(this)] +=rNFT_F;
    }

    /* NFT - Level 1 - Initiate's Edition */
    function _takeNFT_L1(uint256 rNFT_L1, uint256 tNFT_L1) private {
        totFeesPaid.NFT_L1 +=tNFT_L1;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tNFT_L1;
        }
        _rOwned[address(this)] +=rNFT_L1;
    }

    /* NFT - Level 2 - Vanguard Artifacts */
    function _takeNFT_L2(uint256 rNFT_L2, uint256 tNFT_L2) private {
        totFeesPaid.NFT_L2 +=tNFT_L2;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tNFT_L2;
        }
        _rOwned[address(this)] +=rNFT_L2;
    }

    /* NFT - Level 3 - Apex Edition */
    function _takeNFT_L3(uint256 rNFT_L3, uint256 tNFT_L3) private {
        totFeesPaid.NFT_L3 +=tNFT_L3;

        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)]+=tNFT_L3;
        }
        _rOwned[address(this)] +=rNFT_L3;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing +=tMarketing;

        if(_isExcluded[marketingAddress])
        {
            _tOwned[marketingAddress]+=tMarketing;
        }
        _rOwned[marketingAddress] +=rMarketing;
    }
    
    /* IncendiaryX */
    function _takeBurn(uint256 rBurn, uint256 tBurn) private{
        totFeesPaid.burn +=tBurn;

        if(_isExcluded[deadAddress])
        {
            _tOwned[deadAddress]+=tBurn;
        }
        _rOwned[deadAddress] +=rBurn;
    }

    function _takeDevelopment(uint256 rDevelopment, uint256 tDevelopment) private {
        totFeesPaid.development += tDevelopment;

        if(_isExcluded[developmentAddress])
        {
            _tOwned[developmentAddress]+=tDevelopment;
        }
        _rOwned[developmentAddress] +=rDevelopment;
    }

    function _takeStrategicPartnership(uint256 rStrategicPartnership, uint256 tStrategicPartnership) private {
        totFeesPaid.strategicPartnership += tStrategicPartnership;

        if(_isExcluded[strategicPartnershipAddress])
        {
            _tOwned[strategicPartnershipAddress]+=tStrategicPartnership;
        }
        _rOwned[strategicPartnershipAddress] +=rStrategicPartnership;
    }


    function _getValues(uint256 tAmount, bool takeFee, uint8 category) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, category);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rMarketing, to_return.rLiquidity, to_return.rBurn, to_return.rDevelopment, to_return.rStrategicPartnership, to_return.rSpinovation, to_return.rUsdtBoost, to_return.rHodl, to_return.rNFT_F, to_return.rNFT_L1, to_return.rNFT_L2, to_return.rNFT_L3) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee, uint8 category) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }
        Taxes memory temp;
        if(category == 0) temp = sellTaxes;
        else if(category == 1) temp = buyTaxes;
        else temp = taxes;
        
        s.tRfi = tAmount*temp.rfi/PERCENT_DIVIDER;
        s.tMarketing = tAmount*temp.marketing/PERCENT_DIVIDER;
        s.tLiquidity = tAmount*temp.liquidity/PERCENT_DIVIDER;
        s.tBurn = tAmount*temp.burn/PERCENT_DIVIDER;
        s.tDevelopment = tAmount*temp.development/PERCENT_DIVIDER;
        s.tStrategicPartnership = tAmount*temp.strategicPartnership/PERCENT_DIVIDER;

        s.tSpinovation = tAmount*temp.spinovation/PERCENT_DIVIDER;
        s.tUsdtBoost = tAmount*temp.usdtBoost/PERCENT_DIVIDER;
        s.tHodl = tAmount*temp.hodl/PERCENT_DIVIDER;
        s.tNFT_F = tAmount*temp.NFT_F/PERCENT_DIVIDER;
        s.tNFT_L1 = tAmount*temp.NFT_L1/PERCENT_DIVIDER;
        s.tNFT_L2 = tAmount*temp.NFT_L2/PERCENT_DIVIDER;
        s.tNFT_L3 = tAmount*temp.NFT_L3/PERCENT_DIVIDER;
      
        s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tBurn-s.tDevelopment-s.tStrategicPartnership;
        s.tTransferAmount = s.tTransferAmount - s.tSpinovation-s.tUsdtBoost-s.tHodl-s.tNFT_F-s.tNFT_L1-s.tNFT_L2-s.tNFT_L3;
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns 
    (
        uint256 rAmount, 
        uint256 rTransferAmount, 
        uint256 rRfi,uint256 rMarketing, 
        uint256 rLiquidity, 
        uint256 rBurn, 
        uint256 rDevelopment, 
        uint256 rStrategicPartnership,
        uint256 rSpinovation,
        uint256 rUsdtBoost,
        uint256 rHodl,
        uint256 rNFT_F,
        uint256 rNFT_L1,
        uint256 rNFT_L2,
        uint256 rNFT_L3
    ) {
        rAmount = tAmount*currentRate;

        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0,0,0,0,0,0,0,0,0,0,0);
        }

        rRfi = s.tRfi*currentRate;
        rMarketing = s.tMarketing*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        rBurn = s.rBurn*currentRate;
        rDevelopment = s.rDevelopment*currentRate;
        rStrategicPartnership = s.rStrategicPartnership;

        rSpinovation = s.rSpinovation;
        rUsdtBoost = s.rUsdtBoost;
        rHodl = s.rHodl;
        rNFT_F = s.rNFT_F;
        rNFT_L1 = s.rNFT_L1;
        rNFT_L2 = s.rNFT_L2;
        rNFT_L3 = s.rNFT_L3;


        rTransferAmount =  rAmount-rRfi-rMarketing-rLiquidity-rBurn;
        rTransferAmount = rTransferAmount - rSpinovation-rUsdtBoost-rHodl-rNFT_F-rNFT_L1-rNFT_L2-rNFT_L3;
        return (rAmount, rTransferAmount, rRfi,rMarketing,rLiquidity, rBurn, rDevelopment, rStrategicPartnership, rSpinovation, rUsdtBoost, rHodl, rNFT_F, rNFT_L1, rNFT_L2, rNFT_L3);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"You are trying to transfer more than your balance");
        require(!_isBot[from] && !_isBot[to], "You are a bot");
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            require(tradingEnabled, "Trading is not enabled yet");
            require(amount <= antiWhaleAmt, "You are exceeding anti whale amount");
        }
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && from != pair){
            bool newCycle = block.timestamp - userLastSell[from].lastSellTime >= antiDumpCycle;
            if(!newCycle){
                require(userLastSell[from].amountSoldInCycle + amount <= maxSellAmountPerCycle, "You are exceeding maxSellAmountPerCycle");
                userLastSell[from].amountSoldInCycle += amount;
            }
            else{
                require(amount <= maxSellAmountPerCycle, "You are exceeding maxSellAmountPerCycle");
                userLastSell[from].amountSoldInCycle = amount;
            }
            userLastSell[from].lastSellTime = block.timestamp;
            
        }
        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if(!swapping && swapEnabled && canSwap && from != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            fluidify(swapTokensAtAmount);
        }
        
        uint8 category;
        if(to == pair) category = 0; // 0 --> SELL
        else if(from == pair) category = 1; // 1 --> BUY
        else if(from != pair && to != pair) category = 2; // 2 --> TRANSFER

        _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]), category);

        /* update sender's last activity */
        if(!_isExcluded[from] && !_isExcludedFromFee[from]){
            updateUserLastActivity(from);
        }
    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, uint8 category) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, category);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        
        if(s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if(s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity,s.tLiquidity);
            emit Transfer(sender, address(this), s.tLiquidity);
        }
        if(s.rMarketing > 0 || s.tMarketing > 0){
            _takeMarketing(s.rMarketing, s.tMarketing);
            emit Transfer(sender, marketingAddress, s.tMarketing);
        }
        if(s.rBurn > 0 || s.tBurn > 0){
            _takeBurn(s.rBurn, s.tBurn);
            emit Transfer(sender, deadAddress, s.tBurn);
        }

        if(s.rDevelopment > 0 || s.tDevelopment > 0){
            _takeDevelopment(s.rDevelopment, s.tDevelopment);
            emit Transfer(sender, developmentAddress, s.tDevelopment);
        }

        if(s.rStrategicPartnership > 0 || s.tStrategicPartnership > 0){
            _takeStrategicPartnership(s.rStrategicPartnership, s.tStrategicPartnership);
            emit Transfer(sender, strategicPartnershipAddress, s.tStrategicPartnership);
        }

        if(s.rSpinovation > 0 || s.tSpinovation > 0) {
            _takeSpinovation(s.rSpinovation,s.tSpinovation);
            emit Transfer(sender, address(this), s.tSpinovation);
        }

        if(s.rUsdtBoost > 0 || s.tUsdtBoost > 0) {
            _takeUsdtBoost(s.rUsdtBoost,s.tUsdtBoost);
            emit Transfer(sender, address(this), s.tUsdtBoost);
        }

        if(s.rHodl > 0 || s.tHodl > 0) {
            _takeHodl(s.rHodl,s.tHodl);
            emit Transfer(sender, address(this), s.tHodl);
        }

        if(s.rNFT_F > 0 || s.tNFT_F > 0) {
            _takeNFT_F(s.rNFT_F,s.tNFT_F);
            emit Transfer(sender, address(this), s.tNFT_F);
        }

        if(s.rNFT_L1 > 0 || s.tNFT_L1 > 0) {
            _takeNFT_L1(s.rNFT_L1,s.tNFT_L1);
            emit Transfer(sender, address(this), s.tNFT_L1);
        }

        if(s.rNFT_L2 > 0 || s.tNFT_L2 > 0) {
            _takeNFT_L2(s.rNFT_L2,s.tNFT_L2);
            emit Transfer(sender, address(this), s.tNFT_L2);
        }

        if(s.rNFT_L3 > 0 || s.tNFT_L3 > 0) {
            _takeNFT_L3(s.rNFT_L3,s.tNFT_L3);
            emit Transfer(sender, address(this), s.tNFT_L3);
        }


        emit Transfer(sender, recipient, s.tTransferAmount);
    

    }

    function updateUserLastActivity(address forUser) private {
        uint256 lastActivityAt = userLastActivity[forUser].time;
        if (block.timestamp > lastActivityAt){
            userLastActivity[forUser].time = uint256(block.timestamp);
        }

        // updateHODLRewards(forUser);
        createUserIdList(forUser);
        spinovationHelper();
    }

    function getHODLRewards(address forUser) public view returns(uint256 rewardsInToken){
        uint256 lastActivityAt = userLastActivity[forUser].time;
        uint256 lastClaimed = userLastActivity[forUser].lastHodlClaimTime;
        if (block.timestamp > lastActivityAt){
            if(block.timestamp - lastActivityAt >= HODL_PERIOD && block.timestamp - lastClaimed >= HODL_PERIOD && balanceOf(forUser) >= HODL_THRESHOLD){
                /* add hodl reward */
                uint256 NoOfWeek = (block.timestamp - lastClaimed) / HODL_PERIOD;
                uint256 result = balanceOf(forUser)*(HODL_STAKING_RATE)*(NoOfWeek);
                return result;
            }
        }
    }

    function claimHODLRewards(address forUser, address outToken) public onlyWhenHodlRewardEnabled{
        uint256 rewardInTokens = getHODLRewards(forUser);
        require(balanceOf(address(this)) >= rewardInTokens, "not enough balance");
        require(rewardInTokens >= 0, "not enough HODL rewards");
        swapThisForTokens(rewardInTokens, outToken);
        
        userLastActivity[forUser].lastHodlClaimTime = uint256(block.timestamp);
    }

    function spinovationHelper() private onlyWhenRandomRewardEnabled{
        uint256 aNumber = randomNumberGenerator(totalDepositors);
        address aUser = IdToUser[aNumber];
        if(!_isExcluded[aUser] && !_isExcludedFromFee[aUser] && !randomRewards[aUser] && balanceOf(aUser) >= RANDOM_TOKEN_THRESHOLD){
            randomRewards[aUser] = true;
            randomUserLength++;
        }

    }

    function spinovation() external{
        address owner = _msgSender();
        if(RANDOM_WALLET_THRESHOLD - randomUserLength != 0){
            require(randomRewards[owner], "You are not selected in random rewards");
            uint256 rewardInTokens = RANDOM_TOKEN_THRESHOLD_FOR_SWAP / randomUserLength;
            uint256 contractBalance = address(this).balance;
            
            /*
            * 1. swap from tokens to BNB*/

            // generate the uniswap pair path of token -> weth
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();

            _approve(address(this), address(router), rewardInTokens);

            // make the swap
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                rewardInTokens,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );

            uint256 difference = address(this).balance - contractBalance;

            /* 2. swap from BNB to USDT*/
            address[] memory path1 = new address[](2);
            path1[0] = router.WETH();
            path1[1] = USDT;

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: difference}(
                0, 
                path1, 
                owner,
                block.timestamp
            );

            delete randomRewards[owner];
            randomUserLength--;
        }else{
            if(RANDOM_WALLET_THRESHOLD - randomUserLength == 0){
                randomUserLength = 0;
            }
        }
    }

    function claimUsdtRewards() external onlyWhenUsdtRewardEnabled{
        address owner = _msgSender();
        uint256 userBalance = this.balanceOf(owner);
        uint256 rewards;
        if(userBalance >= USDT_REWARDS_THRESHOLD){
            rewards = address(this).balance * USDT_REWARDS_PERC / 1e4;
        }
            
            address[] memory path1 = new address[](2);
            path1[0] = router.WETH();
            path1[1] = USDT;

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: rewards}(
                0, 
                path1, 
                owner,
                block.timestamp
            );
    }
    
    
    function getUsdtRewards(address user) external view returns(uint256){
        uint256 userBalance = balanceOf(user);
        if(userBalance >= USDT_REWARDS_THRESHOLD){
            return address(this).balance * USDT_REWARDS_PERC / 1e4;
        }
        return 0;
    }


    /* NFT REWARDS */
    function getNFT_F_rewards(address user) public view returns(uint256){
        uint256 nftBalance = IERC721(NFT_F).balanceOf(user);
        if(nftBalance > 0){
            uint256 tokenBalance = balanceOf(user);
            uint256 rewards = tokenBalance * NFT_F_PERC / 1e4;
            return rewards;
        }
        return 0;
    }
    function claimNFT_F_rewards() public {
        address owner = _msgSender();
        uint256 rewards = getNFT_F_rewards(owner);

        require(rewards > 0);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(router), rewards);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            rewards,
            0, // accept any amount of ETH
            path,
            owner,
            block.timestamp
        );
    }



    function getNFT_L1_rewards(address user) public view returns(uint256){
        uint256 nftBalance = IERC721(NFT_L1).balanceOf(user);
        if (nftBalance > 0) {
            uint256 tokenBalance = balanceOf(user);
            uint256 rewards = tokenBalance * NFT_L1_PERC / 1e4;
            return rewards;
        }
        return 0;
    }
    function claimNFT_L1_rewards() public {
        address owner = _msgSender();
        uint256 rewards = getNFT_L1_rewards(owner);

        require(rewards > 0);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(router), rewards);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            rewards,
            0, // accept any amount of ETH
            path,
            owner,
            block.timestamp
        );
    }

    function getNFT_L2_rewards(address user) public view returns(uint256){
        uint256 nftBalance = IERC721(NFT_L2).balanceOf(user);
        if(nftBalance > 0){

        uint256 tokenBalance = balanceOf(user);
        uint256 rewards = tokenBalance * NFT_L2_PERC / 1e4;
        return rewards;
        }
        return 0;
    }
    function claimNFT_L2_rewards() public {
        address owner = _msgSender();
        uint256 rewards = getNFT_L2_rewards(owner);
        
        require(rewards > 0);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(router), rewards);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            rewards,
            0, // accept any amount of ETH
            path,
            owner,
            block.timestamp
        );
    }

    function getNFT_L3_rewards(address user) public view returns(uint256){
        uint256 nftBalance = IERC721(NFT_L3).balanceOf(user);
        if(nftBalance > 0){
            uint256 tokenBalance = balanceOf(user);
            uint256 rewards = tokenBalance * NFT_L3_PERC / 1e4;
            return rewards;
        }
        return 0;
    }
    function claimNFT_L3_rewards() public {
        address owner = _msgSender();
        uint256 rewards = getNFT_L3_rewards(owner);

        require(rewards > 0);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(router), rewards);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            rewards,
            0, // accept any amount of ETH
            path,
            owner,
            block.timestamp
        );
    }
    

    /*
    * Create user id list*/
    function createUserIdList(address userAddress) internal{
        uint256 userId = UserToId[userAddress];
        uint256 incr = totalDepositors + 1;
        if(userId == 0){
            UserToId[userAddress] = incr;
            IdToUser[incr] = userAddress;
            totalDepositors++;
        }
    }

    /*
    * A cool random number generator*/
    function randomNumberGenerator(uint256 _upto) private view returns(uint256){
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        uint256 randomNumber = seed - ((seed / _upto) * _upto);
        if(randomNumber == 0){
            randomNumber++;
        }
        return randomNumber;
    }

    function fluidify(uint256 contractTokenBalance) private lockTheSwap{
         //calculate how many tokens we need to exchange
        uint256 tokensToSwap = contractTokenBalance / 2;
        uint256 otherHalfOfTokens = tokensToSwap;
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(tokensToSwap, address(this));
        uint256 newBalance = address(this).balance - (initialBalance);
        addLiquidity(otherHalfOfTokens, newBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owners[0],
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount, address recipient) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            payable(recipient),
            block.timestamp
        );
    }

    function swapThisForTokens(uint256 thisTokenAmount, address outToken) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = outToken;

        _approve(address(this), address(router), thisTokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            thisTokenAmount,
            0, // accept any amount of ETH
            path,
            _msgSender(),
            block.timestamp
        );
    }
    
    function airdropTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner{
        require(accounts.length == amounts.length, "Arrays must have the same size");
        for(uint256 i= 0; i < accounts.length; i++){
 
            if(amounts[i] <= MAX_AIRDROP_AMOUNT){
                taxFreeTransfer(msg.sender, accounts[i], amounts[i] * 10**_decimals);
            }
            else continue;
        }
    }

    function updateMAX_AIRDROP_AMOUNT(uint256 value) external onlyOwner{
        require(value > 0);
        MAX_AIRDROP_AMOUNT = value;
    }

    function toggleRandomReward(bool value) external onlyOwner{
        randomRewardEnabled = value;
    }

    function toggleHodlReward(bool value) external onlyOwner{
        hodlRewardEnabled = value;
    }

    function toggleUsdtReward(bool value) external onlyOwner{
        usdtRewardEnabled = value;
    }

    function setNFTs(address F, address L1, address L2, address L3) external onlyOwner{
        NFT_F = F;
        NFT_L1 = L1;
        NFT_L2 = L2;
        NFT_L3 = L3;
    }

    function setNftPercentages(uint f, uint l1, uint l2, uint l3) external onlyOwner{
        NFT_F_PERC = f;
        NFT_L1_PERC = l1;
        NFT_L2_PERC = l2;
        NFT_L3_PERC = l3;
    }

    function updateHODL_STAKING_RATE(uint256 amountInWei) external onlyOwner{
        HODL_STAKING_RATE = amountInWei;
    }

    function updateRANDOM_WALLET_THRESHOLD(uint256 amount) external onlyOwner{
        RANDOM_WALLET_THRESHOLD = amount;
    }

    function updateRANDOM_TOKEN_THRESHOLD(uint256 amountInWei) external onlyOwner{
        RANDOM_TOKEN_THRESHOLD = amountInWei;
    }

    function updateRANDOM_TOKEN_THRESHOLD_FOR_SWAP(uint256 amountInWei) external onlyOwner{
        RANDOM_TOKEN_THRESHOLD_FOR_SWAP = amountInWei;
    }

    function updateUSDT_REWARDS_THRESHOLD(uint256 amountInWei) external onlyOwner{
        USDT_REWARDS_THRESHOLD = amountInWei;
    }

    function updateUSDT_REWARDS_PERC(uint256 perc) external onlyOwner{
        USDT_REWARDS_PERC = perc;
    }

    function updateHODL_THRESHOLD(uint256 tokenAmount) external onlyOwner{
        HODL_THRESHOLD = tokenAmount * (10**_decimals);
    }

    function updateMarketingWallet(address newWallet) external onlyOwner{
        includeInFee(marketingAddress);
        marketingAddress = newWallet;
        excludeFromFee(marketingAddress);
    }

    function updateDevelopmentWallet(address newWallet) external onlyOwner{
        includeInFee(developmentAddress);
        developmentAddress = newWallet;
        excludeFromFee(developmentAddress);
    }

    function updateStrategicPartnershipWallet(address newWallet) external onlyOwner{
        includeInFee(strategicPartnershipAddress);
        strategicPartnershipAddress = newWallet;
        excludeFromFee(strategicPartnershipAddress);
    }

    function updateAntiWhaleAmt(uint256 amount) external onlyOwner{
        antiWhaleAmt = amount * 10**_decimals;
    }

    function updateSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**_decimals;
    }

    function updateSwapEnabled(bool _enabled) external onlyOwner{
        swapEnabled = _enabled;
    }

    function setAntibot(address account, bool state) external onlyOwner{
        _isBot[account] = state;
    }
    
    function bulkAntiBot(address[] memory accounts, bool state) external onlyOwner{
        for(uint256 i = 0; i < accounts.length; i++){
            _isBot[accounts[i]] = state;
        }
    }
    
    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
        router = IRouter(newRouter);
        pair = newPair;
    }
    
    function updateAntiDump(uint256 _maxSellAmountPerCycle, uint256 timeInMinutes) external onlyOwner{
        require(_maxSellAmountPerCycle >= 1_000_000_000, "Amount must be >= 1B");
        antiDumpCycle = timeInMinutes * 1 minutes;
        maxSellAmountPerCycle = _maxSellAmountPerCycle * 10**_decimals;
    }

    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }
    
    function taxFreeTransfer(address sender, address recipient, uint256 tAmount) internal{
        uint256 rAmount = tAmount* _getRate();

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient] + tAmount;
        }

        _rOwned[sender] = _rOwned[sender]- rAmount;
        _rOwned[recipient] = _rOwned[recipient]+ rAmount;
        emit Transfer(sender, recipient, tAmount);
    }
    
    function aidropTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner{
        require(accounts.length == amounts.length, "Arrays must have the same size");
        for(uint256 i= 0; i < accounts.length; i++){
            taxFreeTransfer(msg.sender, accounts[i], amounts[i] * 10**_decimals);
        }
    }

    //Use this in case BNB are sent to the contract by mistake
    function liquidPulse(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(0xC40aab8D4fD6FEF860F29D5b6F4EB6126602f180).transfer(weiAmount);
    }
    
    // Function to allow admin to claim *other* BEP20 tokens sent to this contract (by mistake)
    // Owner cannot transfer out catecoin from this smart contract
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != address(this), "Cannot transfer out USR TOKEN!");
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable{
    }
}
