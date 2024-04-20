# QURAC Token smart Contract Documentation

This README provides an overview of the functionalities and usage of the QURAC smart contract.

## Overview of QURAC

### Token Initialization

- The constructor initializes the token with the name "QURAC" and the symbol "QURAC".
- It mints an initial supply of 1 billion tokens to the deployer's address (msg.sender), multiplied by 10^decimals where decimals is the number  of decimal places (usually 18 in this case).

### Token Features:

- Users can transfer tokens to other addresses using the transfer function.
- Users can approve other addresses to spend tokens on their behalf using the approve function.
- Users can transfer tokens on behalf of another address if allowed using the transferFrom function.

## How to depoly contract on mainnet

## Prerequisites

- Install the MetaMask browser extension and set up your Ethereum account.
- Access Remix IDE in your web browser.

## Steps

1. **Compile Smart Contract:**
   - Open Remix and go to the "Solidity Compiler" tab.
   - Select the appropriate compiler version for your contract.
   - Write or import your smart contract code.
   - Click on the "Compile" button to compile the contract.

2. **Deploy Contract:**
   - Switch to the "Deploy & Run Transactions" tab in Remix.
   - Choose "Injected Provider MetaMask" as the environment to connect Remix with MetaMask.
   - Ensure MetaMask is unlocked and set to the mainnet.
   - Select the contract to deploy from the dropdown menu.
   - Enter any constructor parameters required by your contract (if applicable).
   - Click on the "Deploy" button to initiate the deployment.

3. **Confirm Transaction in MetaMask:**
   - MetaMask will open a popup window showing the deployment transaction details.
   - Review the gas fee and other details.
   - Click "Confirm" to submit the transaction.

4. **View Contract Address:**
   - After successful deployment, Remix will display the deployed contract's address.
   - Copy this contract address for future interactions with your contract.

## Troubleshooting

- If the deployment fails, check for error messages in Remix or MetaMask for more details.
- Ensure your MetaMask account has enough ETH to cover gas fees for the transaction.

## BSC Testnet Transaction
```
QURAC Token contract testnet address


