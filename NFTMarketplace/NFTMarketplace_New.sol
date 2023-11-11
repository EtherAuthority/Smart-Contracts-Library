// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface USDT {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ERC1155Interface {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract NFTMarketplace is Ownable {
    /**
    * @title NFT Marketplace Contract
    * @dev This contract manages listings and deals for various types of tokens (ERC20, ERC721, ERC1155).
    */
    enum TokenType { ERC20, ERC721, ERC1155 }

    // Mapping to track the existence and owner of listings
    mapping(uint256 => bool) public listingExists;
    mapping(uint256 => address) public listingOwner;

    // Address of the USDT contract
    address public USDTContractAddress;

    // Counter for generating unique listing IDs
    uint256 public listingCounter = 1;

    // Struct to hold data for creating a new listing
    struct listingTupleData {
        address buyer;
        uint256[] listingType;
        address[] tokenAddress;
        uint256[][] tokenId;
        uint256[][] tokenAmount;
        uint256[] swapListingType;
        address[] swapTokenAddress;
        uint256[][] swapTokenId;
        uint256[][] swapTokenAmount;
        uint256 listingEndDate;
        bool isSwap;
    }
    
    // Struct to represent a listing
    struct Listing {
        uint256 listingId;
        address ownerof;
        address seller;
        address buyer;
        uint256[] listingType;
        address[] tokenAddress;
        uint256[][] tokenId;
        uint256[][] tokenAmount;
        uint256[] swapListingType;
        address[] swapTokenAddress;
        uint256[][] swapTokenId;
        uint256[][] swapTokenAmount;
        uint256 listingEndDate;
        bool isSwap;
        bool isActive;
    }

    // Mapping to store listing details
    mapping(uint256 => Listing) public listings;

    /**
     * @dev Modifier to check if the caller is the seller of a listing.
     * @param listingId The ID of the listing.
     */
    modifier onlySeller(uint256 listingId) {
        require(listings[listingId].seller == msg.sender, "You are not the seller");
        _;
    }

    /**
     * @dev Modifier to check if a listing is active.
     * @param listingId The ID of the listing.
     */
    modifier isActiveListing(uint256 listingId) {
        require(listings[listingId].isActive, "Listing is not active");
        _;
    }

    /**
     * @dev Constructor function to initialize the contract with known tokens.
     */
    constructor() {
        USDTContractAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    }

    receive() external payable { }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes memory data
    ) external returns (bytes4) {
        
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) external returns (bytes4) {
        
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev Sets the USDT contract address.
     * @param _address The new address for the USDT contract.
     */
    function setUSDTContractAddress(address _address) external onlyOwner {
        USDTContractAddress = _address;
    }

    /**
    * @dev Function for creating a new listing.
    * @param _data A structure containing listing details, including token types, addresses, and amounts.
    * @notice This function handles the creation of a new listing. It verifies the data, 
    * transfers tokens based on the listing type, and stores the listing details.
    * @param _data A structure containing listing details, including token types, addresses, and amounts.
    */
    function createListing(listingTupleData memory _data) public payable {
        
        //require(_data.tokenAddress.length == _data.tokenIdOrAmount.length, "Token address and token ID/amount arrays must have the same length");
        //require(_data.swapTokenAddress.length == _data.swapTokenIdOrAmount.length, "Swap token address and swap token ID/amount arrays must have the same length");
        require(_data.listingEndDate > block.timestamp, "Invalid listing end date");

        for (uint256 tc = 0; tc < _data.tokenAddress.length; tc++) {
            require(_data.tokenAddress[tc] != address(0), "Invalid tokenAddress");

            if(_data.listingType[tc] == uint256(TokenType.ERC721) || _data.listingType[tc] == uint256(TokenType.ERC1155)){
                for (uint256 subtc1 = 0; subtc1 < _data.tokenId[tc].length; subtc1++) {
                    require(_data.tokenId[tc][subtc1] > 0, "Invalid tokenId");
                }
            }

            if(_data.listingType[tc] == uint256(TokenType.ERC20) || _data.listingType[tc] == uint256(TokenType.ERC1155)){
                for (uint256 subtc2 = 0; subtc2 < _data.tokenAmount[tc].length; subtc2++) {
                    require(_data.tokenAmount[tc][subtc2] > 0, "Invalid tokenAmount");
                }
            }
        }
        
        if(_data.isSwap){

            for (uint256 stc = 0; stc < _data.swapTokenAddress.length; stc++) {
                require(_data.swapTokenAddress[stc] != address(0), "Invalid swapTokenAddress");

                if(_data.listingType[stc] == uint256(TokenType.ERC721) || _data.listingType[stc] == uint256(TokenType.ERC1155)){
                    for (uint256 subtc3 = 0; subtc3 < _data.swapTokenId[stc].length; subtc3++) {
                        require(_data.swapTokenId[stc][subtc3] > 0, "Invalid swapTokenId");
                    }
                }

                for (uint256 subtc4 = 0; subtc4 < _data.swapTokenAmount[stc].length; subtc4++) {
                    require(_data.swapTokenAmount[stc][subtc4] > 0, "Invalid swapTokenAmount");
                }
            }
        }

        require(_data.listingType.length == _data.tokenAddress.length, "listingType and tokenAddress length should be same.");

        for (uint256 tc = 0; tc < _data.tokenAddress.length; tc++) {
            if(_data.isSwap == true){

                if(_data.listingType[tc] == uint256(TokenType.ERC20)){
                    for (uint256 subtc5 = 0; subtc5 < _data.tokenAmount[tc].length; subtc5++) {
                        require(IERC20(_data.tokenAddress[tc]).balanceOf(msg.sender) >= _data.tokenAmount[tc][subtc5], "You don't have enough ERC20 tokens");
                        IERC20(_data.tokenAddress[tc]).transferFrom(msg.sender, address(this), _data.tokenAmount[tc][subtc5]);
                    }

                } else if(_data.listingType[tc] == uint256(TokenType.ERC721)){
                    for (uint256 subtc6 = 0; subtc6 < _data.tokenId[tc].length; subtc6++) {
                        require(IERC721(_data.tokenAddress[tc]).ownerOf(_data.tokenId[tc][subtc6]) == msg.sender, "You don't own the specified ERC721 token");
                        IERC721(_data.tokenAddress[tc]).transferFrom(msg.sender, address(this), _data.tokenId[tc][subtc6]);
                    }

                } else if(_data.listingType[tc] == uint256(TokenType.ERC1155)){

                    require(_data.tokenAmount[tc].length == _data.tokenId[tc].length, "ERC1155 token id and token amount length should be same.");
                    for (uint256 subtc7 = 0; subtc7 < _data.tokenId[tc].length; subtc7++) {
                        require(IERC1155(_data.tokenAddress[tc]).balanceOf(msg.sender, _data.tokenId[tc][subtc7]) > 0, "You don't own the specified ERC1155 token");
                        IERC1155(_data.tokenAddress[tc]).safeTransferFrom(msg.sender, address(this), _data.tokenId[tc][subtc7], _data.tokenAmount[tc][subtc7], "");
                    }
                }

            } else {

                if(_data.listingType[tc] == uint256(TokenType.ERC20)){
                    if(_data.tokenAddress[tc] == USDTContractAddress){
                        USDT usdtToken = USDT(_data.tokenAddress[tc]);
                        require(msg.value == 0, "Cannot send Ether for token purchase.");
                        for (uint256 subtc8 = 0; subtc8 < _data.tokenAmount[tc].length; subtc8++) {
                            usdtToken.approve(address(this), _data.tokenAmount[tc][subtc8]);
                            usdtToken.transferFrom(msg.sender, address(this), _data.tokenAmount[tc][subtc8]);
                        }
                    } else if(_data.tokenAddress[tc] != address(0)){
                        require(msg.value == 0, "Cannot send Coins for token purchase.");
                        for (uint256 subtc9 = 0; subtc9 < _data.tokenAmount[tc].length; subtc9++) {
                            require(IERC20(_data.tokenAddress[tc]).balanceOf(msg.sender) >= _data.tokenAmount[tc][subtc9], "You don't have enough tokens balance.");
                            IERC20(_data.tokenAddress[tc]).approve(address(this), _data.tokenAmount[tc][subtc9]);
                            IERC20(_data.tokenAddress[tc]).transferFrom(msg.sender, address(this), _data.tokenAmount[tc][subtc9]);
                        }
                    }
                } else if(_data.listingType[tc] == uint256(TokenType.ERC721)){
                    for (uint256 subtc10 = 0; subtc10 < _data.tokenId[tc].length; subtc10++) {
                        require(IERC721(_data.tokenAddress[tc]).ownerOf(_data.tokenId[tc][subtc10]) == msg.sender, "You don't own the specified ERC721 token");
                        IERC721(_data.tokenAddress[tc]).transferFrom(msg.sender, address(this), _data.tokenId[tc][subtc10]);
                    }
                } else if(_data.listingType[tc] == uint256(TokenType.ERC1155)){

                    require(_data.tokenAmount[tc].length == _data.tokenId[tc].length, "ERC1155 token id and token amount length should be same.");

                    for (uint256 subtc11 = 0; subtc11 < _data.tokenId[tc].length; subtc11++) {
                        require(IERC1155(_data.tokenAddress[tc]).balanceOf(msg.sender, _data.tokenId[tc][subtc11]) > 0, "You don't own the specified ERC1155 token");
                        IERC1155(_data.tokenAddress[tc]).safeTransferFrom(msg.sender, address(this), _data.tokenId[tc][subtc11], _data.tokenAmount[tc][subtc11], "");
                    }
                }
            }
        }
        
        uint256 newListingId = listingCounter++;

        listings[newListingId] = Listing({
            listingId: newListingId,
            ownerof: msg.sender,
            seller: msg.sender,
            buyer: _data.buyer,
            listingType: _data.listingType,
            tokenAddress: _data.tokenAddress,
            tokenId: _data.tokenId,
            tokenAmount: _data.tokenAmount,
            swapListingType: _data.swapListingType,
            swapTokenAddress: _data.swapTokenAddress,
            swapTokenId: _data.swapTokenId,
            swapTokenAmount: _data.swapTokenAmount,
            listingEndDate: _data.listingEndDate,
            isSwap: _data.isSwap,
            isActive: true
        });
        
        listingExists[newListingId] = true;
        listingOwner[newListingId] = msg.sender;
    }

    /**
    * @dev Function for confirming a deal for a specific listing.
    * @param listingId The ID of the listing to be confirmed.
    * @notice This function handles the confirmation of a deal for a specific listing.
    * @dev It checks if the listing has expired, ensures the sender is not the seller,
    * and handles the transfer of tokens based on the listing type.
    * @dev If it's a swap listing, it iterates over the tokens involved and transfers them accordingly.
    * @dev If it's a non-swap listing, it transfers ERC20 tokens or Ether based on the conditions.
    * @dev Finally, it marks the listing as inactive.
    * @param listingId The ID of the listing to be confirmed.
    */
    function confirmDeal(uint256 listingId) external payable isActiveListing(listingId) {

        // Retrieve listing details from storage
        Listing storage listing = listings[listingId];
        
        // Check if the listing has expired
        require(block.timestamp < listing.listingEndDate,"Listing Expired");
        // Ensure the sender is not the seller or a third-party
        require(msg.sender != listing.seller, "You cannot buy your own listing");
        require(msg.sender == listing.buyer, "You are not the specified buyer");
        
        listing.isActive = false;

        // Handle swap scenario
        if(listing.isSwap == true){

            // Iterate over tokens in the listing
            for (uint256 tc = 0; tc < listing.swapTokenAddress.length; tc++) {
                if (listing.listingType[tc] == uint256(TokenType.ERC20)) {

                    for (uint256 subtc111 = 0; subtc111 < listing.tokenAmount[tc].length; subtc111++) {
                        require(IERC20(listing.tokenAddress[tc]).balanceOf(address(this)) >= listing.tokenAmount[tc][subtc111], "Contract don't have enough ERC20 tokens");
                        IERC20(listing.tokenAddress[tc]).approve(address(this), listing.tokenAmount[tc][subtc111]);
                        IERC20(listing.tokenAddress[tc]).transfer(listing.buyer, listing.tokenAmount[tc][subtc111]);
                    }

                    if(listing.swapListingType[tc] == uint256(TokenType.ERC20)){
                        for (uint256 subtc12 = 0; subtc12 < listing.swapTokenAmount[tc].length; subtc12++) {
                            require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenAmount[tc][subtc12], "You don't have enough ERC20 tokens");
                            IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenAmount[tc][subtc12]);
                        }

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC721)){
                        for (uint256 subtc13 = 0; subtc13 < listing.swapTokenId[tc].length; subtc13++) {
                            require(IERC721(listing.swapTokenAddress[tc]).ownerOf(listing.swapTokenId[tc][subtc13]) == msg.sender, "You don't own the specified ERC721 token");
                            IERC721(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenId[tc][subtc13]);
                        }

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC1155)){

                        require(listing.swapTokenAmount[tc].length == listing.swapTokenId[tc].length, "ERC1155 swap token id and swap token amount length should be same.");
                        
                        for (uint256 subtc14 = 0; subtc14 < listing.swapTokenId[tc].length; subtc14++) {
                            require(IERC1155(listing.swapTokenAddress[tc]).balanceOf(msg.sender, listing.swapTokenAmount[tc][subtc14]) > 0, "You don't own the specified ERC1155 token");
                            IERC1155(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenId[tc][subtc14], listing.swapTokenAmount[tc][subtc14],"");
                        }
                    }
                    
                } else if (listing.listingType[tc] == uint256(TokenType.ERC721)) {

                    for (uint256 subtc15 = 0; subtc15 < listing.tokenId[tc].length; subtc15++) {
                        require(IERC721(listing.tokenAddress[tc]).ownerOf(listing.tokenId[tc][subtc15]) == address(this), "Contract don't own the specified ERC721 token");
                        IERC721(listing.tokenAddress[tc]).safeTransferFrom(address(this), msg.sender, listing.tokenId[tc][subtc15]);
                    }
                    
                    if(listing.swapListingType[tc] == uint256(TokenType.ERC20)){
                        for (uint256 subtc16 = 0; subtc16 < listing.swapTokenAmount[tc].length; subtc16++) {
                            require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenAmount[tc][subtc16], "You don't have enough ERC20 tokens");
                            IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenAmount[tc][subtc16]);
                        }

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC721)){
                        for (uint256 subtc17 = 0; subtc17 < listing.swapTokenId[tc].length; subtc17++) {
                            require(IERC721(listing.swapTokenAddress[tc]).ownerOf(listing.swapTokenId[tc][subtc17]) == msg.sender, "You don't own the specified ERC721 token");
                            IERC721(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenId[tc][subtc17]);
                        }

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC1155)){

                        require(listing.swapTokenAmount[tc].length == listing.swapTokenId[tc].length, "ERC1155 swap token id and swap token amount length should be same.");

                        for (uint256 subtc18 = 0; subtc18 < listing.swapTokenId[tc].length; subtc18++) {
                            require(IERC1155(listing.swapTokenAddress[tc]).balanceOf(msg.sender, listing.swapTokenAmount[tc][subtc18]) > 0, "You don't own the specified ERC1155 token");
                            IERC1155(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenId[tc][subtc18], listing.swapTokenAmount[tc][subtc18], "");
                        }
                    }
                } else if (listing.listingType[tc] == uint256(TokenType.ERC1155)) {

                    require(listing.tokenAmount[tc].length == listing.tokenId[tc].length, "ERC1155 token id and token amount length should be same.");

                    for (uint256 subtc19 = 0; subtc19 < listing.tokenId[tc].length; subtc19++) {
                        require(IERC1155(listing.tokenAddress[tc]).balanceOf(address(this), listing.tokenId[tc][subtc19]) > 0, "Contract don't own the specified ERC1155 token");
                        IERC1155(listing.tokenAddress[tc]).safeTransferFrom(address(this), listing.buyer, listing.tokenId[tc][subtc19], listing.tokenAmount[tc][subtc19], "");
                    }

                    if(listing.swapListingType[tc] == uint256(TokenType.ERC20)){
                        for (uint256 subtc20 = 0; subtc20 < listing.swapTokenAmount[tc].length; subtc20++) {
                            require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenAmount[tc][subtc20], "You don't have enough ERC20 tokens");
                            IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenAmount[tc][subtc20]);
                        }

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC721)){

                        for (uint256 subtc21 = 0; subtc21 < listing.swapTokenId[tc].length; subtc21++) {
                            require(IERC721(listing.swapTokenAddress[tc]).ownerOf(listing.swapTokenId[tc][subtc21]) == msg.sender, "You don't own the specified ERC721 token");
                            IERC721(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenId[tc][subtc21]);
                        }

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC1155)){

                        require(listing.swapTokenAmount[tc].length == listing.swapTokenId[tc].length, "ERC1155 swap token id and swap token amount length should be same.");

                        for (uint256 subtc22 = 0; subtc22 < listing.swapTokenId[tc].length; subtc22++) {
                            require(IERC1155(listing.swapTokenAddress[tc]).balanceOf(msg.sender, listing.swapTokenId[tc][subtc22]) > 0, "You don't own the specified ERC1155 token");
                            IERC1155(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenId[tc][subtc22], listing.swapTokenAmount[tc][subtc22], "");
                        }
                    }
                }
            }

        } else {
            for (uint256 tc = 0; tc < listing.swapTokenAddress.length; tc++) {

                require(listing.listingType[tc] == uint256(TokenType.ERC20), "This listing is not for a buy");
                if(listing.swapTokenAddress[tc] == USDTContractAddress){
                    
                    USDT usdtToken = USDT(listing.swapTokenAddress[tc]);
                    require(msg.value == 0, "Cannot send Ether for token purchase.");
                    for (uint256 subtc23 = 0; subtc23 < listing.swapTokenAmount[tc].length; subtc23++) {
                        usdtToken.transferFrom(msg.sender, listing.seller, listing.swapTokenAmount[tc][subtc23]);
                    }
                    
                } else if(listing.swapTokenAddress[tc] != address(0)){

                    require(msg.value == 0, "Cannot send Coins for token purchase.");
                    for (uint256 subtc24 = 0; subtc24 < listing.swapTokenAmount[tc].length; subtc24++) {
                        require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenAmount[tc][subtc24], "You don't have enough tokens balance.");
                    
                        IERC20(listing.tokenAddress[tc]).transfer(msg.sender, listing.tokenAmount[tc][subtc24]);
                        IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenAmount[tc][subtc24]);
                    }

                } else {
                    
                    for (uint256 subtc25 = 0; subtc25 < listing.swapTokenAmount[tc].length; subtc25++) {
                        require(msg.value >= listing.swapTokenAmount[tc][subtc25], "Insufficient funds");
                        payable(listing.seller).transfer(listing.swapTokenAmount[tc][subtc25]);
                    }
                }
            }
        }
    }

    /**
    * @dev Get details of a specific listing.
    * @param _listingId The ID of the listing to retrieve.
    * @return Listing details including listing ID, owner, seller, buyer, listing types, token addresses, 
    * token IDs/amounts, swap listing types, swap token addresses, swap token IDs/amounts, listing end date, 
    * swap status, and active status.
    */
    function getListingDetails(uint256 _listingId) public view returns (Listing memory) {
        return listings[_listingId];
    }

    /**
     * @dev Function to get the name of a TokenType.
     * @param tokenType The TokenType (0 for ERC20, 1 for ERC721, 2 for ERC1155).
     * @return string Returns the name of the TokenType.
     */
    function getTokenType(uint8 tokenType) public pure returns (string memory) {
        require(tokenType >= 0 && tokenType <= 2, "Invalid input. Use 0 for ERC20, 1 for ERC721, 2 for ERC1155.");
        
        if (tokenType == 0) {
            return "ERC20";
        } else if (tokenType == 1) {
            return "ERC721";
        } else {
            return "ERC1155";
        }
    }

    /**
     * @dev Function to get the name of a swap TokenType.
     * @param tokenType The TokenType (0 for ERC20, 1 for ERC721, 2 for ERC1155).
     * @return string Returns the name of the TokenType.
     */
    function getSwapTokenType(uint8 tokenType) public pure returns (string memory) {
        require(tokenType >= 0 && tokenType <= 2, "Invalid input. Use 0 for ERC20, 1 for ERC721, 2 for ERC1155.");
        
        if (tokenType == 0) {
            return "ERC20";
        } else if (tokenType == 1) {
            return "ERC721";
        } else {
            return "ERC1155";
        }
    }
}
