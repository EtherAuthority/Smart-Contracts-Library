# SafeChainToken (SFC) - Solidity Smart Contract

SafeChainToken (SFC) is a decentralized token built on the Ethereum blockchain, designed with features for reflection rewards, liquidity provision, and adjustable transaction fees. This document outlines the structure and functionality of the SafeChainToken smart contract.

## Token Information

- **Name**: SafeChain
- **Symbol**: SFC
- **Decimals**: 18
- **Total Supply**: 21,000,000 SFC
- **Liquidity Fee**: 0.25%
- **Reflection Fee**: 0.25%
- **Tax Fee**: 0.50% (Default - Adjustable)

## Features

### 1. Reflection Mechanism
SafeChainToken includes a reflection mechanism that allows token holders to passively earn rewards based on the amount of tokens they hold. The rewards are automatically distributed and calculated based on reflections from each transaction.

- **Reflection/Reward System**: Token holders can earn rewards based on their share of the token supply. Excluded accounts do not receive rewards.
- **Current Reflection Percentage**: **0.25%** of each transaction is reflected to all holders.

### 2. Liquidity Provision
SafeChainToken includes a liquidity fee, which adds liquidity to the Uniswap pool on each transaction, ensuring that there is enough liquidity for the token on decentralized exchanges.

- **Liquidity Fee**: **0.25%** of each transaction is converted into liquidity, ensuring stable and sustainable trading on Uniswap.
- **Swap and Liquify**: Tokens are swapped for ETH and paired with liquidity on Uniswap.
  
### 3. Adjustable Transaction Fees
The contract owner has the ability to adjust the tax, liquidity, and reflection fees to maintain token stability and community trust.

- **Tax Fee**: Default set to **0.50%** (adjustable by the owner).
- **Liquidity Fee**: Default set to **0.25%** (adjustable by the owner).
- **Reflection Fee**: Default set to **0.25%** (adjustable by the owner).
  
### 4. Exclusion from Fees and Rewards
Certain addresses, such as the owner's address and the contract itself, are excluded from both transaction fees and the reward distribution.

## Contract Functions

### Public Functions
- `name()`: Returns the token name (`SafeChain`).
- `symbol()`: Returns the token symbol (`SFC`).
- `decimals()`: Returns the number of decimals (18).
- `totalSupply()`: Returns the total supply of tokens (21,000,000 SFC).
- `balanceOf(address account)`: Returns the balance of the specified account.
- `transfer(address recipient, uint256 amount)`: Transfers tokens from the sender to the recipient.
- `approve(address spender, uint256 amount)`: Approves an account to spend a specified amount on behalf of the sender.
- `transferFrom(address sender, address recipient, uint256 amount)`: Transfers tokens on behalf of the sender.
  
### Reflection and Fee Functions
- `excludeFromReward(address account)`: Excludes an account from receiving rewards.
- `includeInReward(address account)`: Includes an account back into the reward distribution.
- `excludeFromFee(address account)`: Excludes an account from transaction fees.
- `includeInFee(address account)`: Includes an account back into transaction fees.
- `setTaxFeePercent(uint256 taxFee)`: Sets the tax fee percentage (only callable by the owner).
- `setLiquidityFeePercent(uint256 liquidityFee)`: Sets the liquidity fee percentage (only callable by the owner).
- `setTaxThreshold(uint256 threshold)`: Sets the threshold for when the contract swaps tokens for liquidity.
  
### Private Functions
- `_reflectFee(uint256 rFee, uint256 tFee)`: Internal function to reflect the fees in the reward pool.
- `_getValues(uint256 tAmount)`: Calculates and returns transaction values.
- `_getRate()`: Returns the current rate for reflection calculation.
- `_takeLiquidity(uint256 tLiquidity)`: Internal function to handle liquidity taking in transactions.
  
### Events
- `SwapAndLiquifyEnabledUpdated(bool enabled)`: Triggered when the swap and liquify process is toggled.
- `MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap)`: Triggered when the minimum tokens before swap is updated.
- `SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity)`: Triggered when tokens are swapped and added to liquidity.

## Deployment Information

### Uniswap Integration
The contract integrates with Uniswap V2 for liquidity provision, creating a token pair with ETH during deployment. 

- **Uniswap Router Address**: `0xD99D1c33F9fC3444f8101754aBC46c52416550D1` (testnet example).
- **Uniswap Pair**: Automatically created upon deployment.

### Fee Management
By default, the owner and the contract itself are excluded from paying fees. The owner has the ability to exclude any address from paying fees and receiving rewards, as well as the ability to adjust fee percentages.

## Usage

1. **Deploy the contract**: Use your preferred method (e.g., Remix, Truffle, Hardhat) to deploy the SafeChainToken smart contract to the Ethereum network.
2. **Set Fees**: Adjust tax, liquidity, and reflection fees as required by the project.
3. **Distribute Tokens**: Transfer tokens to users and liquidity pools as needed.
4. **Enable Swap and Liquify**: Make sure the swap and liquify functionality is enabled to maintain liquidity on Uniswap.

## Security Considerations

- **Owner Privileges**: The owner has control over excluding addresses from fees and rewards, adjusting fee percentages, and enabling/disabling liquidity mechanisms.
- **Safeguards**: Ensure the owner account is secured to avoid unauthorized control over the contract's sensitive features.

## License

This project is licensed under the MIT License.
