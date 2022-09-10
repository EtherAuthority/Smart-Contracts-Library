// SPDX-License-Identifier: MIT
pragma solidity 0.8.17; 




//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract ownable {
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
 

interface tokenInterface
{
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
} 

 
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//

contract TokenSale is ownable {

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables for private sale
    address public tokenContractAddress;            // main token address to run ICO on
   	uint256 public exchangeRate = 100;              // exchange rate  1 ETH = 100 tokens
   	uint256 public icoETHReceived;                  // how many ETH Received through ICO
   	uint256 public totalTokenSold;                  // how many tokens sold
	  uint256 public minimumContribution = 10**16;    // Minimum amount to invest - 0.01 ETH (in 18 decimal format)



    /**
        * Fallback function. It accepts incoming ETH and issue tokens
    */
    receive () payable external {
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
        tokenInterface(tokenContractAddress).transfer(msg.sender, tokenTotal);
        
        
        //send fund to owner
        owner.transfer(msg.value);
        
        //logging event
        emit buyTokenEvent(msg.sender,msg.value, tokenTotal);
        
        return tokenTotal;

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
    
    
    function setTokenContract(address _tokenContract) onlyOwner public returns (bool)
    {
        tokenContractAddress = _tokenContract;
        return true;
    }
    
	
	function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner returns(string memory){
        // no need for overflow checking as that will be done in transfer function
        tokenInterface(tokenContractAddress).transfer(msg.sender, tokenAmount);
        return "Tokens withdrawn to owner wallet";
    }

    function manualWithdrawFund() public onlyOwner returns(string memory){
        owner.transfer(address(this).balance);
        return "Fund withdrawn to owner wallet";
    }
    


}
