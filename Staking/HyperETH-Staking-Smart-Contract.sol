pragma solidity 0.5.4;


/**
 * @title PoSTokenStandard
 * @dev the interface of PoSTokenStandard
 */
contract PoSTokenStandard {
    uint256 public stakeStartTime;
    uint256 public stakeMinAge;
    uint256 public stakeMaxAge;
    function mint() public returns (bool);
    function coinAge() public view returns (uint256);
    function annualInterest() public view returns (uint256);
    event Mint(address indexed _address, uint _reward);
}

/***
 * https://hypereth.net
 *
 * No administrators or developers, this contract is fully autonomous
 *
 * 12 % entry fee
 * 10 % of entry fee to masternode referrals
 * 0 % transfer fee
 * 15 % exit fee
 * 1 % dividends fee on all the dividends balance
 */
contract HyperEX is PoSTokenStandard {

  using SafeMath for uint;
  using SafeMath for uint256;

    /*=================================
    =            MODIFIERS            =
    =================================*/

    /// @dev Only people with tokens
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

    /// @dev Only people with profits
    modifier onlyStronghands {
        require(myDividends(true) > 0);
        _;
    }

    /// @dev notGasbag
    modifier notGasbag() {
      require(tx.gasprice < 200999999999);
      _;
    }

    /// @dev Preventing unstable dumping and limit ambassador mine
    modifier antiEarlyWhale {
        if (address(this).balance  -msg.value < whaleBalanceLimit){
          require(msg.value <= maxEarlyStake);
        }
        if (depositCount_ == 0){
          require(ambassadors_[msg.sender] && msg.value == 0.001 ether);
        }else
        if (depositCount_ == 1){
          require(ambassadors_[msg.sender] && msg.value == 0.002 ether);
        }else
        if (depositCount_ == 2){
          require(ambassadors_[msg.sender] && msg.value == 0.003 ether);
        }
        _;
    }

    /// @dev notGasbag
    modifier isControlled() {
      require(isPremine() || isStarted());
      _;
    }

    /*==============================
    =            EVENTS            =
    ==============================*/

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp,
        uint256 price
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned,
        uint timestamp,
        uint256 price
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    string public name = "Test Token";
    string public symbol = "TST";
    uint8 constant public decimals = 18;

    /// @dev 12% dividends for token purchase
    uint8 constant internal entryFee_ = 12;

    /// @dev 15% dividends for token selling
    uint8 constant internal startExitFee_ = 15;

    /// @dev 15% dividends for token selling after step
    uint8 constant internal finalExitFee_ = 15;

    /// @dev Exit fee falls over period of 30 days
    uint256 constant internal exitFeeFallDuration_ = 1 days;

    /// @dev 10% masternode
    uint8 constant internal refferalFee_ = 10;
    
    /// @dev 5% goes to dividendPoolNEW while token purchase
    uint256 public buyFeeDividendPool = 5;
    
    /// @dev 1% dividends fee. this will be reduction on the all the dividends balance by 1%
    uint256 public dividendsFee = 1;

    /// @dev P3D pricing
    uint256 internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 internal tokenPriceIncremental_ = 0.00000001 ether;

    uint256 constant internal magnitude = 2 ** 64;

    /// @dev 300 needed for masternode activation
    uint256 public stakingRequirement = 100e18;

    /// @dev anti-early-whale
    uint256 public maxEarlyStake = 5 ether;
    uint256 public whaleBalanceLimit = 75 ether;

    /// @dev apex starting gun
    address public apex;

    /// @dev starting
    uint256 public startTime = 0; //  January 1, 1970 12:00:00

    ///PoSToken
    uint public chainStartTime; //chain start time
    uint public chainStartBlockNumber; //chain start block number
    uint public stakeStartTime; //stake start time
    uint public stakeMinAge = 2; // minimum age for coin age: 3D
    uint public stakeMaxAge = 90 days; // stake age of full weight: 90D
    uint public maxMintProofOfStake = 10**17; // default 10% annual interest
    uint public stakeMinAmount = 500 * (10**uint(decimals));

    struct transferInStruct{
    uint128 amount;
    uint64 time;
    }

    mapping(address => transferInStruct[]) transferIns;

   /*=================================
    =            DATASETS            =
    ================================*/

    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) public referralBalance_;
    mapping(address => uint256) internal bonusBalance_;
    mapping(address => uint256) internal payoutsTo_;
    uint256 internal tokenSupply_;
    uint256 public profitPerShare_;
    uint256 public depositCount_;
    mapping(address => bool) internal ambassadors_;
    
    //new dividend tracker variables
    uint256 public dividendPoolNEW;
    mapping(address => uint256) public dividendPaidTotal;
    mapping(address=>uint256) public tokenTrackerForDividends;

    
    /*=======================================
    =            CONSTRUCTOR                =
    =======================================*/

   constructor (uint timestamp) public {

     //PoSToken
     chainStartTime = now;
     chainStartBlockNumber = block.number;

     require(timestamp >= chainStartTime);
     stakeStartTime = timestamp;

     //HyperETH Funding Allocations
     ambassadors_[msg.sender]=true;
     //1
     ambassadors_[0x73018870D10173ae6F71Cac3047ED3b6d175F274]=true;

     apex = msg.sender;
   }

    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/

    // @dev Function setting the start time of the system
    function setStartTime(uint256 _startTime) public {
      require(msg.sender==apex && !isStarted() && now < _startTime);
      startTime = _startTime;
    }

    /// @dev Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)
    function buy(address _referredBy) antiEarlyWhale notGasbag isControlled public payable  returns (uint256) {
        purchaseTokens(msg.value, _referredBy , msg.sender);
    }

    /// @dev Converts to tokens on behalf of the customer - this allows gifting and integration with other systems
    function buyFor(address _referredBy, address _customerAddress) antiEarlyWhale notGasbag isControlled public payable returns (uint256) {
        purchaseTokens(msg.value, _referredBy , _customerAddress);
    }

    /**
     * @dev Fallback function to handle ethereum that was send straight to the contract
     *  Unfortunately we cannot use a referral address this way.
     */
    function() antiEarlyWhale notGasbag isControlled payable external {
        purchaseTokens(msg.value, address(0) , msg.sender);
    }

    /// @dev Converts all of caller's dividends to tokens.
    function reinvest() onlyStronghands public {
        // fetch dividends
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        dividendPaidTotal[_customerAddress] +=  _dividends;

        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_dividends, address(0) , _customerAddress);

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    /// @dev Alias of sell() and withdraw().
    function exit() public {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);

        // capitulation
        withdraw();
    }

    /// @dev Withdraws all of the callers earnings.
    function withdraw() onlyStronghands public {
        // setup data
        address payable _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code

        // update dividend tracker
        dividendPaidTotal[_customerAddress] =  dividendPaidTotal[_customerAddress].add(_dividends);

        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // lambo delivery service
        _customerAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends);
    }

    /// @dev Liquifies tokens to ethereum.
    function sell(uint256 _amountOfTokens) onlyBagholders public {
        // setup data
        address _customerAddress = msg.sender;
        // russian hackers BTFO
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee()), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        
        //update custom dividends tracker
        tokenTrackerForDividends[_customerAddress] = tokenTrackerForDividends[_customerAddress].sub(_tokens);

       
        // update dividends tracker
        uint256 _updatedPayouts = (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }
       
        // transfer the _taxedEthereum to caller
        msg.sender.transfer(_taxedEthereum);

        // fire event
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());
    }

    /**
     * @dev Transfer tokens from the caller to a new holder.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders public returns (bool) {

        if(msg.sender == _toAddress) return mint();

        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        // withdraw all outstanding dividends first
        if (myDividends(true) > 0) {
            withdraw();
        }

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

        //update custom dividend tracker
        tokenTrackerForDividends[_customerAddress] = tokenTrackerForDividends[_customerAddress].sub(_amountOfTokens);
        tokenTrackerForDividends[_toAddress] = tokenTrackerForDividends[_toAddress].add(_amountOfTokens);

        
      /*  // update dividend trackers
        payoutsTo_[_customerAddress] -=  (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] +=  (profitPerShare_ * _amountOfTokens);
        
       */ 

        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

        if(transferIns[_customerAddress].length > 0) delete transferIns[_customerAddress];
        uint64 _now = uint64(now);
        transferIns[_customerAddress].push(transferInStruct(uint128(tokenBalanceLedger_[_customerAddress]),_now));
        transferIns[_toAddress].push(transferInStruct(uint128(_amountOfTokens),_now));

        // ERC20
        return true;
    }


    /*=====================================
    =      HELPERS AND CALCULATORS        =
    =====================================*/

    /**
     * @dev Method to view the current Ethereum stored in the contract
     *  Example: totalEthereumBalance()
     */
    function totalEthereumBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev Retrieve the total token supply.
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /// @dev Retrieve the tokens owned by the caller.
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * @dev Retrieve the dividends owned by the caller.
     *  If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     *  The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     *  But in the internal calculations, we want them separate.
     */
    function myDividends(bool _includeReferralBonus) public view returns (uint256) {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /// @dev Retrieve the dividend balance of any single address.
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        
        //share percentage is calculated based on no. of token hold by user vs total supply
        //1000000 is added just because sharePercentage variable can have 6 decimals.
        uint256 sharePercentage = tokenTrackerForDividends[_customerAddress] * 100 * 1000000 / tokenSupply_;
 
        
        
        if(sharePercentage > 0){
            uint256 _dividends =  ((dividendPoolNEW * sharePercentage / 100) / 1000000); //dividing with 1000000 because sharePercentage was multiplied with it.
        
            if(_dividends > dividendPaidTotal[_customerAddress]){
                return _dividends - dividendPaidTotal[_customerAddress];
            }
        }
        
        return 0;
        
      /*
        uint256 _dividends =   SafeMath.sub(SafeMath.mul(profitPerShare_ , divHolderAmount[_customerAddress]) , payoutsTo_[_customerAddress]) / magnitude;
        //deducting the dividendsFee. No SafeMath used as overflow is impossible
        return _dividends - (_dividends*dividendsFee/100) ;
        */
              
    }
    
    /// @dev Change dividendsFee. This can be done only by apex
    function changeDividendsFee(uint256 _newDividendsFee) public {
        require(msg.sender == apex, 'Apex only can make changes to dividendsFee');
        require(_newDividendsFee <= 5, 'dividendsFee can not be more than 5%');
        dividendsFee = _newDividendsFee;
    }

    /// @dev Return the sell price of 1 individual token.
    function sellPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply. Doh.
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee()), 100);
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

            return _taxedEthereum;
        }
    }

    /// @dev Return the buy price of 1 individual token.
    function buyPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply. Doh.
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, entryFee_), 100);
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);

            return _taxedEthereum;
        }
    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of buy orders.
    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, entryFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of sell orders.
    function calculateEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee()), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }

    /// @dev Function for the frontend to get untaxed receivable ethereum.
    function calculateUntaxedEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        //uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee()), 100);
        //uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _ethereum;
    }


    /// @dev Function for getting the current exitFee
    function exitFee() public view returns (uint8) {
        if (startTime==0){
           return startExitFee_;
        }
        if ( now < startTime) {
          return 0;
        }
        uint256 secondsPassed = now - startTime;
        if (secondsPassed >= exitFeeFallDuration_) {
            return finalExitFee_;
        }
        uint8 totalChange = startExitFee_ - finalExitFee_;
        uint8 currentChange = uint8(totalChange * secondsPassed / exitFeeFallDuration_);
        uint8 currentFee = startExitFee_- currentChange;
        return currentFee;
    }

    // @dev Function for find if premine
    function isPremine() public view returns (bool) {
      return depositCount_<=2;
    }

    // @dev Function for find if premine
    function isStarted() public view returns (bool) {
      return startTime!=0 && now > startTime;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    /// @dev Internal function to actually purchase the tokens.
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy , address _customerAddress) internal returns (uint256) {
        // data setup
        uint256 initialDiv;
        if(tokenSupply_ > 0){
            initialDiv = dividendsOf(msg.sender);
        }
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, entryFee_), 100);
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_incomingEthereum, refferalFee_), 100);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 dividendPoolAmount = _incomingEthereum * buyFeeDividendPool / 100;
        
        
        // no point in continuing execution if OP is a poorfag russian hacker
        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world
        // (or hackers)
        // and yes we know that the safemath function automatically rules out the "greater then" equasion.
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);

        // is the user referred by a masternode?
        if (
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&

            // no cheating!
            _referredBy != _customerAddress &&

            // does the referrer have at least X whole tokens?
            // i.e is the referrer a godly chad masternode
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
            // wealth redistribution
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
        } else {
            //if there is no referrer, then 2% goes to Apex and 13% goes to dividend pool
            referralBalance_[apex] = SafeMath.add(referralBalance_[apex], _incomingEthereum * 2 / 100);
            dividendPoolAmount = _incomingEthereum * 13 / 100;
        }

        // we can't give people infinite ethereum
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / tokenSupply_);

        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        
        
        delete transferIns[_customerAddress];
        transferIns[_customerAddress].push(transferInStruct(uint128(tokenBalanceLedger_[_customerAddress]),uint64(now)));
        
        //update custom dividend tracker
        tokenTrackerForDividends[_customerAddress] = tokenTrackerForDividends[_customerAddress].add(_amountOfTokens);

        
        //NEW dividend processing logic
        
        dividendPoolNEW = dividendPoolNEW.add( dividendPoolAmount );
        
        uint256 currentDiv = dividendsOf(msg.sender).sub(initialDiv);
        
        dividendPaidTotal[_customerAddress] = dividendPaidTotal[_customerAddress].add(currentDiv);

        

        // fire event
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());

        // Keep track
        depositCount_++;
        return _amountOfTokens;
    }

    function mint() public  returns (bool) {
        if(tokenBalanceLedger_[msg.sender] <= stakeMinAmount) return false;
        if(transferIns[msg.sender].length <= 0) return false;

        uint reward = getProofOfStakeReward(msg.sender);
        if(reward <= 0) return false;

        uint prevSupply = tokenSupply_;

        tokenSupply_ = SafeMath.add(tokenSupply_,reward);

        // update the amount of dividends per token since no eth is received
        profitPerShare_ = SafeMath.mul(profitPerShare_, prevSupply);
        profitPerShare_ = SafeMath.div(profitPerShare_, tokenSupply_);

        tokenPriceInitial_ = SafeMath.mul(tokenPriceInitial_,prevSupply);
        tokenPriceInitial_ = SafeMath.div(tokenPriceInitial_,tokenSupply_);

        tokenPriceIncremental_ = SafeMath.mul(tokenPriceIncremental_,prevSupply);
        tokenPriceIncremental_ = SafeMath.div(tokenPriceIncremental_,tokenSupply_);

        

        //calculating Mint Fee as 2% of the stakes generated for Ether deduction
        uint256 mintFee = reward * 2 / 100;
        //If user have dividends more than mint fee, then first deduct from it
        if(mintFee <= dividendsOf(msg.sender)){
            //we will add mintFee in dividendPaidTotal mapping so that it will be deducted indirectly
            dividendPaidTotal[msg.sender] = dividendPaidTotal[msg.sender].add(mintFee);
        }
        //else if user has referral earning available more than mintFee, then deduct from it
        else if(mintFee <= referralBalance_[msg.sender]){
            referralBalance_[msg.sender] = referralBalance_[msg.sender].sub(mintFee);
        }
        //if nothing worked then we just remove 4% (which is doubled of mintFee) and deduct that from stakes
        else{
            reward = reward.sub(mintFee*2);
        }
        
        
        tokenBalanceLedger_[msg.sender] =  SafeMath.add(tokenBalanceLedger_[msg.sender],reward);
        delete transferIns[msg.sender];
        transferIns[msg.sender].push(transferInStruct(uint128(tokenBalanceLedger_[msg.sender]),uint64(now)));
        
        emit Mint(msg.sender, reward);
        return true;
    }

    function getProofOfStakeReward(address _address) public view returns (uint) {
        require( (now >= stakeStartTime) && (stakeStartTime > 0) );

        uint _now = now;
        uint _coinAge = getCoinAge(_address, _now);
        if(_coinAge <= 0) return 0;

        uint interest = (3650 * maxMintProofOfStake).div(100); //2% daily

        return (_coinAge * interest).div(365 * (10**uint(decimals)));
    }

    function getCoinAge(address _address, uint _now) internal view returns (uint _coinAge) {
        if(transferIns[_address].length <= 0) return 0;

        for (uint i = 0; i < transferIns[_address].length; i++){
            if( _now < uint(transferIns[_address][i].time).add(stakeMinAge) ) continue;

            uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
            if( nCoinSeconds > stakeMaxAge ) nCoinSeconds = stakeMaxAge;

            _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(2 minutes));
        }

        _coinAge = _coinAge.div(2);
    }

    function getBlockNumber() public view returns (uint blockNumber) {
        blockNumber = block.number.sub(chainStartBlockNumber);
    }

    function coinAge() public view returns (uint myCoinAge) {
        myCoinAge = getCoinAge(msg.sender,now);
    }

    function annualInterest() public view returns(uint interest) {
        interest = (3650 * maxMintProofOfStake).div(100); //2% daily
    }

    /**
     * @dev Calculate Token price based on an amount of incoming ethereum
     *  It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     *  Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function ethereumToTokens_(uint256 _ethereum) internal view returns (uint256) {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
         (
            (
                // underflow attempts BTFO
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial ** 2)
                            +
                            (2 * (tokenPriceIncremental_ * 1e18) * (_ethereum * 1e18))
                            +
                            ((tokenPriceIncremental_ ** 2) * (tokenSupply_ ** 2))
                            +
                            (2 * tokenPriceIncremental_ * _tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            ) / (tokenPriceIncremental_)
        ) - (tokenSupply_);

        return _tokensReceived;
    }

    /**
     * @dev Calculate token sell value.
     *  It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     *  Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tokensToEthereum_(uint256 _tokens) internal view returns (uint256) {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
            // underflow attempts BTFO
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ + (tokenPriceIncremental_ * (_tokenSupply / 1e18))
                        ) - tokenPriceIncremental_
                    ) * (tokens_ - 1e18)
                ), (tokenPriceIncremental_ * ((tokens_ ** 2 - tokens_) / 1e18)) / 2
            )
        / 1e18);

        return _etherReceived;
    }

    /// @dev This is where all your gas goes.
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }


}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}
