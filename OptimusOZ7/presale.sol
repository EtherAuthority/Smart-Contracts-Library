// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Presale {
    address public owner;
    IERC20 public token;
    uint256 public price;    
    mapping(address => uint256) public purchaseAmount;
    mapping(address => uint256) public claimedAmount;
    mapping(address => bool) public tgclaimed;
    mapping(address => uint256) public tgeAmount;
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
        // Calculate TGE release       
        tgeAmount[msg.sender] = (purchaseAmount[msg.sender] * tgePercentage) / 100;
        tgclaimed[msg.sender] = true;
        require(token.transfer(msg.sender, tgeAmount[msg.sender]), "Token transfer failed");
        
    }

    function adjustPrice(uint256 _newPrice) external {
        require(msg.sender == owner, "Only owner can adjust price");
        price = _newPrice;
    }

    function claimTokens() external {
        uint256 vestedAmounts = calculateVestedAmount(msg.sender);
        require(vestedAmounts > 0, "No tokens to claim");
        claimedAmount[msg.sender] += vestedAmounts;        
        require(token.transfer(msg.sender, vestedAmounts), "Token transfer failed");
    }

    function calculateVestedAmount(address _user) internal returns (uint256) {        
        uint256 uservestingamt=purchaseAmount[_user] - tgeAmount[msg.sender];
        // Calculate linear vesting
        require(uservestingamt>=vestedAmount[msg.sender],"Nothing to claim");      
        uint256 elapsedTime = block.timestamp - startTime;
        uint256 vestingPeriods = elapsedTime / (vestingDuration / 4); // Divide the vesting period into 4 parts
        uint256 vested = (uservestingamt * vestingPeriods) / 4;
        require(vested > vestedAmount[msg.sender], "Nothing to claim");
        uint256 claimable = vested - vestedAmount[msg.sender];
        require(uservestingamt>=claimable,"Nothing to claim");
        vestedAmount[msg.sender] = vested;  
        
        return  claimable;
    }

    function completedVestingMonths(address _user) external view returns (uint256) {
        uint256 elapsedMonths = (block.timestamp - (block.timestamp - vestingDuration)) / (4 minutes);
        uint256 completedMonths = (elapsedMonths * (purchaseAmount[_user]-tgeAmount[msg.sender])) / vestingDuration;
        return completedMonths;
    }
}
