# AttentionFUD  smart Contract Documentation

This README provides an overview of the functionalities and usage of the AttentionFUD smart contract.

### New Added Function :

#### getTokensStake:

- The getTokensStake function retrieves and returns the names of all projects and the respective amounts of tokens staked by a specified wallet. It outputs two arrays: one containing the project names and the other containing the corresponding token amounts staked by the given wallet.

#### getStakes:

- The getStakes function show us each address that is currently staking, what project they staked on, and how many tokens they staked on each project. Such as  project,amount,wallet

### Modifed Function :

#### depositTokens:

- Now user can add minimum 1 characters in the project name.
- Users can to stake on more than one project at a time and to stake more on the same project if they want to.

#### withdrawTokens:

- Now user can not withdraw token when flipStakeState will false.

#### burnDeposit:

- The burnDeposit function to burn all staked tokens from all the projects.Now no need to enter projet name, owner can burn all Deposit on click.

#### emergencyTransfer:

- The emergencyTransfer function transfers all tokens in the contract to the hardcoded address.But now it will 'reset all array value' like burnDeposit function.

## How to depoly contract on mainnet

## Prerequisites

- Install the MetaMask browser extension and set up your Ethereum account.
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
   - Ensure MetaMask is unlocked and set to the mainnet.
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
- Ensure your MetaMask account has enough ETH to cover gas fees for the transaction.

## BSC Testnet Transaction

## Contract Addresses

- **AttentionFUD Contract**: [Contract](https://testnet.bscscan.com/address/0x522bdf72f8ebc5cb3853facdeaa9f0d743fb4330#code)
- **ERC1155 Contract**: [Contract](https://testnet.bscscan.com/tx/0x55a681c2158ab958cd2d3bd65b98eb21aac3ea4b244d2104ffb5508b8498eb5c)

1. **SetFUDContract transaction**: [Transaction](https://testnet.bscscan.com/tx/0xf8c7dce988c05c5afc4d085f1af47cf3b89a182c18893d328ca773bee64e739c)

2. **flipStakeState transaction**: [Transaction](https://testnet.bscscan.com/tx/0x498c34321c077aae0b9f1867f454c9aa19f6396ea85d2009afed882f4bd87d7b)

3. **depositTokens transaction**: [Transaction](https://testnet.bscscan.com/tx/0x6d9632d099c9b30f5886446a5e6a883e9d30ae0b69867863ab003d646329691b)
- deposit On same project: [Transaction](https://testnet.bscscan.com/tx/0x9c14d1a1721062eb4d9e814960bc3042314d50305deefc0eab945065a2beb825)
- deposit on different project: [Transaction](https://testnet.bscscan.com/tx/0x50c96d546c57276dc1790701a7e49ab8522da1a10bf94da29390f498dfe34151)

4. **withdrawTokens transaction**: [Transaction](https://testnet.bscscan.com/tx/0x7fa5018dd0e5b6bcba3844b943b9961d35c1a908e78cf538d6b5b70f12dccf4e)

5. **emergencyTransfer transaction**: [Transaction](https://testnet.bscscan.com/tx/0x9360f2e6126c18ea7e67b8c007d6e398dbe5c6038ae717def6ef309a12196756)

6. **flipStakeState transaction**: [Transaction](https://testnet.bscscan.com/tx/0x3c17beeff028ffe57755ecf8cfc7921bde19ff6a48693063f9128c808a5b7bc0)

7. **burnDeposit transaction**: [Transaction](https://testnet.bscscan.com/tx/0xbd5e22f6098c2e6f813e73061d6ec8402a291609b4263796c6075836a4471e35)

### Notes

- Ensure you are connected to the BSC Testnet network on your MetaMask to view these transactions and contracts.
- Check transaction details for gas fees and confirmations.


