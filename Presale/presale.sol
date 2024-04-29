
// SPDX-License-Identifier: MIT
pragma solidity  0.8.24;

import "./tokencontract.sol";


contract PresaleContract is  TestCoin {

    IERC20 public usdtContract;
    IERC20 public usdcContract;
    IERC20 public daiContract;
    IERC20 public baseETHContract;
    // TestCoin public token;
    uint256 public currentPrice=300;// $0.0003 * 10**6
    uint256 public lastPriceUpdateTime;
    uint256 public priceIncrement = 1; // $0.000001 * 10**6 
    address public paymentWallet;
    address public baseRouter;
    event PriceUpdated(uint256 newPrice);

    event TokensBoughtWithEth(address indexed buyer, uint256 ethAmount, uint256 ethPrice, uint256 tokenPrice, uint256 timestamp);

    event TokensBoughtWithUsdt(address indexed buyer, uint256 usdtAmount, uint256 tokenPrice, uint256 timestamp);

    constructor(
        // address _tokenAddress,
        address _usdtContract,
        address _usdcContract,
        address _daiContract,
        address _baseRouter,
        address _paymentWallet
        
    )TestCoin(msg.sender) {
        // token = TestCoin(_tokenAddress);
        usdtContract = IERC20(_usdtContract);
        usdcContract = IERC20(_usdcContract);
        daiContract = IERC20(_daiContract);
        paymentWallet=_paymentWallet;
        baseRouter= _baseRouter;
        lastPriceUpdateTime = block.timestamp; 
    }

    IUniswapV2Router02 private router = IUniswapV2Router02(baseRouter);


    function buyWithUsdt(uint256 usdtAmount) external  returns (bool) {

        uint256 ourAllowance = usdtContract.allowance(_msgSender(), address(this));
        require(usdtAmount <= ourAllowance, "Make sure to add enough allowance");
        (bool success, ) = address(usdtContract).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _msgSender(), paymentWallet, usdtAmount)
        );
        require(success, "Token payment failed");
        emit TokensBoughtWithUsdt(_msgSender(), usdtAmount, currentPrice, block.timestamp);
        return true;
    }
    function buyWithUsdc(uint256 usdcAmount) external  returns (bool) {
        
        uint256 ourAllowance = usdcContract.allowance(_msgSender(), address(this));
        require(usdcAmount <= ourAllowance, "Make sure to add enough allowance");
        (bool success, ) = address(usdcContract).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _msgSender(), paymentWallet, usdcAmount)
        );
        require(success, "Token payment failed");
        emit TokensBoughtWithUsdt(_msgSender(), usdcAmount, currentPrice, block.timestamp);
        return true;
    }
      function buyWithDai(uint256 daiAmount) external  returns (bool) {
        
        uint256 ourAllowance = daiContract.allowance(_msgSender(), address(this));
        require(daiAmount <= ourAllowance, "Make sure to add enough allowance");
        (bool success, ) = address(daiContract).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _msgSender(), paymentWallet, daiAmount)
        );
        require(success, "Token payment failed");
        emit TokensBoughtWithUsdt(_msgSender(), daiAmount, currentPrice, block.timestamp);
        return true;
    }

    function buyWithEth() external payable   returns (bool) {
        require(msg.value > 0, "No ETH sent");
        sendValue(payable(paymentWallet), msg.value);
        emit TokensBoughtWithEth(_msgSender(), msg.value, getLatestEthPrice(msg.value), currentPrice, block.timestamp);
        return true;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Low balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH Payment failed");
    }

    function changePriceIncrement(uint256 newIncrement) external onlyOwner {
        priceIncrement = newIncrement;
    }

    function updateTokenPrice() public {
        uint256 daysPassed = (block.timestamp - lastPriceUpdateTime) / 1 minutes;
        if (daysPassed >= 1) {
            uint256 newPrice = currentPrice + (daysPassed * priceIncrement);
            currentPrice = newPrice;
            lastPriceUpdateTime = block.timestamp;
            emit PriceUpdated(newPrice);
        }
    }

    function getLatestEthPrice(uint256 _amountIn) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(usdcContract);
        path[1] = address(daiContract);
        
        uint[] memory amounts = router.getAmountsOut(_amountIn, path);
         
        return amounts[1]; // Return the price at index 1
    }

}
