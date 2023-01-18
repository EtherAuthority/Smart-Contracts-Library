pragma solidity 0.5.9; /*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



¦¦¦¦¦¦¦+    ¦¦¦¦¦¦+     ¦¦¦¦¦¦¦+    ¦¦¦¦¦¦+      ¦¦¦¦¦¦+     ¦¦+  ¦¦+
¦¦+----+    ¦¦+--¦¦+    ¦¦+----+    ¦¦+--¦¦+    ¦¦+---¦¦+    +¦¦+¦¦++
¦¦¦¦¦+      ¦¦¦¦¦¦++    ¦¦¦¦¦+      ¦¦¦  ¦¦¦    ¦¦¦   ¦¦¦     +¦¦¦++ 
¦¦+--+      ¦¦+--¦¦+    ¦¦+--+      ¦¦¦  ¦¦¦    ¦¦¦   ¦¦¦     ¦¦+¦¦+ 
¦¦¦¦¦¦¦+    ¦¦¦  ¦¦¦    ¦¦¦¦¦¦¦+    ¦¦¦¦¦¦++    +¦¦¦¦¦¦++    ¦¦++ ¦¦+
+------+    +-+  +-+    +------+    +-----+      +-----+     +-+  +-+
                                                                     
  
=== 'Eredox' Token contract with following features ===
      => ERC20 Compliance
      => Higher degree of control by owner - safeguard functionality
      => SafeMath implementation 
      => Burnable and minting 
      => user whitelisting 
      => Token swap functionality (implemented for the future use)
      => Stagged ICO


======================= Quick Stats ===================
    => Name        : Eredox
    => Symbol      : EROX
    => Total supply: 4,000,000,000 (4 Billion)
    => Reserved for ICO: 50%
    => Decimals    : 18


-------------------------------------------------------------------
 Copyright (c) 2019 onwards Eredox Pty Ltd. ( https://Eredox.com )
 Contract designed by EtherAuthority ( https://EtherAuthority.io )
-------------------------------------------------------------------
*/ 


//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//
/**
    * @title SafeMath
    * @dev Math operations with safety checks that throw on error
    */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
 

    
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
    
