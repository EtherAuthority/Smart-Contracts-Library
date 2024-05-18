// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Presale {
    address public owner;
    IERC20 public token;
    uint256 public price; 
    uint256 public completedMonths;
    struct _purchaseDetails{
        uint256 purchaseid;
        uint256 purchaseAmt;
        uint256 purchaseStartTime;
        uint256 purchaseEndTime;
        bool tgclaimed;
        uint256 tgeAmount;
        uint256 vestedAmount;
     }  
    mapping(address => mapping(uint256 =>  _purchaseDetails)) public purchase;
    
   
   // uint256 public constant vestingDuration = 4 * 30 days; // 4 months
    mapping(address => uint256) public noOfpurchase;   
    uint256 public totalTokens;
    uint256 public vestingDuration = 4 * 1 minutes; // 4 months                                                                                 
   
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
            block.timestamp+vestingDuration,
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
        uint256 claimable;
        if(block.timestamp>=purchase[_user][_purchaseid].purchaseEndTime){ 
             claimable = uservestingamt - purchase[_user][_purchaseid].vestedAmount;
             purchase[_user][_purchaseid].vestedAmount = uservestingamt; 
        } else { 
        uint256 elapsedTime = block.timestamp -  purchase[_user][_purchaseid].purchaseStartTime;
        uint256 vestingPeriods = elapsedTime / (vestingDuration / 4); // Divide the vesting period into 4 parts
        uint256 vested = (uservestingamt * vestingPeriods) / 4; 
        require(vested > purchase[_user][_purchaseid].vestedAmount, "Nothing to claim");       
        claimable = vested - purchase[_user][_purchaseid].vestedAmount;        
        require(uservestingamt>=claimable,"Nothing to claim");
        purchase[_user][_purchaseid].vestedAmount = vested;  
        }
        
        return  claimable;
    }

    function getTotalCompletedMonths(address _user, uint256 _purchaseid) public  returns (uint256) {
        uint256 elapsedTimeMonth = block.timestamp - purchase[_user][_purchaseid].purchaseStartTime;
        completedMonths = ((elapsedTimeMonth / vestingDuration) * 4) *1000; // Assuming each month is divided into 4 parts
        uint256 Months = 0; 
        if(completedMonths < 2000 && completedMonths >= 1000)
            Months=1;
        else if(completedMonths < 3000 && completedMonths >= 2000)
            Months=2;
        else if(completedMonths<4000 && completedMonths >= 3000)
            Months=3;
        else if(completedMonths >= 4000)
            Months=4;
            
        return Months;
    }
}
