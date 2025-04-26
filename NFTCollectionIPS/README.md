# NFT Collection Smart Contract

## Overview
The **NFT Collection** is an ERC-721 smart contract built for minting, managing, and controlling NFT collections on the Ethereum blockchain. It supports bulk minting, public and whitelist sales, IPFS-based metadata, burnable tokens, and admin-level controls.

---

## Features
- ERC-721 Compliant with Burnable, Pausable, and Ownable extensions
- Bulk minting (owner-only)
- Public and whitelist minting
- Per wallet / per transaction mint limits
- Multiple IPFS base URIs support
- Event logging for mints
- Admin-controlled withdrawal of ETH
- Reentrancy guard on sensitive operations

---

## Constructor

### `constructor(string memory name, string memory symbol, string memory baseTokenURI, uint256 _mintPrice)`
Initializes the contract with:
- `name`: Token name
- `symbol`: Token symbol
- `baseTokenURI`: The base URI for token metadata
- `_mintPrice`: Price per NFT in wei

---

## 🔐 Owner-Only Functions

### `setMaxSupply(uint256 _maxSupply)`
Update the maximum total supply of NFTs. Must be greater than or equal to current minted supply.

---

### `setPublicMintEnabled(bool enabled)`
Enable or disable public minting.

---

### `setWhitelistMintEnabled(bool enabled)`
Enable or disable whitelist minting.

---

### `setWhitelistStatus(address user, bool status)`
Add or remove an address from the whitelist.

---

### `setBaseURI(string memory uri)`
Update the base URI used in token metadata.

---

### `setMintLimits(uint256 _maxPerTx, uint256 _maxPerWallet)`
Set:
- Maximum NFTs per transaction
- Maximum NFTs per wallet

---

### `pause()`
Pause all minting and transfers (uses OpenZeppelin's `Pausable`).

---

### `unpause()`
Unpause the contract.

---

### `bulkMint(string[] calldata ipfsHashes)`
Mint multiple NFTs directly to the owner's address. Only callable by the owner.  
Each entry in `ipfsHashes` is appended to `_baseTokenURI`.

> Emits `BulkMint(address owner, uint256[] tokenIds)`

---

### `withdraw()`
Withdraw all ETH in the contract to the owner's wallet. Uses `ReentrancyGuard` to prevent attacks.

---

## 🌐 Public Functions

### `publicMint(uint256 quantity, string[] calldata ipfsHashes)`
Mint NFTs directly by the public if `publicMintEnabled` is true.

**Requirements:**
- Must pay `mintPrice * quantity`
- Must not exceed `maxMintPerTx` or `maxMintPerWallet`
- Must provide `ipfsHashes.length == quantity`

> Emits `PublicMint(address minter, uint256 tokenId)` for each token

---

### `whitelistMint(uint256 quantity, string[] calldata ipfsHashes)`
Mint NFTs only if the sender is whitelisted.

**Requirements:**
- `whitelistMintEnabled` must be true
- Sender must be whitelisted
- Must pay `mintPrice * quantity`
- Must not exceed `maxMintPerWallet`
- Must provide `ipfsHashes.length == quantity`

> Emits `WhitelistMint(address minter, uint256 tokenId)` for each token

---

## 🔥 Token Management

### `burn(uint256 tokenId)`
Burn (destroy) the token. Only callable by the token owner.

> Inherited from `ERC721Burnable`

---

## 📡 Token Metadata

### `tokenURI(uint256 tokenId) public view override returns (string memory)`
Returns the full token URI:
```solidity
return string(abi.encodePacked(_baseTokenURI, _tokenURIs[tokenId]));
