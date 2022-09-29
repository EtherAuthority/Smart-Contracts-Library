// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17; 

import "./interface.sol";
import "./multisign.sol";

    
contract USRToken is MultiSignWallet{

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

    uint256 public minTokenForRandomDist = 1000e18;
    uint256 public rewardThreshold = 6.5 ether;
    uint256[] internal randRewards = [1e17, 1e17, 1e17, 1e17, 1e17];
    uint256 private lastUser;
    mapping (address => uint256) private UserToId; //transfer,
    mapping (uint256 => address) private IdToUser; //transfer, 
    mapping (uint256 => bool) private excludeFromRandom;//set excludeWallet, constructor

    mapping (address=> address) public userRewardToken;
    uint256 [] internal randomDistributionRewards = [25e18, 50e18, 100e18, 250e18, 900e18];
    uint256 public liquidityInjectionInRandDist = 50e18;
    

    address  payable public teamWallet = payable(0xa1295a3593648220506ae7F68b887338818d054C);
    address  payable public exchangeWallet = payable(0x4c25c7d476C055B0beCe2aA98430f21A8CE01dF7);
    address  payable public marketingWallet = payable(0xBcb539a11C433784F1c77915f24Bb6A3485C0954);
    address  payable public companyReserve = payable(0x8B960250b2fD5969F2B647Bfd890DC5E997d1F43);
    address  payable public privateSale = payable(0xb711D029049728CD1014474A700282878cBaaeBb);
    address  payable  public developmentWallet = payable(0x0B3E210042F1003d77d940471886d74FF6Ef9d7F);
    address  payable public charityWallet = payable(0x38bcAbb8Dd003a7AffF404AED75e3E66A74ee1f8);
    address  payable public lpWallet = payable(0x9e31b4086Bb31FC2E35235584275b31fb7A9F985);
    address  payable public strategicWallet = payable(0x11fFaAdfE6A98888D30f9c5a337D898976dF7bD6);



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

        require(_value<=getTransferLimit());

 

        uint totalDeduction = _deductAllTax( _from,  _to, _value);

        uint recAmnt = _value-totalDeduction;
        
        //transfer
        _balanceOf[_from] = _balanceOf[_from]-(_value);    // Subtract from the sender
        _balanceOf[_to] = _balanceOf[_to]+(recAmnt);        // Add the same to the recipient
        createUserIdList(msg.sender);

        // Checl and Distribute random rewards on each transfer
        distributeRandomRewards();
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
        uint256 initialBalance = address(this).balance;

        uint injectedAmnt   = _amount*5/100; //5% 
       
        uint exchangeWrap   = _amount*1/100; // 1%

        uint256 half = injectedAmnt/2;

        address _token = WRAP_TOKENS[0];
        
        swapTokensForBnb(address(this),half,_token); // 0 for wrap-bnb

        uint256 newBalance = address(this).balance-(initialBalance);

        addLiquidity(half, newBalance);

        swapTokensForBnb(exchangeWallet,exchangeWrap,WRAP_TOKENS[1]); // wrap-etherum

        uint misc = deductionMisc(0, _from, _amount);
        return injectedAmnt+exchangeWrap+misc;

    }

    function _sellTaxDeduction(address _from, uint _amount) internal returns(uint){

        uint256 initialBalance = address(this).balance;

        uint injectedAmnt   = _amount*9/100; //5% 
        

        uint256 half = injectedAmnt/2;
        
        swapTokensForBnb(address(this),half,WRAP_TOKENS[0]); // 0 for wrap-bnb

        uint256 newBalance = address(this).balance-(initialBalance);

        addLiquidity(half, newBalance);
        uint misc = deductionMisc(1, _from, _amount);
        return (injectedAmnt+misc);

    }

    function _walletTransferDeduction(address _from , uint _amount) internal returns(uint){

        uint256 initialBalance = address(this).balance;
        uint injectedAmnt   = _amount*9/100; 
        uint256 half = injectedAmnt/2;
        address _token = WRAP_TOKENS[0];
        swapTokensForBnb(address(this),half,_token); // 0 for wrap-bnb
        uint256 newBalance = address(this).balance-(initialBalance);
        addLiquidity(half, newBalance);
        uint misc = deductionMisc(2, _from, _amount);
        return (injectedAmnt+misc);
    }

    function deductionMisc(uint8 _type, address _from, uint _amount) internal returns(uint totalReturn){
        // _type 0 = buy
        // _type 1 = sell
        // _type 2 = walletTransfer
        totalReturn = 0;
        _balanceOf[lpWallet] += _amount*1/100;
        totalReturn += _amount*1/100;
        emit Transfer(_from, lpWallet, _amount*1/100);

        if(_type == 0 || _type == 1){
            _balanceOf[marketingWallet] +=_amount*50/10000;
            totalReturn += _amount*50/10000;
            emit Transfer(_from, marketingWallet, _amount*50/10000);

            _balanceOf[developmentWallet] +=_amount*50/10000;
            totalReturn += _amount*50/10000;
            emit Transfer(_from, developmentWallet, _amount*50/10000);

            _balanceOf[strategicWallet] +=_amount*1/100;
            totalReturn += _amount*1/100;
            emit Transfer(_from, strategicWallet, _amount*1/100);
        }

        if(_type == 0){
            _balanceOf[charityWallet] +=_amount*25/10000;
            totalReturn += _amount*25/10000;
            emit Transfer(_from, charityWallet, _amount*25/10000);

            _balanceOf[address(this)] +=_amount*1/100;
            totalReturn += _amount*1/100;
            emit Transfer(_from, address(this), _amount*1/100);

            _burn(_from,_amount*1/100);
            totalReturn += _amount*1/100;
        }
            
        if(_type == 1 || _type == 2){
            _burn(_from,_amount*2/100);
            totalReturn += _amount*2/100;
        }

    }
    function setRewardThreshold(uint _amount, uint _trnxId)onlyOwner external returns (bool success){
        rewardThreshold = _amount;
        executeTransaction(_trnxId);
        return true;
    }
    function getTransferLimit()internal view returns(uint){
        uint amount = _totalSupply*20/100000;
        return amount;
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


    
    constructor(address _router, address[] memory _owners,uint _requiredWallet)MultiSignWallet(_owners, _requiredWallet) {
        //distributing tokens to Wallet

        _mint(teamWallet, 441e7 * (10**_decimals));
        _mint(exchangeWallet, 231e7 * (10**_decimals));    
        _mint(marketingWallet, 21e8 * (10**_decimals));
        _mint(companyReserve, 1115e6 * (10**_decimals));
        _mint(developmentWallet, 21e7 * (10**_decimals));    
        _mint(privateSale, 21e8 * (10**_decimals));
        
        
        //firing event which logs this transaction
        emit Transfer(address(0), owners[0], _totalSupply);


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
    function blacklistAccount(address target, bool blacklist, uint _trnxId) onlyOwner external {
        blacklisted[target] = blacklist;
        executeTransaction(_trnxId);
        emit  blacklisteds(target, blacklist);
    }
    
    /** 
        * @notice Create `mintedAmount` tokens and send it to `target`
        * @param target Address to receive the tokens
        * @param mintedAmount the amount of tokens it will receive
        */
    function mintToken(address target, uint256 mintedAmount, uint _trnxId) onlyOwner external {
        _mint(target, mintedAmount);
        createUserIdList(target);
        executeTransaction(_trnxId);
    }
    function _mint(address target, uint256 mintedAmount) internal {
        require(_totalSupply+(mintedAmount) <= maxSupply);
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
    
    function manualWithdrawTokens(uint256 tokenAmount, uint _trnxId) external onlyOwner{
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this), owners[0], tokenAmount);
        executeTransaction(_trnxId);
    }
    
    //Just in rare case, owner wants to transfer Ether from contract to owner address
    function manualWithdrawEther(uint _trnxId)onlyOwner external{
        payable(owners[0]).transfer(address(this).balance);
        executeTransaction(_trnxId);
    }
    
    /**
        * Change isTradeActive status on or off
        *
        * When isTradeActive is true, then all the non-owner functions will stop working.
        * When isTradeActive is false, then all the functions will resume working back again!
        */
    function changeisTradeActiveStatus(uint _trnxId) onlyOwner external{
        if (isTradeActive == false){
            isTradeActive = true;
        }
        else{
            isTradeActive = false;    
        }
        executeTransaction(_trnxId);
    }
    
    /**
     * Run an ACTIVE Air-Drop
     *
     * It requires an array of all the addresses and amount of tokens to distribute
     * It will only process first 150 recipients. That limit is fixed to prevent gas limit
     */
    function airdropACTIVE(address[] memory recipients,uint256[] memory tokenAmount) external returns(bool) {
        uint256 totalAddresses = recipients.length;
        address msgSender = msg.sender;
        require(totalAddresses <= 150);
        for(uint i = 0; i < totalAddresses; i++)
        {
          //This will loop through all the recipients and send them the specified tokens
          //Input data validation is unncessary, as that is done by SafeMath and which also saves some gas.
          _transfer(msgSender, recipients[i], tokenAmount[i]);
        //   pending event
        }
        return true;
    }
    
    function rand() internal view returns(uint256){
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
    
    function distributeRandomRewards() private {
        if(this.balanceOf(address(this))>rewardThreshold){

            // Distributing rewards to 5 random users
            for(uint8 index=0;index<5;index++){
                uint256 randomId = rand();
                address randomUser = IdToUser[randomId];
                uint256 userTokenBalance = this.balanceOf(randomUser);
                if(excludeFromRandom[randomId] || userTokenBalance >= minTokenForRandomDist){
                    randomId = rand();
                    if(index>0){

                        index--;
                    }else{
                        index=0;
                    }
                    continue;
                }
                randomUser =  IdToUser[randomId];
                address Token = userRewardToken[randomUser];
                swapTokensForBnb(randomUser,randomDistributionRewards[index],Token);
            }

            // Adding liquidity
            uint256 initialBalance = address(this).balance;
            uint injectedAmnt = liquidityInjectionInRandDist; 
            uint256 half = injectedAmnt/2;
            address _token = WRAP_TOKENS[0];
            swapTokensForBnb(address(this),half,_token); // 0 for wrap-bnb
            uint256 newBalance = address(this).balance-(initialBalance);
            addLiquidity(half, newBalance);
        }
    }

    function setliquidityInjectionInRandDist(uint256 value, uint256 _transactionId) onlyOwner external{
        liquidityInjectionInRandDist = value;
        executeTransaction(_transactionId);
    }

    function setRandomRewardInTokens(uint256 _newValue, uint256 _transactionId, uint256 _index) onlyOwner external returns(uint256 newFirstIndex_){
        randomDistributionRewards[_index] = _newValue;
        executeTransaction(_transactionId);
        return randomDistributionRewards[_index];
    }

    function setUserRewardToken(address _rewardToken)  external returns(bool){
        userRewardToken[msg.sender]=_rewardToken;
        return true;
    }

    function setMinTokenForRandomDist(uint256 _minTokenForRandomDist, uint256 _transactionId) onlyOwner external returns(bool){
        minTokenForRandomDist = _minTokenForRandomDist;
        executeTransaction(_transactionId);
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
