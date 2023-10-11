// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SolarPowerToken is ERC20 {
    address public votingContractAddress;
    uint public maxSupply = 75000000 * (10 ** 18);

    constructor()
        ERC20("Solar Power Token", "SPT")
    {}

    function mint(address to, uint256 amount) public {
        require(msg.sender == votingContractAddress, "only voting contract can call");
        require(totalSupply() + amount <= maxSupply, "Cannot Mint more than maximum supply");
        _mint(to, amount);
    }
}
