/* SPDX-License-Identifier: UNLICENSED */
pragma solidity 0.8.17;
pragma abicoder v2;

import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";
import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/IQuoter.sol";

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract Uniswap3 {
    IUniswapRouter public constant uniswapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IQuoter public constant quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    address private constant coolToken = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;    /* change this to your token address */

    /**
    * return buy price of coolToken, 
    * i.e., how much eth you need to spend in order to buy a desired amount of coolToken(aegument: uint forHowMuchToken)
    */
    function getBuyPriceInETH(uint forHowMuchToken, address tokenIn, uint24 fee) external payable returns (uint256 amountIn) {
        address tokenOut = coolToken;
        uint160 sqrtPriceLimitX96 = 0;

        return quoter.quoteExactOutputSingle(
            tokenIn,
            tokenOut,
            fee,
            forHowMuchToken,
            sqrtPriceLimitX96
        );
    }




    // important to receive ETH
    receive() payable external {}
}
