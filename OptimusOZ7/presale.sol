// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Presale {
    address public owner;
    IERC20 public token;
    uint256 public price; 
    struct _purchaseDetails{
        uint256 purchaseid;
        uint256 purchaseAmt;
        uint256 purchaseStartTime;
        bool tgclaimed;
        uint256 tgeAmount;
        uint256 vestedAmount;
     }  
    mapping(address => mapping(uint256 =>  _purchaseDetails)) public purchase;
    
   
   // uint256 public constant vestingDuration = 4 * 30 days; // 4 months
    mapping(address => uint256) public noOfpurchase;   
    uint256 public totalTokens;
    uint256 public vestingDuration = 4 * 4 minutes; // 4 months                                                                                 
   
    uint256 public  tgePercentage = 20; // TGE percentage
    

    constructor(address _token, uint256 _price) {
        owner = msg.sender;
        token = IERC20(_token);
        price = _price;        
       
    }

    function buyTokens(uint256 _amount) external {       
        uint256 cost = _amount * price;
        require(token.transferFrom(msg.sender, address(this), cost), "Token transfer failed");
        noOfpurchase[msg.sender]+=1;
        purchase[msg.sender][noOfpurchase[msg.sender]] = 
        _purchaseDetails(
            noOfpurchase[msg.sender],
            _amount,
            block.timestamp,
            true,
            (_amount * tgePercentage) / 100,
            0
        );
         
       
        require(token.transfer(msg.sender, purchase[msg.sender][noOfpurchase[msg.sender]].tgeAmount), "Token transfer failed");
        
    }

    function adjustPrice(uint256 _newPrice) external {
        require(msg.sender == owner, "Only owner can adjust price");
        price = _newPrice;
    }

    function claimTokens(uint256 _purchaseid) external {
        uint256 vestedAmounts = calculateVestedAmount(msg.sender,_purchaseid);
        require(vestedAmounts > 0, "No tokens to claim");              
        require(token.transfer(msg.sender, vestedAmounts), "Token transfer failed");
    }

    function calculateVestedAmount(address _user, uint256 _purchaseid) internal returns (uint256) {        
        uint256 uservestingamt=purchase[_user][_purchaseid].purchaseAmt - purchase[_user][_purchaseid].tgeAmount;
        // Calculate linear vesting
        require(uservestingamt>=purchase[_user][_purchaseid].vestedAmount,"Nothing to claim");      
        uint256 elapsedTime = block.timestamp -  purchase[_user][_purchaseid].purchaseStartTime;
        uint256 vestingPeriods = elapsedTime / (vestingDuration / 4); // Divide the vesting period into 4 parts
        uint256 vested = (uservestingamt * vestingPeriods) / 4;
        require(vested > purchase[_user][_purchaseid].vestedAmount, "Nothing to claim");
        uint256 claimable = vested - purchase[_user][_purchaseid].vestedAmount;
        require(uservestingamt>=claimable,"Nothing to claim");
        purchase[_user][_purchaseid].vestedAmount = vested;  
        
        return  claimable;
    }

    function getTotalCompletedMonths(address _user, uint256 _purchaseid) public view returns (uint256) {
        uint256 elapsedTime = block.timestamp - purchase[_user][_purchaseid].purchaseStartTime;
        uint256 completedMonths = (elapsedTime / vestingDuration) * 4; // Assuming each month is divided into 4 parts
        return completedMonths;
    }
}
