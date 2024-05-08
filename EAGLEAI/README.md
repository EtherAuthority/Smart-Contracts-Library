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

### 
