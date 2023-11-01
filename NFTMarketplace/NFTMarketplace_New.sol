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
        uint256[] tokenIdOrAmount;
        uint256[] swapListingType;
        address[] swapTokenAddress;
        uint256[] swapTokenIdOrAmount;
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
        uint256[] tokenIdOrAmount;
        uint256[] swapListingType;
        address[] swapTokenAddress;
        uint256[] swapTokenIdOrAmount;
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

    /**
    * @dev Function for creating a new listing.
    * @param _data A structure containing listing details, including token types, addresses, and amounts.
    * @notice This function handles the creation of a new listing. It verifies the data, 
    * transfers tokens based on the listing type, and stores the listing details.
    * @param _data A structure containing listing details, including token types, addresses, and amounts.
    */
    function createListing(listingTupleData memory _data) public payable {
        
        require(_data.tokenAddress.length == _data.tokenIdOrAmount.length, "Token address and token ID/amount arrays must have the same length");
        require(_data.swapTokenAddress.length == _data.swapTokenIdOrAmount.length, "Swap token address and swap token ID/amount arrays must have the same length");
        require(_data.listingEndDate > block.timestamp, "Invalid listing end date");
        if(_data.isSwap){
            for (uint256 stc = 0; stc < _data.swapTokenAddress.length; stc++) {
                require(_data.swapTokenIdOrAmount[stc] > 0, "Invalid swapTokenIdOrAmount");
                require(_data.swapTokenAddress[stc] != address(0), "Invalid swapTokenAddress");
            }
        }

        for (uint256 tc = 0; tc < _data.tokenAddress.length; tc++) {
            require(_data.tokenIdOrAmount[tc] > 0, "Invalid tokenIdOrAmount");
            require(_data.tokenAddress[tc] != address(0), "Invalid tokenAddress");

            if(_data.isSwap){

                if(_data.listingType[tc] == uint256(TokenType.ERC20)){
                    require(IERC20(_data.tokenAddress[tc]).balanceOf(msg.sender) >= _data.tokenIdOrAmount[tc], "You don't have enough ERC20 tokens");
                    IERC20(_data.tokenAddress[tc]).transferFrom(msg.sender, address(this), _data.tokenIdOrAmount[tc]);

                } else if(_data.listingType[tc] == uint256(TokenType.ERC721)){
                    require(IERC721(_data.tokenAddress[tc]).ownerOf(_data.tokenIdOrAmount[tc]) == msg.sender, "You don't own the specified ERC721 token");
                    IERC721(_data.tokenAddress[tc]).transferFrom(msg.sender, address(this), _data.tokenIdOrAmount[tc]);

                } else if(_data.listingType[tc] == uint256(TokenType.ERC1155)){
                    require(IERC1155(_data.tokenAddress[tc]).balanceOf(msg.sender, _data.tokenIdOrAmount[tc]) > 0, "You don't own the specified ERC1155 token");
                    IERC1155(_data.tokenAddress[tc]).setApprovalForAll(address(this), true);
                    //IERC1155(_data.tokenAddress[tc]).safeTransferFrom(msg.sender, _data.buyer, 1, _data.tokenIdOrAmount[tc], "");
                    //IERC1155(_data.tokenAddress[tc]).safeTransferFrom(msg.sender, address(this), 1, _data.tokenIdOrAmount[tc], "");
                }

            } else {

                if(_data.listingType[tc] == uint256(TokenType.ERC20)){
                    if(_data.tokenAddress[tc] == USDTContractAddress){
                        USDT usdtToken = USDT(_data.tokenAddress[tc]);
                        require(msg.value == 0, "Cannot send Ether for token purchase.");
                        usdtToken.approve(address(this), _data.tokenIdOrAmount[tc]);
                        usdtToken.transferFrom(msg.sender, address(this), _data.tokenIdOrAmount[tc]);
                    } else if(_data.tokenAddress[tc] != address(0)){
                        require(msg.value == 0, "Cannot send Coins for token purchase.");
                        require(IERC20(_data.tokenAddress[tc]).balanceOf(msg.sender) >= _data.tokenIdOrAmount[tc], "You don't have enough tokens balance.");
                        IERC20(_data.tokenAddress[tc]).approve(address(this), _data.tokenIdOrAmount[tc]);
                        IERC20(_data.tokenAddress[tc]).transferFrom(msg.sender, address(this), _data.tokenIdOrAmount[tc]);
                    } else {
                        require(msg.value >= _data.tokenIdOrAmount[tc], "Insufficient funds");
                        payable(address(this)).transfer(_data.tokenIdOrAmount[tc]);
                    }
                } else if(_data.listingType[tc] == uint256(TokenType.ERC721)){
                    require(IERC721(_data.tokenAddress[tc]).ownerOf(_data.tokenIdOrAmount[tc]) == msg.sender, "You don't own the specified ERC721 token");
                    IERC721(msg.sender).approve(address(this), _data.tokenIdOrAmount[tc]);
                    IERC721(msg.sender).safeTransferFrom(msg.sender, address(this), _data.tokenIdOrAmount[tc]);
                } else if(_data.listingType[tc] == uint256(TokenType.ERC1155)){
                    require(IERC1155(_data.tokenAddress[tc]).balanceOf(msg.sender, _data.tokenIdOrAmount[tc]) > 0, "You don't own the specified ERC1155 token");
                    //IERC1155(_data.tokenAddress[tc]).setApprovalForAll(msg.sender, true);
                    //IERC1155(_data.tokenAddress[tc]).safeTransferFrom(msg.sender, address(this), 1, _data.tokenIdOrAmount[tc], "");
                    //IERC1155(_data.tokenAddress[tc]).safeTransferFrom(msg.sender, address(this), _data.tokenIdOrAmount[tc], 1, "");
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
            tokenIdOrAmount: _data.tokenIdOrAmount,
            swapListingType: _data.swapListingType,
            swapTokenAddress: _data.swapTokenAddress,
            swapTokenIdOrAmount: _data.swapTokenIdOrAmount,
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
        
        // Handle swap scenario
        if(listing.isSwap){

            // Iterate over tokens in the listing
            for (uint256 tc = 0; tc < listing.swapTokenAddress.length; tc++) {
                if (listing.listingType[tc] == uint256(TokenType.ERC20)) {

                    require(IERC20(listing.tokenAddress[tc]).balanceOf(address(this)) >= listing.tokenIdOrAmount[tc], "Contract don't have enough ERC20 tokens");
                    IERC20(listing.tokenAddress[tc]).approve(address(this), listing.tokenIdOrAmount[tc]);
                    IERC20(listing.tokenAddress[tc]).transfer(listing.buyer, listing.tokenIdOrAmount[tc]);

                    if(listing.swapListingType[tc] == uint256(TokenType.ERC20)){
                        require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenIdOrAmount[tc], "You don't have enough ERC20 tokens");
                        IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC721)){
                        require(IERC721(listing.swapTokenAddress[tc]).ownerOf(listing.swapTokenIdOrAmount[tc]) == msg.sender, "You don't own the specified ERC721 token");
                        IERC721(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC1155)){
                        require(IERC1155(listing.swapTokenAddress[tc]).balanceOf(msg.sender, listing.swapTokenIdOrAmount[tc]) > 0, "You don't own the specified ERC1155 token");
                        IERC1155(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc], 1, "");
                    }
                    
                } else if (listing.listingType[tc] == uint256(TokenType.ERC721)) {

                    require(IERC721(listing.tokenAddress[tc]).ownerOf(listing.tokenIdOrAmount[tc]) == address(this), "Seller don't own the specified ERC721 token");
                    IERC721(listing.tokenAddress[tc]).safeTransferFrom(address(this), msg.sender, listing.tokenIdOrAmount[tc]);
                    
                    if(listing.swapListingType[tc] == uint256(TokenType.ERC20)){
                        require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenIdOrAmount[tc], "You don't have enough ERC20 tokens");
                        IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC721)){
                        require(IERC721(listing.swapTokenAddress[tc]).ownerOf(listing.swapTokenIdOrAmount[tc]) == msg.sender, "You don't own the specified ERC721 token");
                        IERC721(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC1155)){
                        require(IERC1155(listing.swapTokenAddress[tc]).balanceOf(msg.sender, listing.swapTokenIdOrAmount[tc]) > 0, "You don't own the specified ERC1155 token");
                        IERC1155(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc], 1, "");
                    }
                } else if (listing.listingType[tc] == uint256(TokenType.ERC1155)) {

                    require(IERC1155(listing.tokenAddress[tc]).balanceOf(listing.seller, listing.tokenIdOrAmount[tc]) > 0, "Seller don't own the specified ERC1155 token");
                    //IERC1155(listing.tokenAddress[tc]).safeTransferFrom(address(this), msg.sender, listing.tokenIdOrAmount[tc], 1, "");
                    IERC1155(listing.tokenAddress[tc]).safeTransferFrom(listing.seller, listing.buyer, 1, listing.tokenIdOrAmount[tc], "");

                    if(listing.swapListingType[tc] == uint256(TokenType.ERC20)){
                        require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenIdOrAmount[tc], "You don't have enough ERC20 tokens");
                        IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC721)){
                        require(IERC721(listing.swapTokenAddress[tc]).ownerOf(listing.swapTokenIdOrAmount[tc]) == msg.sender, "You don't own the specified ERC721 token");
                        IERC721(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);

                    } else if(listing.swapListingType[tc] == uint256(TokenType.ERC1155)){
                        require(IERC1155(listing.swapTokenAddress[tc]).balanceOf(msg.sender, listing.swapTokenIdOrAmount[tc]) > 0, "You don't own the specified ERC1155 token");
                        IERC1155(listing.swapTokenAddress[tc]).safeTransferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc], 1, "");
                    }
                }
            }

        } else {
            for (uint256 tc = 0; tc < listing.swapTokenAddress.length; tc++) {

                require(listing.listingType[tc] == uint256(TokenType.ERC20), "This listing is not for a buy");
                if(listing.swapTokenAddress[tc] == USDTContractAddress){
                    
                    USDT usdtToken = USDT(listing.swapTokenAddress[tc]);
                    require(msg.value == 0, "Cannot send Ether for token purchase.");
                    usdtToken.transferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);
                    
                } else if(listing.swapTokenAddress[tc] != address(0)){

                    require(msg.value == 0, "Cannot send Coins for token purchase.");
                    require(IERC20(listing.swapTokenAddress[tc]).balanceOf(msg.sender) >= listing.swapTokenIdOrAmount[tc], "You don't have enough tokens balance.");

                    IERC20(listing.tokenAddress[tc]).transfer(msg.sender, listing.tokenIdOrAmount[tc]);
                    IERC20(listing.swapTokenAddress[tc]).transferFrom(msg.sender, listing.seller, listing.swapTokenIdOrAmount[tc]);

                } else {
                    
                    require(msg.value >= listing.swapTokenIdOrAmount[tc], "Insufficient funds");
                    payable(listing.seller).transfer(listing.swapTokenIdOrAmount[tc]);                
                }
            }
        }

        listing.isActive = false;
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
