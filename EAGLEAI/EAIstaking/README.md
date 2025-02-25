# EAI Staking and TdEAIToken Contracts

## Overview

This repository contains the Solidity contracts for a complete staking system:
- **EAIStaking**: A staking contract where users can stake Eagle AI Labs’ EAI tokens and earn rewards in EAI or USDC based on epoch-based reward distribution.
- **TdEAIToken**: An ERC20-based receipt token contract that represents a user’s staked balance. It includes custom minting and burning functionalities controlled via a role-based mechanism.

Both contracts are designed with robust security in mind by leveraging OpenZeppelin’s libraries for access control, pausable mechanisms, and reentrancy protection.

## Contracts

### EAIStaking Contract

The **EAIStaking** contract facilitates:
- **Staking**: Users can stake any amount of EAI tokens and receive tdEAI tokens as a receipt.
- **Unstaking**: Users can unstake their tokens by burning their tdEAI tokens. Only tokens staked for the entire epoch are eligible for rewards.
- **Reward Distribution**: The admin can deposit rewards (in EAI or USDC) into the contract for each epoch. Rewards are calculated proportionally based on each user's stake relative to the total staked amount in that epoch.
- **Claiming Rewards**: Users can claim their accumulated rewards. To manage gas costs and prevent abuse, claims are limited to rewards from a maximum of 12 epochs at a time.
- **Epoch Management**: Epochs are dynamically managed based on a fixed duration (e.g., 5 minutes for testing, 30 days in production). The owner sets the start date for epoch 1 and starts the epoch manually.

#### Key Functions
- `setEpoch1date(uint256 dateTimestamp)`: Set the start date for epoch 1 (only if no staking has occurred).
- `activateContract()`: Activate the contract for staking once the epoch start date is set.
- `startEpoch1()`: Start the first epoch once the contract is activated.
- `stake(uint256 amount)`: Stake EAI tokens; mints tdEAI tokens and updates the staking data.
- `unstake(uint256 amount)`: Unstake EAI tokens; burns tdEAI tokens and transfers back EAI tokens.
- `distributeRewards(uint256 amount, bool isUSDC)`: Distribute rewards for the current epoch.
- `claimRewards()`: Claim accumulated rewards (limited to 12 epochs at a time).
- Additional view functions such as `getCurrentEpochNumber()`, `getPendingRewards()`, and `getEpochRewards(uint256 epoch)`.

### TdEAIToken Contract

The **TdEAIToken** contract is an ERC20 token that serves as a receipt token in the staking system. It features:
- **Standard ERC20 Functionality**: Implements all standard functions including transfers, approvals, and balance checks.
- **Mint and Burn Role**: Only a designated account (assigned via the owner) can mint or burn tdEAI tokens. This role is used by the staking contract to issue and destroy receipt tokens corresponding to staking activities.
- **Access Control**: Inherits from the `Ownable` contract to restrict sensitive operations.

#### Key Functions
- `addRole(address _mintAndBurnRole)`: Assign the mint and burn role to a specific address.
- `mint(address to, uint256 amount)`: Mint new tdEAI tokens (only callable by the account with the mint and burn role).
- `burn(address from, uint256 amount)`: Burn tdEAI tokens (only callable by the account with the mint and burn role).

## Installation and Compilation

 **Clone the Repository:**
    ```bash
    git clone <https://github.com/EtherAuthority/Smart-Contracts-Library/tree/main/EAGLEAI>    
    ```

