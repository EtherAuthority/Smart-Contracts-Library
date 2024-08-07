# USDCtoEAISwap Contract
## Overview
The USDCtoEAISwap contract facilitates the swapping of USDC tokens for EAI tokens using Uniswap V2. The contract allows for configurable parameters such as swap percentage, treasury wallet, and operation wallet. It also supports excluding certain wallets from performing swap operations.

## Features
- **Swap USDC for EAI**: Swap a percentage of USDC tokens for EAI tokens and send the remaining USDC to a designated operation wallet.
- **Configurable Parameters**: Update swap percentage, treasury wallet, and operation wallet.
- **Wallet Exclusion**: Exclude specific wallets from performing swap operations.
- **Ownership Control**: Only the contract owner can update parameters and exclude wallets.

## Interfaces
- **IERC20**
The contract uses the IERC20 interface to interact with the USDC and EAI tokens. It provides standard ERC20 functionality such as transfer, approve, and transferFrom.

- **IUniswapV2Router02**
The contract uses the IUniswapV2Router02 interface to interact with the Uniswap V2 Router for swapping tokens and adding/removing liquidity.

## Key Functionalities
1. **Inherits from Ownable**: The contract inherits from Ownable, providing basic access control functionality where only the owner can perform certain actions.
2. **Constructor**: The constructor initializes the contract with the USDC and EAI token addresses, the operation wallet, and the treasury wallet. It also sets the initial swap percentage to 50% and assigns the Uniswap Router address.
3. **Update Swap Percentage**: The updateSwapPercentage(uint256 _swapPercentage) function allows the owner to adjust the percentage of USDC to be swapped for EAI tokens.
4. **Update Wallet Addresses**:
- **updateTreasuryWallet(address _treasuryWallet)**: function updates the address that will receive the EAI tokens.
- **updateOperationWallet(address _operationWallet)**: function updates the address that will receive the remaining USDC after the swap.
5. **Exclude Wallets**: The updateExcludedWallet(address _wallet, bool _isExcluded) function allows the owner to exclude specific wallets from performing swap operations.
6. **Swap and Send Function**: The swapAndSend(uint256 usdcAmount) function handles the swapping of USDC for EAI tokens and transfers the remaining USDC to the operation wallet. It ensures only non-excluded wallets can perform this action.
  
### Events #### 
**SwapAndSend(uint256 usdcAmount, uint256 eaiAmount)**
Emitted after a successful swap and send operation, indicating the amounts swapped and sent.
### Modifiers #### 
 **onlyNonExcluded**
 Restricts access to functions so that excluded wallets cannot call them.
### Errors ###
**OwnableUnauthorizedAccount(address account)**: Thrown if an unauthorized account attempts to perform an operation restricted to the owner.
**OwnableInvalidOwner(address owner)**: Thrown if an invalid owner address is provided.
### Usage ###
1. **Deploy the Contract**: Deploy the contract with the appropriate token addresses and wallet addresses.
2. **Configure Parameters**: Use updateSwapPercentage, updateTreasuryWallet, and updateOperationWallet to set the desired parameters.
3. **Perform Swap**: Call swapAndSend to execute the swap and send remaining USDC.
### License ###
This contract is licensed under the MIT License. See the LICENSE file for more details.

## BSC Testnet Transaction
### Contract Addresses ###
- **USDC Contract**: [Transaction](https://testnet.bscscan.com/address/0x2ADF4D0380f860906d579e7D0d760488B463aa85#code)

- **EAGLEAI Contract**: [Transaction](https://testnet.bscscan.com/address/0xe2c24c186aeb2e17f6aab8aa8495a2c969504f74#code)

- **Swap  Contract**: [Transaction](https://testnet.bscscan.com/address/0xdd175654e4991e985d7077de56caca6211438fc1#code)

### Function ###

- **startTrading in EAGLAI**:  [Transaction](https://testnet.bscscan.com/tx/0x0ade0b7eb8c092b43d929d5dd2fb10f05cc720723a61ab3dcc8b61c766fd0635)

- **Pool create with USDC to EAI**:  [Transaction](https://testnet.bscscan.com/tx/0xa949d387f99876e2a50c164ceff413e00a6fb8ce827c905ecf0eb13fe801aa34)

- **Approve  USDCtoEAISwap contract  in USDC contract**: [Transaction](https://testnet.bscscan.com/tx/0xe2e838a590f37ec8cb4e94bf84134809ce6015de8c615edb4588cd46cd505ae5)

- **SwapAndSend**: [Transaction](https://testnet.bscscan.com/tx/0x78437fabc7c0caa73375f360151240a36af7bed18e2c878d7b4018a69058544a)

- **UpdateSwapPercentage**: [Transaction](https://testnet.bscscan.com/tx/0xbb58476a88cbedbf811e8568dae026b39ad69c6ed0925426ee6d843e0899032b)

- **Updateexculdedwallet**: [Transaction](https://testnet.bscscan.com/tx/0xcc0f5143a12a8653b516e4ec4fbe6be564f67b5db12018ea6b307a6a53250c3e)

- **exculded wallet to call SwapAndSend function it will fail** : [Trasaction](https://testnet.bscscan.com/tx/0x4515577157293f9ef9d24b7a3229220083a6e6a2aaa8391e1d44dface0da5397)

- **UpdateOperationWallet*** : [Trasaction](https://testnet.bscscan.com/tx/0x2a98e5a5a410b983307ce0f8a4ec8f8ca1710c7501157fb278ab0267114e4bf1)

- **UpdateTreasuryWallet** : [Trasaction](https://testnet.bscscan.com/tx/0x163a3e7b3f49b79ab45058cf049da8234d1938839d81130fd7c41a7456afb311)

- **SwapAndSend function call after update Swap Percentage, Operation & Treasury wallet*** : [Trasaction](https://testnet.bscscan.com/tx/0xf1567b762da9d101b7c6d6584220947f381a81a4504d2f0b226b001628c02e3a)







