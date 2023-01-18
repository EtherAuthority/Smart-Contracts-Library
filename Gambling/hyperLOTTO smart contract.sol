pragma solidity 0.5.1; /*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗     ██╗      ██████╗ ████████╗████████╗ ██████╗ 
██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██║     ██╔═══██╗╚══██╔══╝╚══██╔══╝██╔═══██╗
███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝    ██║     ██║   ██║   ██║      ██║   ██║   ██║
██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗    ██║     ██║   ██║   ██║      ██║   ██║   ██║
██║  ██║   ██║   ██║     ███████╗██║  ██║    ███████╗╚██████╔╝   ██║      ██║   ╚██████╔╝
╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝    ╚═╝      ╚═╝    ╚═════╝ 
                                                                                         


// ----------------------------------------------------------------------------
// 'HyperLotto' contract with following functionalities:
//      => Higher control by owner
//      => SafeMath implementation 
//      => Self destruct funcionality
//
// Contract Name    : HyperLotto
// Decimals         : 18
//
// Copyright (c) 2018 HyperETH Inc. ( https://hypereth.net ) 
// Contract designed by: EtherAuthority ( https://EtherAuthority.io ) 
// ----------------------------------------------------------------------------
*/ 



//*****************************************************************//
//---------------------- SafeMath Library -------------------------//
//*****************************************************************//
    
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

  function subsafe(uint256 a, uint256 b) internal pure returns (uint256) {
    if(b <= a){
        return a - b;
    }else{
        return 0;
    }
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
        address payable public owner;
    	using SafeMath for uint256;
    	
         constructor () public {
            owner = msg.sender;
        }
    
        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }
    
        function transferOwnership(address payable newOwner) onlyOwner public {
            owner = newOwner;
        }
    }
    
//*******************************************************************//
//------------------ Main Contract for HyperLOTTO -------------------//
//*******************************************************************//

contract HyperLOTTO is owned {

    /* Public variables of the smart contract */    
    using SafeMath for uint256;
    address[] public players;
    uint256 public maxEntryAmount = 50;         //50 is the maximum entries user can have in one go. For more, he can do another transaction
    address public tokenContract = 0x59Ac7681e910696452b8AFf31B0c70Be6F513e81; //Token to be used in this lottery
    address public lastContestent;              //Person who entered in the lotto last time
    uint256 public nextDrawTime = 1544484360;   //Time when next draw will start, this can be changed by owner
    uint256 public drawInterval = 86400;        //This is seconds of draw interval, this can be changed by owner
    uint256 public totalJackPotAmount;
    
    /* Public event that log all the winnings */
    event WinnerData(uint256 totalJackPot, address indexed mainWinner, uint256 mainWinnerAmount, address indexed lastContestent, uint256 lastContestentAmount );
    
    /**
     * @dev function called only by token contract, is used to enter into the contest
     * @dev it will send token amount and player address
     * @dev it will run for loop and add all those addresses in the array. The max is 50 now, this max amount can be changed by owner
     * @dev it will also increase totalJackPotAmount and also update the lastContestent
     * 
     * @param tokenAmount amount of tokens user sent. It will have decimals added accordingly
     * @param playerAddress the address of player
     * 
     * @return bool transaction succeed or failed
     */
    function enter(uint256 tokenAmount, address playerAddress) public returns(bool) {
        require(msg.sender == tokenContract, 'This function can be called only by specified token contract');
        uint256 tokenAmountFinal = tokenAmount.div(1e18);   //we assume token decimal points are 18
        require(tokenAmountFinal <= maxEntryAmount, 'Token amount exceed maximum limit'); 
        for(uint256 i=0; i<tokenAmountFinal; i++ ){
            players.push(playerAddress);
        }
        lastContestent = playerAddress;
        totalJackPotAmount += tokenAmount;
        return true;
    }
    
    /**
     * @dev this function is to pick random user from the array of addreses
     * @dev the logic is that it will take block difficulty, current timestamp and array of all the players and then hash it
     * @dev this logic give most amount of accuracy, as to create fake randomness is virtually impossible
     * 
     * @return uint a random number that can be used to pick random member from array of contest addresses
     */
    function random() internal view returns (uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
    }

    /**
     * @dev following is the fund distribution while executing draw
     * => 80% to winner
     * => 5% next round
     * => 5% to last person to buy ticket during round
     * => 10% to owner (reserve)
     * @dev it will be open only when draw time has reached which is every 24 hours, 
     */
    function pickWinner() public onlyOwner {
        require(now > nextDrawTime, 'The draw time has not come yet');
        address winner = players[random() % players.length];

        (bool statusWinner,) =    tokenContract.call(abi.encodeWithSignature("transfer(address, uint256)", winner, totalJackPotAmount*800/1000 ));
        (bool statusLastPerson,) =    tokenContract.call(abi.encodeWithSignature("transfer(address, uint256)", lastContestent, totalJackPotAmount*50/1000 ));
        
        require(statusWinner && statusLastPerson);
        
        emit WinnerData(totalJackPotAmount, winner, totalJackPotAmount*800/1000, lastContestent, totalJackPotAmount*50/1000 );
    
        players = new address[](0);
        totalJackPotAmount = totalJackPotAmount*50/1000;
        nextDrawTime = nextDrawTime + drawInterval;
        
    }


    function getPlayers() public view returns(address[] memory) {
        // Return list of players
        return players;
    }
    
    function updateTokenContract(address _newContract) public onlyOwner{
        require(_newContract != address(0x0), 'Input address is invalid');
        tokenContract = _newContract;
    }
    
    function updateMaxEntryAmount(uint256 _newTokenAmount) public onlyOwner{
        require(_newTokenAmount > 0, 'Input amount is invalid');
        maxEntryAmount = _newTokenAmount;
    }
    
    //Just in case owner wants to transfer Any Ether from this contract
    function manualWithdrawEther() onlyOwner public{
        address(owner).transfer(address(this).balance);
    }
    
    //Just in rare case, owner wants to transfer Tokens from contract to owner address
    //Token amount in Wei or according to the decimal of token contract
    function manualWithdrawTokens(uint tokenAmount) onlyOwner public{
        //no need to validate the input amount as transfer function automatically throws for invalid amounts
        (bool status,) =    tokenContract.call(abi.encodeWithSignature("transfer(address, uint256)", owner, tokenAmount ));
        require(status, 'Token transfer failed');
    }
    
    function updateNextDrawTime(uint256 _newNextDrawTime) public onlyOwner{
        require(_newNextDrawTime > 0, 'Input amount is invalid');
        nextDrawTime = _newNextDrawTime;
    }
    
    
    //selfdestruct function. just in case owner decided to destruct this contract.
    function destructContract()onlyOwner public{
        selfdestruct(owner);
    }
    
  
}


contract token{
    
    mapping(address => bool) public whitelistedContracts;
    
    function transfer(uint256 tokenAmount, address _to) public  {
        
        if(whitelistedContracts[_to] == true){
        
            (bool status,) =    _to.call(abi.encodeWithSignature("enter(uint256,address)", tokenAmount, msg.sender));
            require(status, 'External contract code did not work');
            
        }
        
        
    }
    
    function addWhitelistedContracts(address _newContract) public{
        whitelistedContracts[_newContract] = true;
    }
    
    function removeWhitelistedContracts(address _newContract) public{
        whitelistedContracts[_newContract] = false;
    }
    
    
}
















