# Presale Contract Documentation

This README provides an overview of the functionalities and usage of the Presale smart contract.

## Overview
The Presale contract facilitates token purchases using Ether and approved ERC20 tokens (USDT, USDC, DAI) on the Binance Smart Chain (BSC), Etherum , Base network.
It allows users to buy tokens at the current price, set by the contract owner. Only approved contracts can use ERC20 tokens for purchases.

## Features
- **Token Purchase**
   - Users can buy tokens using Ether (`buyWithEth`) or approved ERC20 tokens (`buyWithToken`).
   - Token purchases update the current token price (`updateTokenPrice`).
   - Token price can be changed by the contract owner (`changePrice`).

- **Admin Actions**
   - Contract owner can approve/revoke contracts for token purchases (`approveContract`).
   - Owner can change the payment wallet address (`changePaymentWallet`).

- **Token Withdrawal**
   - Owner can withdraw tokens from the contract (`withdrawToken`).
   - Owner can withdraw native tokens (ETH/BNB) from the contract (`withdrawNative`).

## Usage
1. **Buying Tokens**
   - To buy tokens with Ether, call `buyWithEth` and send Ether along with the transaction.
   - To buy tokens with approved ERC20 tokens, call `buyWithToken` with the token address and amount.

2. **Admin Actions**
   - Approve/revoke contracts for token purchases using `approveContract`.
   - Change the payment wallet address with `changePaymentWallet`.
   - Change the token price using `changePrice`.

3. **Token Withdrawal**
   - Withdraw tokens using `withdrawToken` by providing the token contract address and amount.
   - Withdraw native tokens (ETH/BNB) using `withdrawNative` by providing the amount.

## Security Considerations
- Ensure only approved contracts can access token purchases.
- Keep the payment wallet address secure and updated as needed.
- Review and test contract functions thoroughly before deployment.

## Contributing
Feel free to contribute to the contract's improvement and submit pull requests.
