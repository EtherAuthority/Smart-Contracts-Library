# AST Factory Contract Readme

## Introduction

This document describes the functions and capabilities of the AST Factory contract, which allows for the creation and management of AST (Asset Token) tokens. The contract owner has specific permissions to control various aspects of the contract.

## Functions

### 1. SetAATContract

- **Function:** `SetAATContract(address _token)`
- **Permission:** Only the contract owner can call this function.
- **Description:** The contract owner can call this function in the AST Factory contract with the address of the "AAT Token Contract" to create a link to call the "AAT token" contract from the AST Factory contract.

### 2. SetPoolWallet

- **Function:** `SetPoolWallet(address _wallet)`
- **Permission:** Only the contract owner can call this function.
- **Description:** The contract owner can call this function in the AST Factory contract with the address of the "Asset Locked Owner" wallet. This address will hold the minted "AST" tokens whenever they are minted.

### 3. CreateASTToken

- **Function:** `CreateASTToken(string memory name_, string memory symbol_, uint256 totalSupply_, uint256 _ratio)`
- **Permission:** Only the contract owner can call this function.
- **Description:** The contract owner can call this function to create/generate "AST" tokens. This function generates AST tokens with the given total supply and splits them into a 50/50 ratio. The first 50% of the "AST" tokens will be minted to the "Asset Owner Wallet," and the other 50% will be stored in the AST Factory. The parameter `_ratio` is the conversion ratio between AST to AAT and AAT to AST tokens.

### 4. Example Ratios

- For example, if 1 AAT = 7.25 AST, the user must pass "725" in the `_ratio` parameter of the `CreateASTToken` function.
- If 1 AAT = 70.25 AST, the user must pass "7025" in the `_ratio` variable. After this, the amount of "AST" tokens minted to the AST Factory will be converted to "AAT" and minted to the "Pool Wallet" address.

### 5. ASTConversionAmount

- **Function:** `ASTConversionAmount(address _astToken, uint256 _aatAmount)`
- **Description:** This function requires the "AST" token address and an "AAT" amount. It will return the "AST" token amount in proportion to the "AAT" amount given in the parameter and the "AST" tokens that need to be burned.

### 6. AATBurnAmount

- **Function:** `AATBurnAmount(address _astToken)`
- **Description:** This function requires the "AST" token address to return the "AAT" amount.

### 7. ReturnASTToLockedOwner

- **Function:** `ReturnASTToLockedOwner(address _astToken, uint256 _astAmount)`
- **Description:** This function requires the "AST" token address and "AST" token amount. It is called internally and transfers the converted "AST" token amount from the "AAT" token amount to the "Asset Owner Wallet."

### 8. BurnAAT

- **Function:** `BurnAAT(uint256 _amount, address _astToken)`
- **Description:** This function requires an "AAT" token amount and the "AST" contract address for which you want to burn your "AAT" tokens and generate "AST" tokens.

### 9. BurnAstToken

- **Function:** `BurnAstToken(address _astToken)`
- **Permission:** This function can only be used by the contract owner.
- **Description:** This function is used by the contract owner. It requires the "AST" token address to burn the "AST" tokens when the "Asset Owner Wallet" holds more than 99% of that "AST" token in their wallet.

## Additional Notes

- The owner can add any wallet address to the `SetFactory()` function and can receive all the minted "AST" tokens to that wallet.

Feel free to reach out for any further clarifications or assistance.
