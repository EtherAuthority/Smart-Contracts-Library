// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Presale {
    address public owner;
    IERC20 public token;
    uint256 public price;    
    mapping(address => uint256) public purchaseAmount;
    mapping(address => uint256) public claimedAmount;
    mapping(address => bool) public claimed;
   // uint256 public constant vestingDuration = 4 * 30 days; // 4 months
    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalTokens;
    uint256 public vestingDuration = 4 * 4 minutes; // 4 months
     mapping(address => uint256) public vestedAmount;
    uint256 public  tgePercentage = 20; // TGE percentage
    

    constructor(address _token, uint256 _price) {
        owner = msg.sender;
        token = IERC20(_token);
        price = _price; 
        startTime = block.timestamp;
        endTime = startTime + vestingDuration;      
    }

    function buyTokens(uint256 _amount) external {       
        uint256 cost = _amount * price;
        require(token.transferFrom(msg.sender, address(this), cost), "Token transfer failed");
        purchaseAmount[msg.sender] += _amount;
    }

    function adjustPrice(uint256 _newPrice) external {
        require(msg.sender == owner, "Only owner can adjust price");
        price = _newPrice;
    }

    function claimTokens() external {
        require(block.timestamp > endTime, "Presale not ended yet");
        require(!claimed[msg.sender], "Tokens already claimed");
        uint256 vestedAmounts = calculateVestedAmount(msg.sender);
        require(vestedAmounts > 0, "No tokens to claim");
        claimedAmount[msg.sender] = vestedAmounts;
        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, vestedAmounts), "Token transfer failed");
    }

    function calculateVestedAmount(address _user) internal returns (uint256) {
        uint256 totalVested = 0;
        uint256 userPurchaseAmount = purchaseAmount[_user];

        // Calculate TGE release       
        uint256 tgeAmount = (userPurchaseAmount * tgePercentage) / 100;
        totalVested += tgeAmount;
        

        // Calculate linear vesting
        require(block.timestamp >= startTime, "Vesting has not started yet");
        require(block.timestamp <= endTime, "Vesting has ended");
        uint256 elapsedTime = block.timestamp - startTime;
        uint256 vestingPeriods = elapsedTime / (vestingDuration / 4); // Divide the vesting period into 4 parts
        uint256 vested = ((userPurchaseAmount - tgeAmount) * vestingPeriods) / 4;
        require(vested > vestedAmount[msg.sender], "Nothing to claim");
        totalVested = vested - vestedAmount[msg.sender];
        vestedAmount[msg.sender] = vested;  
        
        return totalVested;
    }
}
