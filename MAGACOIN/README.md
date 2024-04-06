# How to use contract
```
1. safeMint:- Using SafeMint, you can securely mint your own MagaNFTs, ensuring a smooth and reliable process within the thriving NFT space.
2. approve:- Through the 'approve' function, users can authorize a designated address to manage the transfer of their MagaNFTs on their behalf. This feature enhances flexibility in trading and collaboration within the NFT community, streamlining transactions and enabling secure interactions between parties.
3. transferFrom:- With transferFrom, you have the ability to securely transfer MagaNFTs to another user, facilitating smooth and trusted transactions within the NFT community.
4. setApprovalForAll:- With setApprovalForAll, you can conveniently authorize third-party operators to manage your MagaNFTs, streamlining transactions and collaborations in the NFT market.

5. safeTransferFrom:- With SafeTransferFrom, you can confidently transfer your MagaNFTs, ensuring secure and seamless transactions within the NFT  ecosystem.
6. claimMagaCoin:- With claimMagaCoin, users can securely claim their MagaCoins associated with specific MagaNFTs, ensuring fair distribution and incentivizing NFT ownership. The function validates ownership, checks claim eligibility based on time, and mints the appropriate amount of MagaCoins accordingly, fostering engagement and value within the NFT ecosystem.
7. balanceOf:- The balanceOf function provides users with the ability to query the balance of MagaNFTs associated with a specific address. By calling this function, users can conveniently retrieve information about the quantity of MagaNFTs they own
8. ownerOf:- The ownerOf function allows users to retrieve the current owner of a specific MagaNFT by providing its unique identifier.

---OnlyOwner---
1. setMagaCoinAddress:- To set the MagaCoin contract address, exclusively the contract owner can utilize setMagaCoinAddress, ensuring the provided address is valid, then emits an event confirming the successful address assignment.
2. updateNFTPrice:- To update the NFT price, only the contract owner can call the updateNFTPrice function, providing the new price as an argument, which emits an event signaling the price update.
3. transferOwnership:- The transferOwnership function allows the current owner of the contract to transfer ownership to a new address (newOwner).
4. renounceOwnership:- The renounceOwnership function allows the current owner of the contract to renounce their ownership, After calling renounceOwnership, the contract will no longer have an owner .
```
# Deploy steps
```
1. Deploy magaNFT contract first.
2. Deploy Magacoin using magaNFT contract address.(The initial supply of 5,000,000 MAGA will be minted by the entity deploying this contract.)
3. call "setMagaCoinAddress" function using Magacoin contract address.
```