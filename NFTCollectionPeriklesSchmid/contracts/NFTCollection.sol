// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTCollection is ERC721Burnable, Ownable, Pausable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Minting control
    bool public publicMintEnabled = false;
    bool public whitelistMintEnabled = false;

    uint256 public mintPrice;
    uint256 public maxMintPerTx = 5;
    uint256 public maxMintPerWallet = 10;
    uint256 public maxSupply = 1000000;

    string private _baseTokenURI;
    
    mapping(address => uint256) public mintedWallets;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => bool) public whitelisted;

    event PublicMint(address indexed minter, uint256 indexed tokenId);
    event WhitelistMint(address indexed minter, uint256 indexed tokenId);
    event BulkMint(address indexed owner, uint256[] tokenIds);

    /**
     * @notice Constructor to initialize the NFT collection.
     * @param name Name of the NFT token.
     * @param symbol Symbol of the NFT token.
     * @param _mintPrice Price per NFT mint in wei.
     */
    constructor(
        string memory name,
        string memory symbol,        
        uint256 _mintPrice
    ) ERC721(name, symbol) {        
        mintPrice = _mintPrice;
    }

    // ------------------- Owner Functions -------------------

    /**
     * @notice Set a new maximum supply of NFTs.
     * @param _maxSupply The new max supply value.
     */
    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        require(_maxSupply >= _tokenIdCounter.current(), "New max must be greater than current supply.");
        maxSupply = _maxSupply;
    }

    /**
     * @notice Enable or disable public minting.
     * @param enabled Boolean value to enable/disable.
     */
    function setPublicMintEnabled(bool enabled) external onlyOwner {
        publicMintEnabled = enabled;
    }

    /**
     * @notice Enable or disable whitelist minting.
     * @param enabled Boolean value to enable/disable.
     */
    function setWhitelistMintEnabled(bool enabled) external onlyOwner {
        whitelistMintEnabled = enabled;
    }

    /**
     * @notice Add or remove an address from the whitelist.
     * @param user The address to modify.
     * @param status Whitelist status to set.
     */
    function setWhitelistStatus(address user, bool status) external onlyOwner {
        whitelisted[user] = status;
    }

    /**
     * @notice Set the base URI for token metadata.
     * @param uri New base URI string.
     */
    function setBaseURI(string memory uri) external onlyOwner {
        _baseTokenURI = uri;
    }

    /**
     * @notice Set minting limits per transaction and per wallet.
     * @param _maxPerTx Maximum NFTs per transaction.
     * @param _maxPerWallet Maximum NFTs per wallet.
     */
    function setMintLimits(uint256 _maxPerTx, uint256 _maxPerWallet) external onlyOwner {
        maxMintPerTx = _maxPerTx;
        maxMintPerWallet = _maxPerWallet;
    }

    /**
     * @notice Pause minting and transferring.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause minting and transferring.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Mint multiple NFTs to the owner.
     * @param ipfsHashes Array of IPFS hashes for metadata.
     */
    function bulkMint(string[] calldata ipfsHashes) external onlyOwner {
        require(_tokenIdCounter.current() + ipfsHashes.length <= maxSupply, "Exceeds max supply");

        uint256[] memory tokenIds = new uint256[](ipfsHashes.length);
        for (uint256 i = 0; i < ipfsHashes.length; i++) {
            unchecked { _tokenIdCounter.increment(); }
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            _tokenURIs[tokenId] = ipfsHashes[i];
            tokenIds[i] = tokenId;
        }
        emit BulkMint(msg.sender, tokenIds);
    }

    // ------------------- Public Minting -------------------

    /**
     * @notice Publicly mint NFTs.
     * @param quantity Number of NFTs to mint.
     * @param ipfsHashes Array of IPFS hashes for each NFT.
     */
    function publicMint(uint256 quantity, string[] calldata ipfsHashes) external payable whenNotPaused {
        require(publicMintEnabled, "Public minting is disabled");
        require(quantity == ipfsHashes.length, "Mismatched hash array");
        require(quantity <= maxMintPerTx, "Exceeds max mint per transaction");
        require(mintedWallets[msg.sender] + quantity <= maxMintPerWallet, "Exceeds max mint per wallet");
        require(msg.value >= mintPrice * quantity, "Insufficient ETH");
        require(_tokenIdCounter.current() + quantity <= maxSupply, "Exceeds max supply");

        mintedWallets[msg.sender] += quantity;

        for (uint256 i = 0; i < quantity; i++) {
            unchecked { _tokenIdCounter.increment(); }
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            _tokenURIs[tokenId] = ipfsHashes[i];
            emit PublicMint(msg.sender, tokenId);
        }
    }

    // ------------------- Whitelist Minting -------------------

    /**
     * @notice Mint NFTs if whitelisted.
     * @param quantity Number of NFTs to mint.
     * @param ipfsHashes Array of IPFS hashes for each NFT.
     */
    function whitelistMint(uint256 quantity, string[] calldata ipfsHashes) external payable whenNotPaused {
        require(whitelistMintEnabled, "Whitelist minting is disabled");
        require(whitelisted[msg.sender], "Not whitelisted");
        require(quantity == ipfsHashes.length, "Mismatched hash array");
        require(mintedWallets[msg.sender] + quantity <= maxMintPerWallet, "Exceeds max wallet mint");
        require(msg.value >= mintPrice * quantity, "Insufficient ETH");
        require(_tokenIdCounter.current() + quantity <= maxSupply, "Exceeds max supply");

        mintedWallets[msg.sender] += quantity;

        for (uint256 i = 0; i < quantity; i++) {
            unchecked { _tokenIdCounter.increment(); }
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            _tokenURIs[tokenId] = ipfsHashes[i];
            emit WhitelistMint(msg.sender, tokenId);
        }
    }

    // ------------------- Overrides -------------------

    /**
     * @notice Returns the URI for a given token ID.
     * @param tokenId The token ID to retrieve the URI for.
     * @return URI string.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Nonexistent token");        
        return string(abi.encodePacked(_baseTokenURI, _tokenURIs[tokenId]));
    }

    /**
     * @notice Checks supported interfaces.
     * @param interfaceId The interface ID to check.
     * @return True if supported.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Withdraw all ETH in the contract to the owner.
     */
    function withdraw() external onlyOwner nonReentrant {
        payable(owner()).transfer(address(this).balance);
    }

    function burn(uint256 tokenId) public override onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _burn(tokenId);
    }

    /**
     * @notice Allow contract to receive ETH.
     */
    receive() external payable {}
}