# Implementation and Factory Smart Contracts

## Overview

This repository contains two Solidity smart contracts, `Implementation` and `Factory`, designed for the Binance Smart Chain (BSC) testnet. The `Implementation` contract facilitates swapping ETH for tokens using Uniswap and distributing fees to predefined wallets, while the `Factory` contract allows the creation and management of multiple `Implementation` contract instances.

## Table of Contents

- [Contracts](#contracts)
  - [Context](#context)
  - [Ownable](#ownable)
  - [Implementation](#implementation)
  - [Factory](#factory)
- [Example](#deployed-contract-address)


## Contracts

### Context

The `Context` contract provides information about the current execution context, including the sender of the transaction and its data. This contract is used for intermediate, library-like contracts.

### Ownable

The `Ownable` contract module provides a basic access control mechanism with an owner account that can be granted exclusive access to specific functions. The initial owner is set to the address provided by the deployer.

### Implementation

The `Implementation` contract enables swapping ETH for tokens via Uniswap and distributing fees. Key features include:

- Setting a fee wallet and a token to swap.
- Automatic ETH-to-token swaps upon receiving ETH.
- Distributing fees to the fee wallet and the main owner's fee wallet.
- Updating fee wallet and token to swap addresses.

#### Key Functions

- **constructor(address _feeWallet, address _tokenToSwap, address _owner, address _factory)**  
  Initializes the contract with the provided addresses for the fee wallet, token to swap, owner, and factory.

- **receive() external payable**  
  Fallback function to receive ETH and trigger the swap and fee distribution.

- **swapAndSend(uint256 amount) internal**  
  Swaps ETH for tokens and distributes fees.

- **updateFeeWallet(address newFeeWallet) external onlyOwner**  
  Updates the fee wallet address.

- **updateTokenToSwap(address tokenAddress) external onlyOwner**  
  Updates the token to swap address.

- **getMainOwnerFeeWallet() public view returns (address)**  
  Retrieves the main owner fee wallet address from the factory contract.

### Factory

The `Factory` contract manages the creation and tracking of `Implementation` contracts. It allows the main owner to update the main owner fee wallet.

#### Key Functions

- **constructor(address _mainOwnerFeeWallet)**  
  Initializes the factory with the main owner fee wallet address.

- **createContract(address feeWallet, address tokenToSwap) external**  
  Deploys a new `Implementation` contract and tracks it.

- **updateMainOwnerFeeWallet(address newFeeWallet) external onlyOwner**  
  Updates the main owner fee wallet address.


## Deployed contract address

[Implementation]https://testnet.bscscan.com/address/0xF306b3dA7dDf3Cb10508F9d3951A14d1c96dF901
[Factory]https://testnet.bscscan.com/address/0x688f70aF96cc26620152132909bb58ABe37c0Bc9
[TokenContract]https://testnet.bscscan.com/address/0xC7FD75eb9e520bD68f300ddEECAcb729541F68Da
