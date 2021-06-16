pragma solidity 0.5.11; 
/*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



 █████╗ ███████╗██╗   ██╗███╗   ███╗ █████╗      ██████╗ ██████╗ ██╗███╗   ██╗
██╔══██╗╚══███╔╝██║   ██║████╗ ████║██╔══██╗    ██╔════╝██╔═══██╗██║████╗  ██║
███████║  ███╔╝ ██║   ██║██╔████╔██║███████║    ██║     ██║   ██║██║██╔██╗ ██║
██╔══██║ ███╔╝  ██║   ██║██║╚██╔╝██║██╔══██║    ██║     ██║   ██║██║██║╚██╗██║
██║  ██║███████╗╚██████╔╝██║ ╚═╝ ██║██║  ██║    ╚██████╗╚██████╔╝██║██║ ╚████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
                                                                              


-------------------------------------------------------------------
 Copyright (c) 2019 onwards Azuma Coin Inc. ( https://Azumacoin.io )
 Contract designed with ❤ by EtherAuthority ( https://EtherAuthority.io )
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address payable public owner;
    address payable private newOwner;

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
 

interface tokenInterface
{
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
} 

 
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//

contract AzumaPivateSale is owned {

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables for private sale
    using SafeMath for uint256;
    address public azumaContractAddress;            // main token address to run ICO on
   	uint256 public exchangeRate = 100;              // exchange rate  1 ETH = 100 tokens
   	uint256 public icoETHReceived;                  // how many ETH Received through ICO
   	uint256 public totalTokenSold;                  // how many tokens sold
	uint256 public minimumContribution = 10**16;    // Minimum amount to invest - 0.01 ETH (in 18 decimal format)


    //nothing happens in constructor
    constructor() public{ }    


    /**
        * Fallback function. It accepts incoming ETH and issue tokens
    */
    function () payable external {
        buyToken();
    }

    event buyTokenEvent (address sender,uint amount, uint tokenPaid);
    function buyToken() payable public returns(uint)
    {
		
		//checking conditions
        require(msg.value >= minimumContribution, "less then minimum contribution"); 
        
        //calculating tokens to issue
        uint256 tokenTotal = msg.value * exchangeRate;

        //updating state variables
        icoETHReceived += msg.value;
        totalTokenSold += tokenTotal;
        
        //sending tokens. This crowdsale contract must hold enough tokens.
        tokenInterface(azumaContractAddress).transfer(msg.sender, tokenTotal);
        
        
        //send ether to owner
        forwardETHToOwner();
        
        //logging event
        emit buyTokenEvent(msg.sender,msg.value, tokenTotal);
        
        return tokenTotal;

    }


	//Automatocally forwards ether from smart contract to owner address
	function forwardETHToOwner() internal {
		owner.transfer(msg.value); 
	}
	
	
	// exchange rate => 1 ETH = how many tokens
    function setExchangeRate(uint256 _exchangeRatePercent) onlyOwner public returns (bool)
    {
        exchangeRate = _exchangeRatePercent;
        return true;
    }



    function setMinimumContribution(uint256 _minimumContribution) onlyOwner public returns (bool)
    {
        minimumContribution = _minimumContribution;
        return true;
    }
    
    
    function updateAzumaContract(address _newAzumaContract) onlyOwner public returns (bool)
    {
        azumaContractAddress = _newAzumaContract;
        return true;
    }
    
	
	function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner returns(string memory){
        // no need for overflow checking as that will be done in transfer function
        tokenInterface(azumaContractAddress).transfer(msg.sender, tokenAmount);
        return "Tokens withdrawn to owner wallet";
    }

    function manualWithdrawEther() public onlyOwner returns(string memory){
        address(owner).transfer(address(this).balance);
        return "Ether withdrawn to owner wallet";
    }
    


}
