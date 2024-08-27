# Industrial Gold Coin (IGC) Smart Contract

## Overview

The Industrial Gold Coin (IGC) is a custom ERC20 token with additional features for minting, burning, dividend distribution, and transfer restrictions. The token is designed to have a controlled supply, with minting and burning capabilities restricted to specific roles. Additionally, the contract includes a dividend distribution mechanism that allows the distribution of SOLID tokens to IGC holders.

## Features

1. **Minting**: Only the contract owner can mint new IGC tokens.
2. **Burning**: Holders can burn their tokens, reducing the total supply.
3. **Dividend Distribution**: Distributes SOLID tokens to IGC holders based on their holdings. The owner can specify the number of holders and the amount to distribute.
4. **Transfer Restrictions**: Transfers to Decentralized Exchanges (DEX) are restricted to prevent trading. Only the owner can designate DEX addresses.
5. **Holder Management**: The contract tracks holders and manages their eligibility for dividend claims.
6. **Claim Missed Dividends**: Claim All Dividends that User never claimed and Eligible to Claim.

## Contract Details

- **Token Name**: IGC Token
- **Symbol**: IGC
- **Decimals**: 18

## Setup

### Prerequisites

- Solidity version: 0.8.24
- Node.js and npm installed
- Hardhat or Truffle for deployment and testing

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/EtherAuthority/Smart-Contracts-Library.git
   cd IGC