contract Eredox is owned {
    

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    string constant public name = "Eredox";
    string constant public symbol = "EROX";
    uint256 constant public decimals = 18;
    uint256 public totalSupply = 4000000000 * (10**decimals);   //4 billion tokens
    uint256 public maxTokenSupply;
    bool public safeguard = false;  //putting safeguard on will halt all non-owner functions
    bool public tokenSwap = false;  //when tokenSwap will be on then all the token transfer to contract will trigger token swap

    // This creates a mapping with all data storage
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;


    /*===============================
    =         PUBLIC EVENTS         =
    ===============================*/

    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
        
    // This generates a public event for frozen (blacklisting) accounts
    event FrozenAccount(address target, bool frozen);
    
    // This will log approval of token Transfer
    event Approval(address indexed from, address indexed spender, uint256 value);

    // This is for token swap
    event TokenSwap(address indexed user, uint256 value);


    /*======================================
    =       STANDARD ERC20 FUNCTIONS       =
    ======================================*/

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        
        //code for token swap.
        if(tokenSwap && _to == address(this)){
            //fire tokenSwap event. This event can be listed by oracle and issue tokens of ethereum or another blockchain
            emit TokenSwap(msg.sender, _value);
        }
        
        //checking conditions
        require(!safeguard);
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        
        // overflow and undeflow checked by SafeMath Library
        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
        
        // emit Transfer event
        emit Transfer(_from, _to, _value);
    }

    /**
        * Transfer tokens
        *
        * Send `_value` tokens to `_to` from your account
        *
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transfer(address _to, uint256 _value) public returns (bool success) {
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
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
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!safeguard);
        require(balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    /*=====================================
    =       CUSTOM PUBLIC FUNCTIONS       =
    ======================================*/
    
    constructor() public{
        //sending 50% to owner and keep remaining 50% in smart contract for ICO
        uint256 tokens = totalSupply / 2;
        balanceOf[owner] = tokens;
        balanceOf[address(this)] = tokens;
        
        maxTokenSupply = totalSupply;
        
        //firing event which logs this transaction
        emit Transfer(address(0), owner, tokens);
        emit Transfer(address(0), address(this), tokens);
    }
    

    /**
        * Destroy tokens
        *
        * Remove `_value` tokens from the system irreversibly
        *
        * @param _value the amount of money to burn
        */
    function burn(uint256 _value) public returns (bool success) {
        require(!safeguard);
        //checking of enough token balance is done by SafeMath
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);  // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
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
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(!safeguard);
        //checking of allowance and token value is done by SafeMath
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value); // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                                   // Update totalSupply
        emit  Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }
        
    
    /** 
        * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
        * @param target Address to be frozen
        * @param freeze either to freeze it or not
        */
    function freezeAccount(address target, bool freeze) onlyOwner public {
            frozenAccount[target] = freeze;
        emit  FrozenAccount(target, freeze);
    }
    
    /** 
        * @notice Create `mintedAmount` tokens and send it to `target`
        * @param target Address to receive the tokens
        * @param mintedAmount the amount of tokens it will receive
        */
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        
        require(totalSupply <= maxTokenSupply, 'Minting not possible more than maxTokenSupply');
        
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }

        

    /**
        * Owner can transfer tokens from contract to owner address
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    
    function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner{
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this), owner, tokenAmount);
    }
    
    //Just in rare case, owner wants to transfer Ether from contract to owner address
    function manualWithdrawEther()onlyOwner public{
        address(owner).transfer(address(this).balance);
    }
    
    /**
        * Change safeguard status on or off
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    function changeSafeguardStatus() onlyOwner public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;    
        }
    }
    
    /**
     * This function allows enable admins to start or stop token swaps.
     */
    function changeTokenSwapStatus() public onlyOwner{
        if (tokenSwap == false){
            tokenSwap = true;
        }
        else{
            tokenSwap = false;    
        }
    }
    
    
    
    
    /*************************************/
    /*  Section for User whitelisting    */
    /*************************************/
    bool public whitelistingStatus;
    mapping (address => bool) public whitelisted;
    
    /**
     * Change whitelisting status on or off
     *
     * When whitelisting is true, then crowdsale will only accept investors who are whitelisted.
     */
    function changeWhitelistingStatus() onlyOwner public{
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
    function whitelistUser(address userAddress) onlyOwner public{
        require(whitelistingStatus == true);
        require(userAddress != address(0));
        whitelisted[userAddress] = true;
    }
    
    /**
     * Whitelist Many user address at once - only Owner can do this
     * It will require maximum of 150 addresses to prevent block gas limit max-out and DoS attack
     * It will add user address in whitelisted mapping
     */
    function whitelistManyUsers(address[] memory userAddresses) onlyOwner public{
        require(whitelistingStatus == true);
        uint256 addressCount = userAddresses.length;
        require(addressCount <= 150);
        for(uint256 i = 0; i < addressCount; i++){
            whitelisted[userAddresses[i]] = true;
        }
    }
    
    
    
    
    /******************************/
    /*   Code for the Crowdsale   */
    /******************************/
    
    /* TECHNICAL SPECIFICATIONS:
    
    => Private-sale Starts  :  TBA
    => ICO will start       :  TBA
    => ICO Ends             :  TBA
    => Coins reserved for ICO   : 2 Billion (50% of total supply)
    => Minimum Contribution     : 0.01 ETH (Private-sale and Main-sale)
    => Hard cap                 : 157,500 ETH
    => Token Prices:
        * Private sale      :  1 ETH = 18,667 EROX
        * Main Sale Stage 1 :  1 ETH = 11,200 EROX
        * Main Sale Stage 2 :  1 ETH = 10,000 EROX
        * Main Sale Stage 3 :  1 ETH =  9,600 EROX
        * Main Sale Stage 4 :  1 ETH =  9,200 EROX
        * Main Sale Stage 5 :  1 ETH =  8,640 EROX
        * Main Sale Stage 6 :  1 ETH =  8,000 EROX

    */

    //public variables for the Crowdsale
    uint256 public datePivateSale   = 1541059200;
    uint256 public dateICOStage1    = 1546329600;    
    uint256 public dateICOStage2    = 1546329600;    
    uint256 public dateICOStage3    = 1546329600;    
    uint256 public dateICOStage4    = 1546329600;    
    uint256 public dateICOStage5    = 1546329600;   
    uint256 public dateICOStage6    = 1546329600; 
    uint256 public dateICOFinished  = 1546329600; 
    
    uint256 public tokenPricePrivateSale = 18667;
    uint256 public tokenPriceMainSale1   = 11200;
    uint256 public tokenPriceMainSale2   = 10000;
    uint256 public tokenPriceMainSale3   =  9600;
    uint256 public tokenPriceMainSale4   =  9200;
    uint256 public tokenPriceMainSale5   =  8640;
    uint256 public tokenPriceMainSale6   =  8000;
   
    uint256 public tokensSold;                  // how many tokens sold through crowdsale
    uint256 public etherRaised;                 // how much ether raised through crowdsale
    uint256 public minimumContribution = 1e16;  // Minimum amount to invest - 0.01 ETH (in 18 decimal format)
    uint256 public hardCap = 157500 * (10 ** decimals);

    /**
     * fallback function, only accepts ether if pre-sale or ICO is running or Reject
     */
    function () payable external {
        
        require(!safeguard);
        require(!frozenAccount[msg.sender]);
        if(whitelistingStatus == true)  require(whitelisted[msg.sender]); 
        require(datePivateSale < now);
        require(dateICOFinished > now);
        require(msg.value  >= minimumContribution);   //converting msg.value wei into 2 decimal format
        require (etherRaised <= hardCap);
        
        // calculate token amount to be sent
        uint256 token = msg.value.mul(findCurrentTokenPrice());  //weiamount * current token price
        
        //adding purchase bonus if applicable
        token = token.add(token * purchaseBonusPercentage(msg.value) / 100 );
        
        tokensSold = tokensSold.add(token);
        etherRaised += msg.value;
        _transfer(address(this), msg.sender, token);                  //makes the transfers
        
        //send Ether to owner
        forwardEherToOwner();                                               
    }
    
    /**
     * Calculates price of token based on ICO Stage
     */
    function findCurrentTokenPrice() public view returns (uint256){
        
        uint256 currentTimeStamp = now;
        
        if(datePivateSale <= currentTimeStamp && dateICOStage1 > currentTimeStamp ) return tokenPricePrivateSale;
        
        if(dateICOStage1 <= currentTimeStamp && dateICOStage2 > currentTimeStamp ) return tokenPriceMainSale1;
        
        if(dateICOStage2 <= currentTimeStamp && dateICOStage3 > currentTimeStamp ) return tokenPriceMainSale2;
    
        if(dateICOStage3 <= currentTimeStamp && dateICOStage4 > currentTimeStamp ) return tokenPriceMainSale3;
        
        if(dateICOStage4 <= currentTimeStamp && dateICOStage5 > currentTimeStamp ) return tokenPriceMainSale4;
        
        if(dateICOStage5 <= currentTimeStamp && dateICOStage6 > currentTimeStamp ) return tokenPriceMainSale5;
        
        if(dateICOStage6 <= currentTimeStamp && dateICOFinished > currentTimeStamp ) return tokenPriceMainSale6;
        
        //by default it will return zero
        
    }
    
    /**
     * This will calculate the percentage for the purchase bonus.
     * Purchase bonus is certain percentage of extra tokens depending on amount of ether invested.
     */
     function purchaseBonusPercentage(uint256 etherInvested) pure internal returns(uint256){
         
         if(etherInvested < (5 * 1e18)) return 0;
         
         if(etherInvested >= (5 * 1e18) && etherInvested <  (15 * 1e18)) return 5;
         
         if(etherInvested >= (15 * 1e18)) return 15;
         
     }

    
    /**
     * Automatocally forwards ether from smart contract to owner address
     */
    function forwardEherToOwner() internal {
        owner.transfer(msg.value); 
    }

    
    /**
     * updates ICO dates
     */
     function updateICOdates(uint256 _datePivateSale, uint256 _dateICOStage1, uint256 _dateICOStage2, uint256 _dateICOStage3, uint256 _dateICOStage4, uint256 _dateICOStage5, uint256 _dateICOStage6, uint256 _dateICOFinished ) public onlyOwner returns(string memory){
        
        datePivateSale   = _datePivateSale;
        dateICOStage1    = _dateICOStage1;    
        dateICOStage2    = _dateICOStage2;    
        dateICOStage3    = _dateICOStage3;    
        dateICOStage4    = _dateICOStage4;    
        dateICOStage5    = _dateICOStage5;   
        dateICOStage6    = _dateICOStage6; 
        dateICOFinished  = _dateICOFinished; 
        
        return("ICO Dates are updated successfully");
     }
     
    /**
    * update token price for all ico stages
    */
    function updateTokenPrices(uint256 _tokenPricePrivateSale, uint256 _tokenPriceMainSale1, uint256 _tokenPriceMainSale2, uint256 _tokenPriceMainSale3, uint256 _tokenPriceMainSale4, uint256 _tokenPriceMainSale5, uint256 _tokenPriceMainSale6 ) public onlyOwner returns(string memory){
      
        tokenPricePrivateSale = _tokenPricePrivateSale;
        tokenPriceMainSale1   = _tokenPriceMainSale1;
        tokenPriceMainSale2   = _tokenPriceMainSale2;
        tokenPriceMainSale3   = _tokenPriceMainSale3;
        tokenPriceMainSale4   = _tokenPriceMainSale4;
        tokenPriceMainSale5   = _tokenPriceMainSale5;
        tokenPriceMainSale6   = _tokenPriceMainSale6;
      
        return("Token prices are updated successfully");
    }
    

}
