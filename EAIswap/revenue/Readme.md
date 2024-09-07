# RevenueContract

This is a smart contract designed to swap **EAI tokens** for **ETH** using Uniswap's V2 Router. It features functionality to pause and unpause the contract, change the monitored wallet, and withdraw ETH from the contract.

## Features
- **Swap EAI for ETH**: Allows the monitored wallet to swap a specific amount of EAI tokens for ETH via Uniswap.
- **Pause/Unpause**: The contract can be paused or unpaused by the owner.
- **Monitored Wallet**: The monitored wallet is the only account that can initiate the token swap.
- **Withdraw ETH**: The owner can withdraw any ETH held by the contract.

## Contract Deployment

### Constructor Parameters
- `_eaiTokenAddress`: The address of the EAI token contract.
- `_uniswapRouterAddress`: The address of the Uniswap V2 Router.
- `_monitoredWallet`: The address of the wallet allowed to initiate token swaps.

### Example Deployment
```solidity
RevenueContract revenueContract = new RevenueContract(
    "0xEaiTokenAddress",   // EAI Token Address
    "0xUniswapRouterAddress",  // Uniswap V2 Router Address
    "0xMonitoredWallet"   // Monitored Wallet Address
);

