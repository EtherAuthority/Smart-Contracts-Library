# Last Stablecoin (LSC) Smart Contract

## Overview
The **Last Stablecoin (LSC)** is an ERC-20 token on the Ethereum blockchain designed with specific functionalities to ensure security, efficiency, and stability.

## Features
- **Fixed Supply:** 1 billion LSC tokens minted at deployment.
- **Ownable Contract:** Admin control for contract ownership.
- **Reentrancy Protection:** Prevents reentrancy attacks.
- **Anti-Whale Mechanism:** Limits transactions to a maximum of 1% of the total supply.
- **Gas Optimization:** Efficient smart contract structure.
- **Event Logging:** Comprehensive event emissions for transparency.
- **Tax Wallet:** 3% buy/sell tax directed to a designated wallet.
- **No Minting/Burning:** The total supply is fixed; no further minting or burning functions.
- **Audited Libraries:** Utilizes OpenZeppelin for security and efficiency.

## Contract Specifications
- **Network:** Ethereum
- **Token Name:** Last Stablecoin (LSC)
- **Symbol:** LSC
- **Decimals:** 18
- **Total Supply:** 1 billion
- **Solidity Version:** 0.8.x or higher

## Installation
Ensure you have **Node.js** and **Hardhat** installed. Then, follow these steps:

```sh
npm install
```

## Deployment
To deploy the contract, update the Hardhat configuration and run:

```sh
npx hardhat run scripts/deploy.js --network mainnet
```

## Usage
To interact with the contract, use Web3.js, Ethers.js, or directly call contract functions via a blockchain explorer.

### Transfer Tokens
```solidity
transfer(address recipient, uint256 amount)
```

### Approve Spending
```solidity
approve(address spender, uint256 amount)
```

### Check Balance
```solidity
balanceOf(address account)
```

## Security Considerations
- Uses OpenZeppelin libraries to prevent common vulnerabilities.
- Includes a reentrancy guard for secure function execution.
- Implements anti-whale limits to reduce market manipulation.

## License
This project is licensed under the MIT License.



