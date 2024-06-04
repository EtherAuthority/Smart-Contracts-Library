// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract PresaleVesting {
    IERC20 public presaleToken;
    IERC20 public usdtToken;
    address public owner; // Address of the owner
    uint256 public purchaseStartDate;
   
    uint256 public vestingStartDate = 1726310400; // 14th September 2024
    uint256 public vestingEndDate = vestingStartDate + (4 * 30 days);  // 4 month 

    uint256 public activeStage = 1;
    mapping(uint256 => uint256) public purchaseStage;// Example prices in USDT per token

    struct PurchaseDetails {
        uint256 purchaseId;
        uint256 amount;
        uint256 purchaseTime;
        uint256 claimedAmount;
        uint256 purchaseStage;
    }

    mapping(address => uint256) public noOfPurchases;
    mapping(address => mapping(uint256 => PurchaseDetails)) public purchases;

    event Purchase(address indexed buyer, uint256 amount, uint256 cost, uint256 timestamp, uint256 stage);
    event TokensClaimed(address indexed claimer, uint256 amount);

    constructor(IERC20 _presaleToken, IERC20 _usdtToken, uint256 _price) {
        owner = msg.sender;
        presaleToken = _presaleToken;
        usdtToken = _usdtToken;
        purchaseStartDate = block.timestamp;
        purchaseStage[activeStage-1] = _price;
    }
    function setStagePrice(uint256 _price, uint256 _stage) external {
        require(msg.sender == owner, "Only owner can adjust price!");
        require(_stage >= 1 && _stage <= 5 , "Please select valid stage!");
        purchaseStage[_stage-1] = _price;
    }

    function changeStage() external {
        require(msg.sender == owner, "Only owner can adjust price");
        require(activeStage <= 5, "You can change stage till the 5th stage");
        require(purchaseStage[activeStage++] > 0,"Please set price before change stage!");
    }

    function buyTokens(uint256 _amount) external {
        require(block.timestamp >= purchaseStartDate, "Presale purchase not active yet!");
        require(_amount > 0,"Please set valid token amount!");
        uint256 cost = _amount * purchaseStage[activeStage - 1];        
        require(usdtToken.transferFrom(msg.sender, address(this), cost), "Token transfer failed");

        noOfPurchases[msg.sender] += 1;
        purchases[msg.sender][noOfPurchases[msg.sender]] = PurchaseDetails(
            noOfPurchases[msg.sender],
            _amount,
            block.timestamp,
            0,
            activeStage
        );

        emit Purchase(msg.sender, _amount, cost, block.timestamp, activeStage);
    }

  
    function claimTokens() external {
        require(block.timestamp >= vestingStartDate, "Vesting period has not started yet");

        uint256 claimableAmount;
        for (uint256 i = 1; i <= noOfPurchases[msg.sender]; i++) {
            PurchaseDetails storage purchase = purchases[msg.sender][i];
            uint256 vestedAmount = calculateVestedAmount(purchase.amount);
            uint256 unclaimedAmount = vestedAmount - purchase.claimedAmount;
            if (unclaimedAmount > 0) {
                claimableAmount += unclaimedAmount;
                purchase.claimedAmount = vestedAmount;
            }
        }

        require(claimableAmount > 0, "No tokens available for claiming");
        presaleToken.transfer(msg.sender, claimableAmount);
        emit TokensClaimed(msg.sender, claimableAmount);
    }

    function calculateVestedAmount(uint256 totalAmount) public view returns (uint256) {
        if (block.timestamp < vestingStartDate) {
            return 0;
        } else if (block.timestamp >= vestingEndDate) {
            return totalAmount;
        } else {
            uint256 elapsedTime = block.timestamp - vestingStartDate;
            uint256 vestingDuration = vestingEndDate - vestingStartDate;
            return (totalAmount * elapsedTime) / vestingDuration;
        }
    }
}
