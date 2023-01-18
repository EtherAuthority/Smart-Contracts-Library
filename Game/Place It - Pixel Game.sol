pragma solidity 0.4.25; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



██████╗ ██╗      █████╗  ██████╗███████╗    ██╗████████╗
██╔══██╗██║     ██╔══██╗██╔════╝██╔════╝    ██║╚══██╔══╝
██████╔╝██║     ███████║██║     █████╗      ██║   ██║   
██╔═══╝ ██║     ██╔══██║██║     ██╔══╝      ██║   ██║   
██║     ███████╗██║  ██║╚██████╗███████╗    ██║   ██║   
╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝    ╚═╝   ╚═╝   
                                                        

// ----------------------------------------------------------------------------
// 'PlaceIt' Token contract with following features
//      => PlaceIt - Game complete functionality
//      => TR20 Compliance
//      => Higher degree of control by owner
//      => selfdestruct ability by owner
//      => SafeMath implementation 
//      => Burnable and no minting
//
// Name        : PlaceIt
// Symbol      : PLACE
// Total supply: 1,000,000,000 (1 Billion)
// Decimals    : 8
//
// Copyright (c) 2019 PlaceIt Inc. ( https://PlaceIt.io )
// Contract designed by EtherAuthority ( https://EtherAuthority.io )
// ----------------------------------------------------------------------------
  
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
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address public owner;
    
     constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
    
    

//*************************************************************//
//------------------ TR20 Standard Template -------------------//
//*************************************************************//
    
contract TokenTR20 {
    // Public variables of the token
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint256 public decimals = 8; 
    uint256 public totalSupply;
    bool public safeguard = false;  //putting safeguard on will halt all non-owner functions

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor (
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply.mul(10**decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;            // All the tokens will be sent to owner
        name = tokenName;                               // Set the name for display purposes
        symbol = tokenSymbol;                           // Set the symbol for display purposes
        
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    /**
     * fallback function. It just accepts any incoming fund into smart contract
     */
    function () payable external { }


    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(!safeguard);
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to].add(_value) > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
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
        require(!safeguard);
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
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        require(!safeguard);
        allowance[msg.sender][_spender] = _value;
        return true;
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
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
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
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                              // Update totalSupply
        emit  Burn(_from, _value);
        return true;
    }
    
}
    
//**************************************************************************//
//---------------------  PLACEIT MAIN CODE STARTS HERE ---------------------//
//**************************************************************************//
    
