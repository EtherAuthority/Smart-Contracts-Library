
// SPDX-License-Identifier: MIT
pragma solidity  0.8.24;

import "./tokencontract.sol";


contract PresaleContract is  TestCoin {

    TestCoin public token;
    uint256 public startingPrice=300;// $0.0003 * 10**6
    uint256 public lastPriceUpdateTime;
    uint256 public priceIncrement = 1; // $0.000001 * 10**6 

  
    event PriceUpdated(uint256 newPrice);

    constructor(
        address _tokenAddress
    
    )TestCoin(msg.sender) {
      
        token = TestCoin(_tokenAddress);
        lastPriceUpdateTime = block.timestamp; 
    }

    function changePriceIncrement(uint256 newIncrement) external onlyOwner {
        priceIncrement = newIncrement;
    }

   
    function updateTokenPrice() public {
        uint256 daysPassed = (block.timestamp - lastPriceUpdateTime) / 1 days;
        if (daysPassed >= 1) {
            uint256 newPrice = startingPrice + (daysPassed * priceIncrement);
            startingPrice = newPrice;
            lastPriceUpdateTime = block.timestamp;
            emit PriceUpdated(newPrice);
        }
    }
}
