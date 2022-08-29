//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.2; 


//-------------------------INTERFACES-----------------------------



// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
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



// pragma solidity >=0.6.2;

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



contract owned {
    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor()  {
        owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) external onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = payable(0);
    }
}
 


    
contract USRToken is owned {

    // Public variables of the token
    string constant private _name = "User Token";
    string constant private _symbol = "USR";
    uint256 constant private _decimals = 18;
    uint256 private _totalSupply = 21000000000 * (10**_decimals);         
    uint256 constant public maxSupply = 21000000000 * (10**_decimals); 
    bool public isTradeActive;  //putting isTradeActive on will halt all non-owner functions

    address [] public WRAP_TOKENS;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;


    uint256 private lastUser;
    mapping (address => uint256) private UserToId; //transfer,
    mapping (uint256 => address) private IdToUser; //transfer, 
    mapping (uint256 => bool) private excludeFromRandom;//set excludeWallet, constructor

    mapping (address=> address) public userRewardToken;
    

    address  payable public teamWallet = payable(0xa1295a3593648220506ae7F68b887338818d054C);
    address  payable public exchangeWallet = payable(0x4c25c7d476C055B0beCe2aA98430f21A8CE01dF7);
    address  payable public marketingWallet = payable(0xBcb539a11C433784F1c77915f24Bb6A3485C0954);
    address  payable public companyReserve = payable(0x8B960250b2fD5969F2B647Bfd890DC5E997d1F43);
    address  payable public privateSale = payable(0xb711D029049728CD1014474A700282878cBaaeBb);
    address  payable  public developmentWallet = payable(0x0B3E210042F1003d77d940471886d74FF6Ef9d7F);
    address  payable public charityWallet = payable(0x38bcAbb8Dd003a7AffF404AED75e3E66A74ee1f8);
    address  payable public lpWallet = payable(0x9e31b4086Bb31FC2E35235584275b31fb7A9F985);
    address  payable public strategicWallet = payable(0x11fFaAdfE6A98888D30f9c5a337D898976dF7bD6);
    // address public payable ownerWallet = 0x81BD639F0EC8CBB6083c2627b3661eE42EEb17B8;



    // This creates a mapping with all data storage
    mapping (address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;
    mapping (address => bool) public blacklisted;



    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
        
    // This generates a public event for blacklisted (blacklisting) accounts
    event blacklisteds(address target, bool blacklisted);
    
    // This will log approval of token Transfer
    event Approval(address indexed from, address indexed spender, uint256 value);



    /**
     * Returns name of token 
     */
    function name() external pure returns(string memory){
        return _name;
    }
    
    /**
     * Returns symbol of token 
     */
    function symbol() external pure returns(string memory){
        return _symbol;
    }
    
    /**
     * Returns decimals of token 
     */
    function decimals() external pure returns(uint256){
        return _decimals;
    }
    
    /**
     * Returns totalSupply of token.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * Returns balance of token 
     */
    function balanceOf(address user) external view returns(uint256){
        return _balanceOf[user];
    }
    
    /**
     * Returns allowance of token 
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowance[owner][spender];
    }
    
    /**
     * Internal transfer, only can be called by this contract 
     */
    function _transfer(address _from, address _to, uint _value) internal {
        
        //checking conditions
        require(!isTradeActive);
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require(!blacklisted[_from]);                     // Check if sender is blacklisted
        require(!blacklisted[_to]);                       // Check if recipient is blacklisted

 

        uint totalDeduction = _deductAllTax( _from,  _to, _value);

        uint recAmnt = _value-totalDeduction;
        
        //transfer
        _balanceOf[_from] = _balanceOf[_from]-(_value);    // Subtract from the sender
        _balanceOf[_to] = _balanceOf[_to]+(recAmnt);        // Add the same to the recipient
        
        // emit Transfer event
        emit Transfer(_from, _to, _value);
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
            // owner(),
            address(this),
            block.timestamp
        );
    }

    /**
     * Internal transfer, only can be called by this contract 
     */
    function _deductAllTax(address _from, address _to, uint256 _amount) internal returns(uint){

         if (_to == uniswapV2Pair) {

             // TOKEN SELL CALL 

             return _sellTaxDeduction(_from,_amount);

        } else if (_from == uniswapV2Pair) {

            // TOKEN BUY CALL

           return _buyTaxDeduction ( _from,  _amount);

        }else{

            // TOKEN WALLET TO WALLET TRANSFER CALL

            return _walletTransferDeduction(_from,_amount);
        }

    }

    function _buyTaxDeduction (address _from, uint _amount) internal returns(uint256){

        // 5% injected into liquidity pool (pancake swap)
        // 1% Liquidity injection wallet
        // 1% true burn (removal from total supply)
        // 1% token sold and exchanged for bnb wrapped etherum
        // 1% goes towards the 1337 reward wallet
        // .05% marketing wallet
        // .05% development wallet
        // .025% charity wallet
        // 1% strategic partnership wallet
        uint totalReturn;
        uint256 initialBalance = address(this).balance;

        uint injectedAmnt   = _amount*5/100; //5% 
        // uint liquidity      = _amount*1/100; // 1%
       
        uint exchangeWrap   = _amount*1/100; // 1%
        // uint marketing      = _amount*50/10000; // 0.5%
        // uint development    = _amount*50/10000; // 0.5%
        // uint charity        = _amount*25/10000; // 0.025%
        // uint strategic      = _amount*1/100; // 1%

        // uint rewardCollection = _amount*1/100; //1%

        uint burnFee = _amount*1/100; //1%

        uint256 half = injectedAmnt/2;

         address _token = WRAP_TOKENS[0];
        
        swapTokensForBnb(address(this),half,_token); // 0 for wrap-bnb

        uint256 newBalance = address(this).balance-(initialBalance);

        addLiquidity(half, newBalance);

        swapTokensForBnb(exchangeWallet,exchangeWrap,WRAP_TOKENS[1]); // wrap-etherum

            _balanceOf[lpWallet] += _amount*1/100;
            totalReturn += _amount*1/100;
             emit Transfer(_from, lpWallet, _amount*1/100);

            _balanceOf[marketingWallet] +=_amount*50/10000;
            totalReturn += _amount*50/10000;
             emit Transfer(_from, marketingWallet, _amount*50/10000);

            _balanceOf[developmentWallet] +=_amount*50/10000;
            totalReturn += _amount*50/10000;
             emit Transfer(_from, developmentWallet, _amount*50/10000);

            _balanceOf[charityWallet] +=_amount*25/10000;
            totalReturn += _amount*25/10000;
             emit Transfer(_from, charityWallet, _amount*25/10000);

            _balanceOf[strategicWallet] +=_amount*1/100;
            totalReturn += _amount*1/100;
             emit Transfer(_from, strategicWallet, _amount*1/100);

            _balanceOf[address(this)] +=_amount*1/100;
            totalReturn += _amount*1/100;
            emit Transfer(_from, address(this), _amount*1/100);

            _burn(_from,burnFee);

            totalReturn += injectedAmnt+exchangeWrap+burnFee;
        return totalReturn;

    }

    function _sellTaxDeduction(address _from, uint _amount) internal returns(uint){



        uint256 initialBalance = address(this).balance;

        uint injectedAmnt   = _amount*9/100; //5% 
        uint liquidity      = _amount*1/100; // 1%
       
   
        uint marketing      = _amount*50/10000; // 0.5%
        uint development    = _amount*50/10000; // 0.5%

        uint strategic      = _amount*1/100; // 1%


        uint burnFee = _amount*2/100; //1%

        uint256 half = injectedAmnt/2;
        
        swapTokensForBnb(address(this),half,WRAP_TOKENS[0]); // 0 for wrap-bnb

        uint256 newBalance = address(this).balance-(initialBalance);

        addLiquidity(half, newBalance);


            _balanceOf[lpWallet] +=liquidity;

             emit Transfer(_from, lpWallet, liquidity);

            _balanceOf[marketingWallet] +=marketing;

             emit Transfer(_from, marketingWallet, marketing);

            _balanceOf[developmentWallet] +=development;

             emit Transfer(_from, developmentWallet, development);


            _balanceOf[strategicWallet] +=strategic;

             emit Transfer(_from, strategicWallet, strategic);


            _burn(_from,burnFee);


        return (injectedAmnt+liquidity+marketing+development+strategic+burnFee);



    }

    function _walletTransferDeduction(address _from , uint _amount) internal returns(uint){



        uint256 initialBalance = address(this).balance;

        uint injectedAmnt   = _amount*9/100; //5% 
        uint liquidity      = _amount*1/100; // 1%
       


        uint burnFee = _amount*2/100; //1%

        uint256 half = injectedAmnt/2;
        
        address _token = WRAP_TOKENS[0];

        swapTokensForBnb(address(this),half,_token); // 0 for wrap-bnb

        uint256 newBalance = address(this).balance-(initialBalance);

        addLiquidity(half, newBalance);


            _balanceOf[lpWallet] +=liquidity;

             emit Transfer(_from, lpWallet, liquidity);

            _burn(_from,burnFee);

        return (injectedAmnt+liquidity+burnFee);



    }

    /**
        * Transfer tokens
        *
        * Send `_value` tokens to `_to` from your account
        *
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transfer(address _to, uint256 _value) external returns (bool success) {
        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        * Transfer tokens from other address
        *
        * Send `_value` tokens to `_to` in behalf of `_from`
        *
        * @param _from The address of the sender
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        //checking of allowance and token value is done by SafeMath
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender]-(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
        * Set allowance for other address
        *
        * Allows `_spender` to spend no more than `_value` tokens in your behalf
        *
        * @param _spender The address authorized to spend
        * @param _value the max amount they can spend
        */
    function approve(address _spender, uint256 _value) external returns (bool success) {
        _approve(_spender, msg.sender, _value);
        return true;
    }

    function _approve(address _spender, address _from, uint256 _value) internal returns (bool success) {
        require(!isTradeActive);
        /* AUDITOR NOTE:
            Many dex and dapps pre-approve large amount of tokens to save gas for subsequent transaction. This is good use case.
            On flip-side, some malicious dapp, may pre-approve large amount and then drain all token balance from user.
            So following condition is kept in commented. It can be be kept that way or not based on client's consent.
        */
        //require(_balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        _allowance[_from][_spender] = _value;
        emit Approval(_from, _spender, _value);
        return true;
    }
    
    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to increase the allowance by.
     */
    function increase_allowance(address spender, uint256 value) external returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender]+(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to decrease the allowance by.
     */
    function decrease_allowance(address spender, uint256 value) external returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender]-(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }


    
    constructor(address _router) {
        //distributing tokens to Wallet

        _balanceOf[owner] = _totalSupply;
        _mint(teamWallet, 441e7 * (10**_decimals));
        _mint(exchangeWallet, 231e7 * (10**_decimals));    
        _mint(marketingWallet, 21e8 * (10**_decimals));
        _mint(companyReserve, 1115e6 * (10**_decimals));
        _mint(developmentWallet, 21e7 * (10**_decimals));    
        _mint(privateSale, 21e8 * (10**_decimals));
        
        
        //firing event which logs this transaction
        emit Transfer(address(0), owner, _totalSupply);


        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        WRAP_TOKENS.push( _uniswapV2Router.WETH());

        // warp eth on 0 index


    }
    
    
    receive () external payable {
      
    }

    /**
        * Destroy tokens
        *
        * Remove `_value` tokens from the system irreversibly
        *
        * @param _value the amount of money to burn
        */
    function burn(uint256 _value) external returns (bool success) {
        require(!isTradeActive);
        //checking of enough token balance is done by SafeMath
        _balanceOf[msg.sender] = _balanceOf[msg.sender]-(_value);  // Subtract from the sender
        _totalSupply = _totalSupply-(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }


    function _burn(address _from, uint256 _value) internal returns (bool success) {
        require(!isTradeActive);
        //checking of enough token balance is done by SafeMath
        _totalSupply = _totalSupply-(_value);                      // Updates totalSupply
        emit Burn(_from, _value);
        return true;
    }


    /**
        * Destroy tokens from other account
        *
        * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
        *
        * @param _from the address of the sender
        * @param _value the amount of money to burn
        */
    function burnFrom(address _from, uint256 _value) external returns (bool success) {
        require(!isTradeActive);
        //checking of allowance and token value is done by SafeMath
        _balanceOf[_from] = _balanceOf[_from]-(_value);                         // Subtract from the targeted balance
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender]-(_value); // Subtract from the sender's allowance
        _totalSupply = _totalSupply-(_value);                                   // Update totalSupply
        emit  Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }
        
    
    /** 
        * @notice `blacklist? Prevent | Allow` `target` from sending & receiving tokens
        * @param target Address to be blacklisted
        * @param blacklist either to blacklist it or not
        */
    function blacklistAccount(address target, bool blacklist) onlyOwner external {
        blacklisted[target] = blacklist;
        emit  blacklisteds(target, blacklist);
    }
    
    /** 
        * @notice Create `mintedAmount` tokens and send it to `target`
        * @param target Address to receive the tokens
        * @param mintedAmount the amount of tokens it will receive
        */
    function mintToken(address target, uint256 mintedAmount) onlyOwner external {
        _mint(target, mintedAmount);
    }
    function _mint(address target, uint256 mintedAmount) internal {
        require(_totalSupply+(mintedAmount) <= maxSupply, "Cannot Mint more than maximum supply");
        _balanceOf[target] = _balanceOf[target]+(mintedAmount);
        _totalSupply = _totalSupply+(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }

        

    /**
        * Owner can transfer tokens from contract to owner address
        *
        * When isTradeActive is true, then all the non-owner functions will stop working.
        * When isTradeActive is false, then all the functions will resume working back again!
        */
    
    function manualWithdrawTokens(uint256 tokenAmount) external onlyOwner{
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this), owner, tokenAmount);
    }
    
    //Just in rare case, owner wants to transfer Ether from contract to owner address
    function manualWithdrawEther()onlyOwner external{
        payable(owner).transfer(address(this).balance);
    }
    
    /**
        * Change isTradeActive status on or off
        *
        * When isTradeActive is true, then all the non-owner functions will stop working.
        * When isTradeActive is false, then all the functions will resume working back again!
        */
    function changeisTradeActiveStatus() onlyOwner external{
        if (isTradeActive == false){
            isTradeActive = true;
        }
        else{
            isTradeActive = false;    
        }
    }
    

    
    
    
    // pending section
    
    /**
     * Run an ACTIVE Air-Drop
     *
     * It requires an array of all the addresses and amount of tokens to distribute
     * It will only process first 150 recipients. That limit is fixed to prevent gas limit
     */
    function airdropACTIVE(address[] memory recipients,uint256[] memory tokenAmount) external returns(bool) {
        uint256 totalAddresses = recipients.length;
        address msgSender = msg.sender;
        require(totalAddresses <= 150,"Too many recipients");
        for(uint i = 0; i < totalAddresses; i++)
        {
          //This will loop through all the recipients and send them the specified tokens
          //Input data validation is unncessary, as that is done by SafeMath and which also saves some gas.
          _transfer(msgSender, recipients[i], tokenAmount[i]);
        //   pending event
        }
        return true;
    }
    
    
    
    bool public whitelistingStatus;
    mapping (address => bool) public whitelisted;
    
    /**
     * Change whitelisting status on or off
     *
     * When whitelisting is true, then crowdsale will only accept investors who are whitelisted.
     */
    function changeWhitelistingStatus() onlyOwner external{
        if (whitelistingStatus == false){
            whitelistingStatus = true;
        }
        else{
            whitelistingStatus = false;    
        }
    }
    
    /**
     * Whitelist any user address - only Owner can do this
     *
     * It will add user address in whitelisted mapping
     */
    function whitelistUser(address userAddress) onlyOwner external{
        require(whitelistingStatus == true);
        require(userAddress != address(0));
        whitelisted[userAddress] = true;
    }
    
    /**
     * Whitelist Many user address at once - only Owner can do this
     * It will require maximum of 150 addresses to prevent block gas limit max-out and DoS attack
     * It will add user address in whitelisted mapping
     */
    function whitelistManyUsers(address[] memory userAddresses) onlyOwner external{
        require(whitelistingStatus == true);
        uint256 addressCount = userAddresses.length;
        require(addressCount <= 150,"Too many addresses");
        for(uint256 i = 0; i < addressCount; i++){
            whitelisted[userAddresses[i]] = true;
        }
    }

    
    
    function rand() internal view returns(uint256)    
    {
        
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));


        uint256 randomNumber = seed - ((seed / lastUser) * lastUser);
        if(randomNumber == 0){
            randomNumber++;
        }
        
        
        return randomNumber;
    }



    function createUserIdList(address userAddress) internal {
        uint256 userId = UserToId[userAddress];
        if(userId == 0){
            UserToId[userAddress] = lastUser++;
            IdToUser[lastUser++] = userAddress;
            
        }else{
            UserToId[userAddress] = lastUser++;
            IdToUser[lastUser++] = userAddress;
        }
    }
    function setExcludeFromRandom(address userAddress) internal{

        uint256 id = UserToId[userAddress];
        excludeFromRandom[id] = true;
    }
    
    function distributeRandomRewards() private{
        // if(balanceof(address.this)){

        // }
        for(uint8 index=0;index<5;index++){
            uint256 randomId = rand();
            if(excludeFromRandom[randomId]){
                randomId = rand();
                continue;
            }
            address userAddress =  IdToUser[randomId];
            address Token= userRewardToken[userAddress];
            // swapTokensForBnb(userAddress,reward,Token);
        }


        

    }


    function setUserRewardToken(address _rewardToken) public  returns(bool){

        userRewardToken[msg.sender]=_rewardToken;

        return true;
    }


    //------------------------------EXTERNAL EXCHANGE CALL----------------------

    function swapTokensForBnb(address _receiver ,uint256 tokenAmount,address _token) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _token;

        _approve(_receiver, address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            _receiver,
            block.timestamp
        );
    }

    
   
    
}
