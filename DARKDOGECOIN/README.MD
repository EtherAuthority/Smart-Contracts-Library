# Token Smart Contract on Binance Smart Chain (Testnet)

This repository contains the implementation of a token smart contract deployed on the Binance Smart Chain (Testnet). The contract includes various functionalities like adding liquidity, buying and selling tokens, blacklisting addresses, and renouncing ownership. Below are the important links and descriptions of the contract's features and transactions.

## Smart Contract Address

The smart contract is deployed at the following address:
- [0x103D239B6aFd3a10EB419B9A164d628e3A1256a2](https://testnet.bscscan.com/address/0x103D239B6aFd3a10EB419B9A164d628e3A1256a2#code)

## Features

### 1. Add Liquidity
The contract supports adding liquidity to the liquidity pool. Below is the transaction link for adding liquidity:
- [Add Liquidity Transaction](https://testnet.bscscan.com/tx/0x19a25237a80de9e9622776de9618cc0efc7a33df8083cf306d424daf89e833fc)

### 2. Buy Tokens
Users can buy tokens from the contract. Example transaction of purchasing 100 tokens:
- [Buy 100 Tokens](https://testnet.bscscan.com/tx/0xff136d8b3aa4041093aa9ccd0a7024c2e5148b482c19a2684df60e2d3044b08d)

### 3. Sell Tokens
The contract allows selling tokens as well. Example transaction for selling 100 tokens:
- [Sell 100 Tokens](https://testnet.bscscan.com/tx/0xfdda5e4d9428479b3cd26900fae7af6013a972920b48a47fc5d140f53a59a90a)

### 4. Max Token Holding Restriction
If the maximum holding limit for tokens is reached, users are restricted from purchasing more tokens.

### 5. Wallet Holding Restriction
The smart contract enforces restrictions on wallet holdings to prevent certain wallets from holding tokens beyond a defined limit.

### 6. Blacklist Functionality
The contract allows the owner to blacklist certain addresses, preventing them from participating in transactions. Example transaction for adding an address to the blacklist:
- [Add to Blacklist](https://testnet.bscscan.com/tx/0x3623c33c324d617643634d3adbb1cfae80044054ec5c87ff032fdb0ddb05b393)

To remove an address from the blacklist, refer to the contract address:
- [Remove from Blacklist](https://testnet.bscscan.com/address/0x103D239B6aFd3a10EB419B9A164d628e3A1256a2)

### 7. Renounce Ownership
The contract owner can renounce ownership, after which no further restrictions or administrative functions can be executed. Example transaction for renouncing ownership:
- [Renounce Ownership](https://testnet.bscscan.com/tx/0x66d752e012d969e881d41b367337396fbcf5ea931344fafd03ed3560a859d239)

Once the ownership is renounced, no restrictions apply to any of the contract functions, as seen in the following transaction:
- [No Restrictions Post-Renouncement](https://testnet.bscscan.com/tx/0xb6aec3f453181843b78e5409344819641df61d223c7e3173f4652caf81ba55f6)

---

## Getting Started

### Prerequisites

To interact with this smart contract, you need the following:
- A Binance Smart Chain wallet (e.g., MetaMask configured for BSC Testnet)
- BNB tokens in the testnet for gas fees

### Interacting with the Contract

You can interact with the contract by using the following methods:
1. **View Contract Code**: [Contract Code](https://testnet.bscscan.com/address/0x103D239B6aFd3a10EB419B9A164d628e3A1256a2#code)
2. **Execute Transactions**: Use [BSC Testnet](https://testnet.bscscan.com/) to interact with the contract using the provided links for specific actions such as buying or selling tokens.

---

## Important Notes

- **Maximum Token Holding**: The contract restricts users from buying tokens if their holding reaches the maximum limit.
- **Maximum Token Holding & Buy restrictions**: After ownership renounce max buy and holding limit will be removed user can buy and hold token without restriction.
- **Blacklist**: Blacklisted addresses cannot participate in transactions. Ensure your address is not blacklisted before interacting with the contract.
- **Ownership**: After renouncing ownership, the contract becomes fully decentralized with no restrictions imposed by the contract owner.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
