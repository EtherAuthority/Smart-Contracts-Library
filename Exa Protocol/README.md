# Exa Protocol and Token Vesting Contracts

## Exa Protocol ERC20 Token Contract

This is a Solidity smart contract for the Exa Protocol ERC20 token. Below is a breakdown of its functionalities:

1. **Inherits from ERC20**: The contract inherits from the ERC20 standard contract, providing basic token functionalities such as transfer and approval.

2. **Constructor**: The constructor initializes the token with the name "Exa Protocol", symbol "XAP", and mints 1 billion tokens to the contract deployer.

3. **Decimals Function**: The `decimals()` function is overridden to return 8, indicating the number of decimal places used to display token amounts.

4. **Burn Function**: The `burn(uint256 amount)` function allows users to burn a specific amount of tokens from their balance.

## Token Vesting Scheme Contract

This is a Solidity contract for a token vesting scheme, designed to manage the distribution of tokens over a specified vesting period. Below is a summary of its functionalities:

1. **ERC20 Token Interface**: Declares an interface for interacting with ERC20 tokens, including functions for transferring tokens and checking balances.

2. **Vesting Contract**: Defines mappings and state variables to store vesting schedule details for each wallet.

3. **Constructor**: Initializes the contract with immutable variables and state variables based on deployment inputs.

4. **Create Vesting Function**: Sets up a new vesting schedule for one or more wallets.

5. **Completed Vesting Month Function**: Returns the number of months of a user's vesting period that have already passed.

6. **Withdrawable Amount Function**: Calculates the amount of token a user can withdraw based on their vesting schedule.

7. **Withdraw Tokens Function**: Allows users to withdraw tokens according to their vesting schedule.

## Usage

To use these contracts, deploy them to the Ethereum blockchain using a tool like Remix or Truffle. Once deployed, interact with the contracts using Ethereum wallets or other smart contracts to mint tokens, manage vesting schedules, and withdraw tokens.

## Note

These contracts are provided as examples and may require modifications or additional features depending on specific use cases. Always review and test smart contracts thoroughly before deploying them to production environments.