contract PlaceIt is owned, TokenTR20 {
        
        
    /*********************************/
    /* Code for the TR20 PLACE Token */
    /*********************************/

    /* Public variables of the token */
    string private tokenName = "PlaceIt";       //Name of the token
    string private tokenSymbol = "PLACE";       //Symbol of the token
    uint256 private initialSupply = 1000000000; //1 Billion
    uint256 public sellPrice = 10;              //Price to sell tokens to smart contract
    uint256 public buyPrice = 10;               //Price to buy tokens from smart contract
    
    
    /* Records for the fronzen accounts */
    mapping (address => bool) public frozenAccount;
    
    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor () TokenTR20(initialSupply, tokenName, tokenSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require(!safeguard);
        require (_to != address(0x0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);               // Check if the sender has enough
        require (balanceOf[_to].add(_value) >= balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }
    
    /**
     * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
     * @param target Address to be frozen
     * @param freeze either to freeze it or not
     */
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit  FrozenFunds(target, freeze);
    }
    
    /**
     * @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
     * @param newSellPrice Price the users can sell to the contract
     * @param newBuyPrice Price users can buy from the contract
     */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /**
     * @notice Buy tokens from contract by sending ether
     */
    function buyTokens() payable public {
        uint256 amount = msg.value.mul(buyPrice).div(1e10); // calculates the amount
        _transfer(address(this), msg.sender, amount);       // makes the transfers
    }

    /**
     * @notice Sell `amount` tokens to contract
     * @param amount amount of tokens to be sold. It must be in 8 decimals
     */
    function sellTokens(uint256 amount) public {
        address myAddress = address(this);
        uint256 tronAmount = amount.mul(1e10).div(sellPrice);
        require(myAddress.balance >= tronAmount);   // checks if the contract has enough ether to buy
        _transfer(msg.sender, address(this), amount);       // makes the transfers
        msg.sender.transfer(tronAmount);            // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }

    /*********************************/
    /*  Code for Main PlaceIt Game   */
    /*********************************/
    
    //--- Public variables of the PlaceIt -------------//
    uint256 public pixelPrice = 10 * (10**decimals);                   //10 TRX for 1 pixel
    uint256 public communityPoolVolume = 0;                            //Total TRX accumulated for commuinty pool for any given round
    uint256 public minimumTokenRequirement = 500 * (10**decimals);     //User must have at least 500 Tokens to be eligible to receive winnings
    uint256 public poolMinimumRequirement = 7000000 * (10**decimals);  //7 Million
    uint256 public communityMinimumPixel = 100;                        //Community must have this many pixel purchased to be eligible for winning
    uint256 public createCommunityFee = 1000 * (10**decimals);         //1000 TRX to create a community
    uint256 public joinCommunityFee = 100 * (10**decimals);            //100 TRX to join a community
    uint256 public leaveCommunityFee = 1 * (10**decimals);             //1 TRX to leave a community
    address public foundersAddress  = TH2se4Ccx5LbGeLMYGqkDVQbNoDPo3E8zF;
    address public developersAddress  = TQ9KeSAi8PXvPWVYyTaVF9jdp65FTBACyf;
    address public maintainanceAddress  = TGGnB81bATA6he2ZEVeFzXU2yzmi5YZ49m;
    address public charityAddress  = TBBnsH1UJMMyjAKWQj3cKtfSmQzsDK78aN;
    
    
    //--- Data storage variables -----------------------//
    mapping(bytes32=>bool) public allCommunities;       //Mapping holds whether community exist
    mapping(bytes32=>address[]) communityTotalUsers;//Mapping holds total users for each community
    mapping(address=>uint) indexOfCommunityUsers;       //Mapping holds index of particular user in communityTotalUsers array
    mapping(bytes32=>uint256) communityTotalPixels;     //Mapping holds purchase volume for each community
    mapping(address=>uint256) public userTotalPixels;   //Mapping to hold all the addresses and their total pixels
    mapping(address=>bytes32) public usertoCommunity;   //Mapping to hold all the addresses and their communities
    mapping(bytes32=>address) pixelDimensionToUsers;    //Mapping for pixes dimension to users
    mapping(bytes32=>address) pixelColorToUsers;        //Mapping for pixes color to users
    bytes32[] public communitiesArray;                  //Array of all the communities
    address[] public userTotalPixelsTemp;               //Temporary Array which holds all the users who purchased pixels
    bytes32[] internal pixelDimensionToUsersTemp;       //Temporary Array which holds all the pixels dimension purchased
    
    
    //--- Public Events to log activities in GUI -----------//
    event CommunityCreated(bytes32 communityName, address indexed communityCreator, uint256 timestamp);
    event CommunityJoined(bytes32 communityName, address indexed member, uint256 timestamp);
    event CommunityLeft(bytes32 communityName, address indexed member, uint256 timestamp);
    event PixelPurchased(address indexed byer, bytes32[] pixelPositionArray, bytes32[] colorArray, uint256 timestamp);
    event PickWinnerData(bytes32 winnerCommunity, uint256 communityPoolVolume, uint256 communityTotalPixels, uint256 communityTotalUsers, uint256 timestamp );
         
         
    /**
     * @notice Whilte creating community user must pay 1000 TRX.
     * @notice The name of community must be unique. Obviously users can not use the same name of any existing community.
     * 
     * @param communityName The name of new community.
     */
     
     function createNewCommunicty(bytes32 communityName) payable public {
        
        require(msg.value == createCommunityFee, 'Payment Amount is not valid');
        require(!allCommunities[communityName], 'Community name is already taken. Please use unique name');
        
        allCommunities[communityName] = true;
        communitiesArray.push(communityName);
        
        emit CommunityCreated(communityName, msg.sender, now);
     }
     
     
     /**
      * @notice User joins a new community.
      * @notice It requires the community exist, and then it also requires the user does not present in any other communities.
      * 
      * @param communityName The name of the community user wish to join.
      * 
      * @return bool true if all good.
      */
     function joinCommunity(bytes32 communityName) public payable returns(bool) {
         
         require(msg.value == joinCommunityFee, 'Payment Amount is not valid');
         require(allCommunities[communityName], 'Community does not exist');
         require(usertoCommunity[msg.sender] == bytes32(0), 'Member belongs to other community. He must first leave that community before joining new one');
         
         usertoCommunity[msg.sender] = communityName;
         communityTotalUsers[communityName].push(msg.sender);
         indexOfCommunityUsers[msg.sender] = communityTotalUsers[communityName].length - 1;
         
         emit CommunityJoined(communityName, msg.sender, now);
         
         return true;
         
     }
     
     /**
      * @notice Function allows user to leave community.
      * @notice User must exist in any community.
      * 
      * @return bool Return true if all good.
      */
     function leaveCommunity() payable public returns(bool) {
         
         require(msg.value == leaveCommunityFee, 'Payment Amount is not valid');
         require(usertoCommunity[msg.sender] != bytes32(0), 'User is not present in any community');
         
         uint index = indexOfCommunityUsers[msg.sender];
         address [] memory addressArray = communityTotalUsers[usertoCommunity[msg.sender]];
         addressArray[index] = addressArray[addressArray.length-1];
         communityTotalUsers[usertoCommunity[msg.sender]].length--; // Implicitly recovers gas from last element storage
         
         emit CommunityLeft(usertoCommunity[msg.sender], msg.sender, now);
         
         usertoCommunity[msg.sender] = "";
         
         return true;
     }
     
     
     /**
      * @notice Function to buy pixel.
      * @notice It has unrestrictive loop. But since it cost lots of fund to run DoS attack, it is impossible to do any harm.
      * @notice And for any genuine users, it will be fine as Tron has high gas limits.
      * 
      * @param pixelPositionArray An array of bytes32 of all the pixel dimension.
      * 
      * @return bool It returns true if all good.
      */
     function buyPixels(bytes32[] memory pixelPositionArray, bytes32[] memory colorArray) payable public returns(bool){
         
         require(pixelPositionArray.length > 0, 'Buyer must purchase at least one position');
         require(pixelPositionArray.length == colorArray.length, 'Dimension and Color array are not the same');
         require(msg.value >= pixelPositionArray.length * pixelPrice, 'User has provided insufficient fund');
         require(usertoCommunity[msg.sender] != bytes32(0), 'User does not belong to any community.');
         require(allCommunities[usertoCommunity[msg.sender]], 'Community does not exist');
         
         for(uint i=0; i<pixelPositionArray.length; i++){
             pixelDimensionToUsers[pixelPositionArray[i]] = msg.sender;
             pixelColorToUsers[pixelPositionArray[i]] = msg.sender;
             
             pixelDimensionToUsersTemp.push(pixelPositionArray[i]);
         }
         
         userTotalPixels[msg.sender] += pixelPositionArray.length;
         userTotalPixelsTemp.push(msg.sender);
         communityTotalPixels[usertoCommunity[msg.sender]] += pixelPositionArray.length;
         communityPoolVolume += msg.value;
         
         emit PixelPurchased(msg.sender, pixelPositionArray, colorArray, now);
         
         return true;
     }
     
    
     
     function pickWinner() public onlyOwner returns(bool){
         require(communityPoolVolume >= poolMinimumRequirement, 'Pool minimum volume is not enough');
         bytes32 winnerCommunity = checkWinnerCommunity();
         require(winnerCommunity != bytes32(0), 'No winnerCommunity selected');
         
         //70% winning to individual members according to their contribution
         uint256 availablePoolAmount = communityPoolVolume * 700 / 1000; 
         for(uint i=0; i<communityTotalUsers[winnerCommunity].length; i++){
             address  user = communityTotalUsers[winnerCommunity][i];
             if(balanceOf[user] >= minimumTokenRequirement){
             uint256 winingAmountPercent = userTotalPixels[user] * 100 / availablePoolAmount;
             uint256 winningAmount = availablePoolAmount * winingAmountPercent / 100;
             //transfering winning amount to user
             user.transfer(winningAmount);
             }
         }
         
         //12% goes to cost and maintainance
         maintainanceAddress.transfer(communityPoolVolume * 120 / 1000);
         //8% goes to founders
         foundersAddress.transfer(communityPoolVolume * 80 / 1000);
         //7% goes to developers
         developersAddress.transfer(communityPoolVolume * 70 / 1000);
         //3% goest to charity
         charityAddress.transfer(communityPoolVolume * 30 / 1000);
        
         
         //Logging winner data in event 
         emit PickWinnerData(winnerCommunity, communityPoolVolume, communityTotalPixels[winnerCommunity], communityTotalUsers[winnerCommunity].length, now);
         
    
         //clearning everything to begin fresh for next round
         communityPoolVolume = 0;
         //clearing communityTotalPixels Mapping
         for(uint a=0; a<communitiesArray.length; a++){
             communityTotalPixels[communitiesArray[a]] = 0;
         }
         //clearing userTotalPixels Mapping
         for(uint b=0; b<userTotalPixelsTemp.length; b++){
             userTotalPixels[userTotalPixelsTemp[b]] = 0;
         }
         userTotalPixelsTemp = new address[](0);
         //clearning pixelDimensionToUsers Mapping
         for(uint c=0; c<pixelDimensionToUsersTemp.length; c++){
             pixelDimensionToUsers[pixelDimensionToUsersTemp[c]] = address(0);
             pixelColorToUsers[pixelDimensionToUsersTemp[c]] = address(0);
         }
         pixelDimensionToUsersTemp = new bytes32[](0);
         
         return true;
         
     }
     
     
     function checkWinnerCommunity() public view returns(bytes32){
        uint256 largest = 0;
        bytes32 winnerCommunity = bytes32(0);
        for(uint256 i = 0; i < communitiesArray.length; i++){
            uint256 totalPixels = communityTotalPixels[communitiesArray[i]];
            if(totalPixels > largest && totalPixels >= communityMinimumPixel) {
                largest = totalPixels; 
                winnerCommunity = communitiesArray[i];
            } 
        }
        if(largest>0){
        return winnerCommunity;
        }else{
            return bytes32(0);
        }
     }
     
     
     
    //**********************************************//
    //----- Functions to Visualise information -----//
    //**********************************************//
    
     /**
      * @notice check if community exist.
      * @param communityName the name of community to look for.
      * @return bool Returns true or false.
      */
     function viewCommunityExist(bytes32 communityName) public view returns(bool){
         return allCommunities[communityName];
     }
     
     
     /**
      * @notice It returns total number of communities.
      * @notice It is used to display the total community dropdown in GUI.
      * @notice This number is the total loop iteration has to be done to look into communitiesArray.
      * @return uint256 Total number of communities.
      */
     function viewTotalCommunities() public view returns(bytes32[] memory){
         return communitiesArray;
     }
     
     
     /**
      * @notice View total number of users exist in any community.
      * @param communityName the name of community to look for.
      * @return bool Returns no of user exist in given community.
      */
     function viewTotalUsersInCommunity(bytes32 communityName) public view returns(uint256){
         return communityTotalUsers[communityName].length;
     }
     
     
     /**
      * @notice View how many pixels purchased in any community.
      * @param communityName the name of community to look for.
      * @return bool Returns no of pixels purchased in given community.
      */
     function viewTotalPixelsInCommunity(bytes32 communityName) public view returns(uint256){
         return communityTotalPixels[communityName];
     }
     
     
     /**
      * @notice View the buyer who purchased a particular pixel dimension.
      * @param pixelDimension the name of pixel Dimension bytes32 to look for.
      * @return address Returns address of buyer who purchased particular pixel.
      */
     function viewPixelOwner(bytes32 pixelDimension) public view returns(address){
         return pixelDimensionToUsers[pixelDimension];
     }
     

   
    //*************************************************//
    //-------- Code for the Helper functions ----------//
    //*************************************************//

    /**
     * @notice Update pixelPrice.
     * @param pixelPrice_ Amount of fee to purchase one pixel.
     * @return bool true for success transaction.
     */
     function updatePixelPrice (uint256 pixelPrice_) public onlyOwner returns(bool){
         require(pixelPrice_ > 0, 'Invalid amount');
         pixelPrice = pixelPrice_ * (10**decimals);
         return true;
     }
     
    /**
     * @notice Update createCommunityFee.
     * @param createCommunityFee_ Amount of fee to create community.
     * @return bool true for success transaction.
     */
     function updateCreateCommunityFee (uint256 createCommunityFee_) public onlyOwner returns(bool){
         require(createCommunityFee_ > 0, 'Invalid amount');
         createCommunityFee = createCommunityFee_ * (10**decimals);
         return true;
     }
     
     /**
     * @notice Update joinCommunityFee.
     * @param joinCommunityFee_ Amount of fee to join community.
     * @return bool true for success transaction.
     */
     function updateJoinCommunityFee (uint256 joinCommunityFee_) public onlyOwner returns(bool){
         require(joinCommunityFee_ > 0, 'Invalid amount');
         joinCommunityFee = joinCommunityFee_ * (10**decimals);
         return true;
     }
     
     /**
     * @notice Update leaveCommunityFee.
     * @param leaveCommunityFee_ Amount of fee to leave community.
     * @return bool true for success transaction.
     */
     function updateLeaveCommunityFee (uint256 leaveCommunityFee_) public onlyOwner returns(bool){
         require(leaveCommunityFee_ > 0, 'Invalid amount');
         leaveCommunityFee = leaveCommunityFee_ * (10**decimals);
         return true;
     }
     
     /**
     * @notice Update poolMinimumRequirement.
     * @param poolMinimumRequirement_ Minimum fund accumulated in pool to execute winner selection.
     * @return bool true for success transaction.
     */
     function updatePoolMinimumRequirement (uint256 poolMinimumRequirement_) public onlyOwner returns(bool){
         require(poolMinimumRequirement_ > 0, 'Invalid amount');
         poolMinimumRequirement = poolMinimumRequirement_ * (10**decimals);
         return true;
     }
     
     /**
     * @notice Update minimumTokenRequirement.
     * @param minimumTokenRequirement_ Minimum tokens user must have to be eligible to receive winning.
     * @return bool true for success transaction.
     */
     function updateMinimumTokenRequirement (uint256 minimumTokenRequirement_) public onlyOwner returns(bool){
         require(minimumTokenRequirement_ > 0, 'Invalid amount');
         minimumTokenRequirement = minimumTokenRequirement_ * (10**decimals);
         return true;
     }
     
     /**
     * @notice Update communityMinimumPixel.
     * @param communityMinimumPixel_ Minimum pixels must be purchased in comminity to be eligible to receive winning.
     * @return bool true for success transaction.
     */
     function updateCommunityMinimumPixel (uint256 communityMinimumPixel_) public onlyOwner returns(bool){
         require(communityMinimumPixel_ > 0, 'Invalid amount');
         communityMinimumPixel = communityMinimumPixel_ ;
         return true;
     }
     
    
    /**
     * @notice Update Founders Address. It must be called by owner only.
     * @param _newFounderAddress New address of founder.
     * @return bool true for success transaction.
     */
     function updateFoundersAddress(address  _newFounderAddress) public onlyOwner returns(bool){
         require(_newFounderAddress != address(0), 'Invalid address');
         foundersAddress = _newFounderAddress;
         return true;
     }
     
     /**
     * @notice Update Developer Address. It must be called by owner only.
     * @param developersAddress_ New address of Developer.
     * @return bool true for success transaction.
     */
     function updateDevelopersAddress(address  developersAddress_) public onlyOwner returns(bool){
         require(developersAddress_ != address(0), 'Invalid address');
         developersAddress = developersAddress_;
         return true;
     }
     
     /**
     * @notice Update Maintainance Address. It must be called by owner only.
     * @param maintainanceAddress_ New address for maintainance.
     * @return bool true for success transaction.
     */
     function updateMaintainanceAddress(address  maintainanceAddress_) public onlyOwner returns(bool){
         require(maintainanceAddress_ != address(0), 'Invalid address');
         maintainanceAddress = maintainanceAddress_;
         return true;
     }
     
     /**
     * @notice Update Charity Address. It must be called by owner only.
     * @param charityAddress_ New address for charity.
     * @return bool true for success transaction.
     */
     function updateCharityAddress(address  charityAddress_) public onlyOwner returns(bool){
         require(charityAddress_ != address(0), 'Invalid address');
         charityAddress = charityAddress_;
         return true;
     }
     
    /**
     * @notice Just in case, owner wants to transfer Tron from contract to owner address
     */
    function manualWithdrawTron()onlyOwner public{
        address(owner).transfer(address(this).balance);
    }
    
    /**
     * @notice selfdestruct function. just in case owner decided to destruct this contract.
     */
    function destructContract()onlyOwner public{
        selfdestruct(owner);
    }
    
    /**
     * @notice Change safeguard status on or off
     * @notice When safeguard is true, then all the non-owner functions will stop working.
     * @notice When safeguard is false, then all the functions will resume working back again!
     */
    function changeSafeguardStatus() onlyOwner public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;    
        }
    }
    



}
