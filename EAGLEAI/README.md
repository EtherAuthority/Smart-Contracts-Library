# EAGLEAI Smart Contract Documentation

This README provides an overview of the functionalities and usage of the EAGLEAI smart contract.

## Functions

### Blacklist
- addBlacklist : This function allows the contract owner to add an address to a blacklist, preventing the blacklisted address from certain actions or functionalities within the contract.
 It checks if the address is not already blacklisted, adds it to the blacklist if not.
- removeBlacklist : This function lets the contract owner remove an address from the blacklist, restoring its access to contract functionalities. It verifies if the address is blacklisted, removes it if true, and emits an event for the removal action.

### airdrop
- This function enables the contract owner to distribute tokens to multiple addresses simultaneously, ensuring the owner has enough tokens before proceeding with the airdrop.

### approve
- This function allows an address [spender] to spend token on behalf of another address [owner]

### Allowance
- increaseAllowance : This function allows the caller to increase the allowance granted to a spender for spending the caller's tokens. It updates the allowance by adding the specified value to the current allowance
- decreaseAllowance : This function enables the caller to decrease the allowance granted to a spender for spending the caller's tokens. It updates the allowance by subtracting the specified value from the current allowance.

### excludeFromFee
- This function allows the contract owner to exclude an address from fee calculations. It checks if the address is not already excluded and then sets it as excluded from fees.

### includeInFee
- This function enables the contract owner to include an address in fee calculations, reversing the exclusion status previously set for that address.

### excludeFromReward
- This function allows the contract owner to exclude an address from earning rewards. It checks if the address is not already excluded, converts reflected tokens to actual tokens if the address holds any, sets the address as excluded, and adds it to the list of excluded addresses.

### includeInReward
- This function allows the contract owner to include an address in earning rewards, reversing the exclusion status previously set for that address. It checks if the address is currently excluded, removes it from the list of excluded addresses, and sets its token balance to zero to indicate inclusion in rewards.

### Ownership Management
- transferOwnership: Transfer ownership of the contract to a new address.
- renounceOwnership: Renounce ownership, removing the contract owner and leaving the contract without an owner.

### Contract Settings 
- setFundWallet : This function allows the contract owner to set the fund wallet address, ensuring it's not set to zero. It updates the fund wallet address and emits an event to signal the change.
- updateReflectionTaxPer : This function enables the contract owner to update the reflection tax percentages for buying and selling. It sets the new values for the buy and sell reflection taxes, then emits an event to announce the update.
- updateThreshold :This function allows the owner to set limitation for call autoliquidity.
- startTrading: This function enables the contract owner to start trading by setting the tradeEnabled variable to true. It emits an event to indicate that trading has been enabled.

### Transfer
- transfer : This function allows to transfer token from one address to another address.
- transferFrom : This function used by the spender to transfer token from the owner address to another address.

### Note (Bot Protection) : If any Bot try to buy token in 4 hours of contract depolyment then 50% token will deduct and send to contract.  

## How to depoly contract on mainnet

## Prerequisites

- Install the MetaMask browser extension and set up your Base network account.
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
   - Ensure MetaMask is unlocked and set to the Base chain mainnet.
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
- Ensure your MetaMask account has enough ETH/AVAX to cover gas fees for the transaction.

BSC Testnet Transaction
```
 Contract Addresses : 
(https://testnet.bscscan.com/address/0xd4A563D97851EB65c600F45c6c3b6EFDd394cFe6#code)

1. addLiquidity :
(https://testnet.bscscan.com/address/0xd4A563D97851EB65c600F45c6c3b6EFDd394cFe6#code)

2. startTrading : 
(https://testnet.bscscan.com/tx/0xfa7e41a3d8bc2a8b946c47d93f883ed77e10495f9dd5a5534e8c460fd1fcc8a0)

3. Buy Token : (CoinOperationTax: 1%  LiquidtyTax: 1% ReflectionTax: 1% burnTax:0)
(https://testnet.bscscan.com/tx/0xe303ff4955b531c6200fc905876057b9277b7b2b3cb20f35e049789aa250e693)

4. Sell Token :  CoinOperationTax:2%  LiquidtyTax:1% ReflectionTax:2% burnTax:1%
(https://testnet.bscscan.com/tx/0x2ff0bdd74ec97b535642523aa1907e69f47831d0987f0d778c640f9517d63108)

5. addBlacklist (onlyOwner):
(https://testnet.bscscan.com/tx/0xe80427622a8a6d89831efaffa8b391ea59d29f342a6ce4c0bd05b7ec871681fb)

6. removeBlacklist (onlyOwner): 
(https://testnet.bscscan.com/tx/0x4cd0bd5614827797a31c4fbb2e1099d29bed135ca22bca8c17ac1479dab27c70)

7. excludeFromFee (onlyOwner): 
(https://testnet.bscscan.com/tx/0x7b3fd5bffd1dcee3c08b0355ad2b782872c3873c2f7341c8ac08d376e7ac8e97)
- After Token buy/sell fee will not deduct: 
(https://testnet.bscscan.com/tx/0xe01b8846ed5ba9fd2c3c2de49d5dbb9918deb7c1180ffdbad7c98c64ce141725)

8. includeInFeee (onlyOwner):
(https://testnet.bscscan.com/tx/0x5a024c7e97c9a6eb08b372a968ed6908fedca57cbb92db757e46769822acb76a)

9. excludeFromReward (onlyOwner): 
(https://testnet.bscscan.com/tx/0x63a634ab72bd91055a93f066e070cc472cbb73a8075fdc3df30f58cfb699d84f)    

10. includeFromReward (onlyOwner):
(https://testnet.bscscan.com/tx/0xd697a45465c48a7ef1b5ac11bbfb54e19c0e0ddaaa75f1386deb703f9091583a)

11. updateReflectionTaxPer(onlyOwner):
(https://testnet.bscscan.com/tx/0xa6cc5459c88ebd3d94672e096468be50bcbee64c94d267ff4ae9aa44299f27f3)

12. updateThreshold(onlyOwner):
(https://testnet.bscscan.com/tx/0xb7f7d7389481846b8d70e6c789b8b69993db468cedd437d4514745b2b5c9260d)



