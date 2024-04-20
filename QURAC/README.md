# QURAC Token smart Contract Documentation

This README provides an overview of the functionalities and usage of the QURAC smart contract.

## Overview of QURAC

### Token Initialization

- The constructor initializes the token with the name "QURAC" and the symbol "QURAC".
- It mints totalSupply of 1 billion tokens to the deployer's address (msg.sender), multiplied by 10^decimals where decimals is the number  of decimal places (usually 18 in this case).

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
https://testnet.bscscan.com/address/0xb66D9BD5E4B1893C29A8A6BC946Af76083194871#code

Transfer token one address to other address
https://testnet.bscscan.com/tx/0xd7e60e6dfdc1fd5e50023df8b8a4c2fa996c97f9e39036ff01a05c6b7265d395

Approve to spender address
https://testnet.bscscan.com/tx/0x148063e55929a846c967599d21be5804fb4ee73f334dfb9a5341350f641f7284

Transferfrom
https://testnet.bscscan.com/tx/0xc9433c2a8f733d685137a688f9b4d816cef1277a09a7fe2ae05912dc26162240

Notes

- Ensure you are connected to the BSC Testnet network on your MetaMask to view these transactions and contracts.
- Check transaction details for gas fees and confirmations.
```

