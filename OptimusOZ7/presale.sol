// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Presale {
    address public owner;
    IERC20 public token;
    uint256 public price;
    uint256 public startTime;
    uint256 public endTime;
    mapping(address => uint256) public purchaseAmount;
    mapping(address => uint256) public claimedAmount;
    mapping(address => bool) public claimed;
    uint256 public constant vestingDuration = 4 * 30 days; // 4 months
    uint256 public constant tgePercentage = 20; // TGE percentage
    uint256 public constant tgeCliff = 0; // TGE cliff

    constructor(address _token, uint256 _price, uint256 _startTime, uint256 _endTime) {
        owner = msg.sender;
        token = IERC20(_token);
        price = _price;
        startTime = _startTime;
        endTime = _endTime;
    }

    function buyTokens(uint256 _amount) external {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Presale not active");
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
        uint256 vestedAmount = calculateVestedAmount(msg.sender);
        require(vestedAmount > 0, "No tokens to claim");
        claimedAmount[msg.sender] = vestedAmount;
        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, vestedAmount), "Token transfer failed");
    }

    function calculateVestedAmount(address _user) internal view returns (uint256) {
        uint256 totalVested = 0;
        uint256 userPurchaseAmount = purchaseAmount[_user];

        // Calculate TGE release
        if (block.timestamp >= startTime + tgeCliff) {
            uint256 tgeAmount = (userPurchaseAmount * tgePercentage) / 100;
            totalVested += tgeAmount;
        }

        // Calculate linear vesting
        uint256 elapsedTime = block.timestamp - startTime;
        if (elapsedTime < vestingDuration) {
            uint256 remainingVestingPeriod = vestingDuration - elapsedTime;
            uint256 linearAmount = ((userPurchaseAmount * (100 - tgePercentage)) / 100) * (remainingVestingPeriod) / vestingDuration;
            totalVested += linearAmount;
        }

        return totalVested;
    }
}
