# Wrapped Minu (WMINU) Token Smart Contract

## Overview
The Wrapped Minu (WMINU) token smart contract is an ERC20-compliant contract written in Solidity. It allows users to wrap their Minu tokens into WMINU tokens and unwrap them back to Minu tokens. The contract also implements a 1% burn on every token transfer.

## Features
1. **ERC20 Compliance**: The WMINU token follows the ERC20 standard, ensuring compatibility with existing infrastructure and wallets.
2. **Wrap and Unwrap**: Users can wrap their Minu tokens into WMINU tokens and unwrap them back to Minu tokens.
3. **Exclusion from Fee**: Certain addresses can be excluded from the burn fee.

## Functions
- `wrap(uint256 amount)`: Allows a user to wrap their Minu tokens into WMINU tokens.
- `unwrap(uint256 amount)`: Allows a user to unwrap their WMINU tokens back into Minu tokens.
- `transfer(address recipient, uint256 amount)`: Transfers WMINU tokens to the recipient and burns 1% of the transferred amount.
- `excludeFromFee(address account)`: Excludes an address from the burn fee.
- `includeInFee(address account)`: Includes an address in the burn fee.

## Getting Started
To interact with this contract, you will need to have a wallet that is capable of sending transactions on the Ethereum network (such as MetaMask). You will also need to have Minu tokens in your wallet.
