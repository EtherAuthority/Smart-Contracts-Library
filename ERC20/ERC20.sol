// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    constructor(string memory tokenName, string memory tokenSymbol, uint256 totalSupply) ERC20(tokenName, tokenSymbol){

        _mint(msg.sender, totalSupply * (10**decimals()));
    }

}
