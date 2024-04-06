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
# Testnet Transaction
```
Deploy magaNFT:-  https://testnet.bscscan.com/address/0x139fa7DeFB26D177474Fdccd4274fE619a22317A#code
Deploy Magacoin:- https://testnet.bscscan.com/address/0xC30573f1D8b50F1Dd7e6E00E37e9dFcbf0757981#code 
setMagaCoinAddress:-  https://testnet.bscscan.com/tx/0x1949f12f735d39ffd143b91a112ada70ebc28e73d2f527f39c4645d8e9dc2896 (onlyOwner)
SafeMint:- https://testnet.bscscan.com/tx/0x79572d097400e9e8476584260eede47874a8a03eaa97b173821b5781e4281ff8
updateNFTPrice:- https://testnet.bscscan.com/tx/0x203835c6777d5688b6ef1394cf6c7ecbb7763fb42078e5bf8c05daf6c9934e33 (onlyOwner)
approve:- https://testnet.bscscan.com/tx/0x4d3819c4202a490b71b0ed69b55be8dda5f8ae20051442987da5ab73de705a27
transferFrom:- https://testnet.bscscan.com/tx/0x9449d50523a4f30d806c17304ea38471fbf22b803c9d94422a87e5c1868c335b
claimMagaCoin:- https://testnet.bscscan.com/tx/0x67fdcb3fc343b4b321eae45af91371691dd694d633199111040558077fe410d6 (Note:- it will fail because claim time is Sunday, March 2nd 2025, 4:08:44 pm)
transferOwnership:- https://testnet.bscscan.com/tx/0x84630ce0a0851b7e1caab5493a3f8cf28d0f23f007dd83bb994636c037d31973 (onlyOwner)
```