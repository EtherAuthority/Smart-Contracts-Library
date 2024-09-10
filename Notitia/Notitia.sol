// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
-------------------------------------------------------------------------------------------------------------------------------------
███╗   ██╗ ██████╗ ████████╗██╗████████╗██╗ █████╗ 
████╗  ██║██╔═══██╗╚══██╔══╝██║╚══██╔══╝██║██╔══██╗
██╔██╗ ██║██║   ██║   ██║   ██║   ██║   ██║███████║
██║╚██╗██║██║   ██║   ██║   ██║   ██║   ██║██╔══██║
██║ ╚████║╚██████╔╝   ██║   ██║   ██║   ██║██║  ██║
╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝

======================= Quick Stats ================================================================================================
    => Name        : Notitia
    => Symbol      : NOTI
    => Total supply: 1000 000 000
    => Decimals    : 18
-------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                   
**/

// Importing the ERC20 contract from OpenZeppelin, a library of secure and audited smart contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Defining the Notitia contract, which inherits from the ERC20 standard contract
contract Notitia is ERC20 {

    // Defining a constant variable for the initial supply of tokens
    // The total supply is set to 1 billion tokens with 18 decimal places
    uint256 private constant INITIAL_SUPPLY = 1_000_000_000 * 10**18;
    
    // Constructor function that is called only once when the contract is deployed
    // It initializes the ERC20 token with the name "Notitia" and symbol "NOTI"
    constructor() ERC20("Notitia", "NOTI") {
        // Minting the initial supply of tokens to the address that deploys the contract
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}

