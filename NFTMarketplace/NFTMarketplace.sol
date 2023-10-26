// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

contract NFTMarketplace is Ownable{
    enum TokenType { ERC20, ERC721, ERC1155 }
    mapping(uint256 => bool) public listingExists;
    mapping(uint256 => address) public listingOwner;
    
    address public USDTContractAddress;
    
    struct SwapDetails {
        bool isSwap;
        uint256 swapTokenIdOrAmount;
        address swapTokenAddress;
        TokenType swapTokenType;
    }

    struct Listing {
        uint256 listingId;
        address ownerof;
        address seller;
        address buyer;
        uint256 tokenIdOrAmount;
        address tokenAddress;
        uint256 price;
        bool isActive;
        TokenType tokenType;
        uint256 feeAmount;
        address feeToken;
        uint256 listingEndDate;
        SwapDetails swapDetails;
    }

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
     * @dev Sets the USDT contract address.
     * @param _address The new address for the USDT contract.
     */
    function setUSDTContractAddress(address _address) external onlyOwner {
        USDTContractAddress = _address;
    }

    /**
     * @dev Internal function to check if a given TokenType is defined.
     * @param tokenType The TokenType to check.
     * @return bool Returns true if TokenType is defined, otherwise false.
     */
    function checkDefinedTokenType(TokenType tokenType) internal pure returns (bool) {
        return tokenType != TokenType.ERC20 && tokenType != TokenType.ERC721 && tokenType != TokenType.ERC1155;
    }

    /**
     * @dev Internal function for common validation when creating a listing.
     * @param listingId The ID of the listing.
     * @param tokenIdOrAmount The ID or amount of the token.
     * @param tokenAddress The address of the token contract.
     * @param price The price of the listing.
     * @param feeAmount The fee amount.
     * @param feeToken The address of the fee token.
     * @param isSwap Indicates if the listing is for swapping.
     * @param swapTokenIdOrAmount The ID or amount of the swap token.
     * @param swapTokenAddress The address of the swap token contract.
     */
    function createListingCommonValidation(
        uint256 listingId,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenIdOrAmount,
        address swapTokenAddress,
        uint256 listingEndDate
    ) internal view {

        require(!listingExists[listingId], "Listing ID already exists");
        require(feeAmount <= 15, "Fee should not be greater than 15%.");
        require(tokenIdOrAmount > 0, "Invalid amount");
        require(listingId > 0, "Invalid listingId");
        require(price > 0, "Invalid price");
        require(feeToken != address(0), "Invalid fee token");
        require(feeAmount > 0, "Invalid feeAmount");
        if(tokenAddress != address(0) && swapTokenAddress != address(0)){
            require(tokenAddress != swapTokenAddress && tokenIdOrAmount != swapTokenIdOrAmount, "tokenAddress and tokenIdOrAmount should not be same as swapTokenAddress and swapTokenIdOrAmount");
        }
        require(listingEndDate > block.timestamp, "Invalid listing end date");

        if(isSwap){
            require(swapTokenIdOrAmount > 0, "Invalid swapTokenIdOrAmount");
            require(swapTokenAddress != address(0), "Invalid swapTokenAddress");
        }
    }

    /**
     * @dev Internal function to check if the seller has the required tokens for a listing.
     * @param seller The address of the seller.
     * @param tokenType The TokenType of the token.
     * @param tokenAddress The address of the token contract.
     * @param tokenIdOrAmount The ID of the token.
     * @return bool Returns true if the seller has the required tokens, otherwise false.
     */
    function hasRequiredTokens(address seller, TokenType tokenType, address tokenAddress, uint256 tokenIdOrAmount) internal view returns (bool) {
        if (tokenType == TokenType.ERC20) {
            return IERC20(tokenAddress).balanceOf(seller) >= tokenIdOrAmount;
        } else if (tokenType == TokenType.ERC721) {
            return IERC721(tokenAddress).ownerOf(tokenIdOrAmount) == seller;
        } else if (tokenType == TokenType.ERC1155) {
            return IERC1155(tokenAddress).balanceOf(seller, tokenIdOrAmount) > 0;
        } else {
            return false;
        }
    }

    /**
     * @dev Function to create an ERC20 listing.
     * @param listingId The ID of the listing.
     * @param buyer The address of the buyer.
     * @param tokenIdOrAmount The ID or amount of the token.
     * @param tokenAddress The address of the token contract.
     * @param price The price of the listing.
     * @param feeAmount The fee amount.
     * @param feeToken The address of the fee token.
     * @param isSwap Indicates if the listing is for swapping.
     * @param swapTokenIdOrAmount The ID or amount of the swap token.
     * @param swapTokenAddress The address of the swap token contract.
     * @param swapTokenType The TokenType of the swap token.
     */
    function createListingERC20(
        uint256 listingId,
        address buyer,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenIdOrAmount,
        address swapTokenAddress,
        TokenType swapTokenType,
        uint256 listingEndDate
    ) external {
        if(tokenAddress != address(0)){
            require(hasRequiredTokens(msg.sender, TokenType.ERC20, tokenAddress, tokenIdOrAmount), "Seller doesn't have the required tokens");
            require(IERC20(tokenAddress).allowance(msg.sender, address(this)) >= tokenIdOrAmount, "Seller hasn't approved token transfer");
        }
        
        createListingCommonValidation(listingId, tokenIdOrAmount, tokenAddress, price, feeAmount, feeToken, isSwap, swapTokenIdOrAmount, swapTokenAddress, listingEndDate);
        if (swapTokenType != TokenType.ERC20 && swapTokenType != TokenType.ERC721 && swapTokenType != TokenType.ERC1155) {
            revert("Invalid swap token type, Use 0 for ERC20, 1 for ERC721, 2 for ERC1155.");
        }

        SwapDetails memory swapDetails;
        swapDetails.isSwap = isSwap;
        swapDetails.swapTokenIdOrAmount = swapTokenIdOrAmount;
        swapDetails.swapTokenAddress = swapTokenAddress;
        swapDetails.swapTokenType = swapTokenType;

        listings[listingId] = Listing({
            listingId: listingId,
            ownerof: msg.sender,
            seller: msg.sender,
            buyer: buyer,
            tokenIdOrAmount: tokenIdOrAmount,
            tokenAddress: tokenAddress,
            price: price,
            isActive: true,
            tokenType: TokenType.ERC20,
            feeAmount: feeAmount,
            feeToken: feeToken,
            listingEndDate: listingEndDate,
            swapDetails: swapDetails
        });

        listingExists[listingId] = true;
        listingOwner[listingId] = msg.sender;
       
    }

    /**
     * @dev Function to create an ERC721 listing.
     * @param listingId The ID of the listing.
     * @param buyer The address of the buyer.
     * @param tokenIdOrAmount The ID or amount of the token.
     * @param tokenAddress The address of the token contract.
     * @param price The price of the listing.
     * @param feeAmount The fee amount.
     * @param feeToken The address of the fee token.
     * @param isSwap Indicates if the listing is for swapping.
     * @param swapTokenIdOrAmount The ID or amount of the swap token.
     * @param swapTokenAddress The address of the swap token contract.
     * @param swapTokenType The TokenType of the swap token.
     */
    function createListingERC721(
        uint256 listingId,
        address buyer,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenIdOrAmount,
        address swapTokenAddress,
        TokenType swapTokenType,
        uint256 listingEndDate
    ) external {

        require(hasRequiredTokens(msg.sender, TokenType.ERC721, tokenAddress, tokenIdOrAmount), "Seller doesn't have the required tokens");
        require(IERC721(tokenAddress).getApproved(tokenIdOrAmount) == address(this), "TokenId not approved");
        createListingCommonValidation(listingId, tokenIdOrAmount, tokenAddress, price, feeAmount, feeToken, isSwap, swapTokenIdOrAmount, swapTokenAddress, listingEndDate);
        if (swapTokenType != TokenType.ERC20 && swapTokenType != TokenType.ERC721 && swapTokenType != TokenType.ERC1155) {
            revert("Invalid swap token type, Use 0 for ERC20, 1 for ERC721, 2 for ERC1155.");
        }

        SwapDetails memory swapDetails;
        swapDetails.isSwap = isSwap;
        swapDetails.swapTokenIdOrAmount = swapTokenIdOrAmount;
        swapDetails.swapTokenAddress = swapTokenAddress;
        swapDetails.swapTokenType = swapTokenType;

        listings[listingId] = Listing({
            listingId: listingId,
            ownerof: msg.sender,
            seller: msg.sender,
            buyer: buyer,
            tokenIdOrAmount: tokenIdOrAmount,
            tokenAddress: tokenAddress,
            price: price,
            isActive: true,
            tokenType: TokenType.ERC721,
            feeAmount: feeAmount,
            feeToken: feeToken,
            listingEndDate: listingEndDate,
            swapDetails: swapDetails
        });

        listingExists[listingId] = true;
        listingOwner[listingId] = msg.sender;

    }

    /**
     * @dev Function to create an ERC1155 listing.
     * @param listingId The ID of the listing.
     * @param buyer The address of the buyer.
     * @param tokenIdOrAmount The ID or amount of the token.
     * @param tokenAddress The address of the token contract.
     * @param price The price of the listing.
     * @param feeAmount The fee amount.
     * @param feeToken The address of the fee token.
     * @param isSwap Indicates if the listing is for swapping.
     * @param swapTokenIdOrAmount The ID or amount of the swap token.
     * @param swapTokenAddress The address of the swap token contract.
     * @param swapTokenType The TokenType of the swap token.
     */
    function createListingERC1155(
        uint256 listingId,
        address buyer,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenIdOrAmount,
        address swapTokenAddress,
        TokenType swapTokenType,
        uint256 listingEndDate
    ) external {

        require(hasRequiredTokens(msg.sender, TokenType.ERC1155, tokenAddress, tokenIdOrAmount), "Seller doesn't have the required tokens");
        require(IERC1155(tokenAddress).isApprovedForAll(msg.sender, address(this)), "TokenId not approved");
        createListingCommonValidation(listingId, tokenIdOrAmount, tokenAddress, price, feeAmount, feeToken, isSwap, swapTokenIdOrAmount, swapTokenAddress, listingEndDate);
        if (swapTokenType != TokenType.ERC20 && swapTokenType != TokenType.ERC721 && swapTokenType != TokenType.ERC1155) {
            revert("Invalid swap token type, Use 0 for ERC20, 1 for ERC721, 2 for ERC1155.");
        }
        
        SwapDetails memory swapDetails;
        swapDetails.isSwap = isSwap;
        swapDetails.swapTokenIdOrAmount = swapTokenIdOrAmount;
        swapDetails.swapTokenAddress = swapTokenAddress;
        swapDetails.swapTokenType = swapTokenType;

        listings[listingId] = Listing({
            listingId: listingId,
            ownerof: msg.sender,
            seller: msg.sender,
            buyer: buyer,
            tokenIdOrAmount: tokenIdOrAmount,
            tokenAddress: tokenAddress,
            price: price,
            isActive: true,
            tokenType: TokenType.ERC1155,
            feeAmount: feeAmount,
            feeToken: feeToken,
            listingEndDate: listingEndDate,
            swapDetails: swapDetails
        });

        listingExists[listingId] = true;
        listingOwner[listingId] = msg.sender;

    }
    
    /**
     * @dev Function to buy a listing.
     * @param listingId The ID of the listing.
     */
    function buyListing(uint256 listingId) external payable isActiveListing(listingId) {
        
        
        Listing storage listing = listings[listingId];
        
        require(listing.swapDetails.isSwap == false, "This listing is not for a buy");
        
        require(block.timestamp < listing.listingEndDate,"Listing Expired");
        require(msg.sender != listing.seller, "You cannot buy your own listing");
        require(msg.sender == listing.buyer, "You are not the specified buyer");
        
        uint256 totalPrice = listing.price;
        uint256 fee = 0;
        
        fee = (totalPrice * listing.feeAmount) / 100;

        if(listing.tokenAddress == USDTContractAddress){
            
            USDT usdtToken = USDT(listing.tokenAddress);

            require(msg.value == 0, "Cannot send Ether for token purchase.");
            require(usdtToken.balanceOf(msg.sender) >= totalPrice, "You don't have enough USDT token balance.");
            
            usdtToken.transferFrom(msg.sender, listing.seller, totalPrice - fee);
            if (fee > 0) {
                usdtToken.transferFrom(msg.sender, listing.feeToken, fee);
            }
        } else if(listing.tokenAddress != address(0)){

            require(msg.value == 0, "Cannot send Coins for token purchase.");
            require(IERC20(listing.tokenAddress).balanceOf(msg.sender) >= totalPrice, "You don't have enough tokens balance.");
            IERC20(listing.tokenAddress).transferFrom(msg.sender, listing.seller, totalPrice - fee);
            if (fee > 0) {
                IERC20(listing.tokenAddress).transferFrom(msg.sender, listing.feeToken, fee);
            }

        } else {
            
            require(msg.value >= totalPrice, "Insufficient funds");
            payable(listing.seller).transfer(totalPrice - fee);
            if (fee > 0) {
                payable(listing.feeToken).transfer(fee);
            }
        }    

        //listing.isActive = false;
    }

    /**
     * @dev Function to confirm a swap for a listing.
     * @param listingId The ID of the listing.
     */
    function confirmSwap(uint256 listingId) external isActiveListing(listingId) {
        Listing storage listing = listings[listingId];
        require(listing.swapDetails.isSwap, "This listing is not for a swap");
        
        require(block.timestamp < listing.listingEndDate,"Listing Expired");
        require(msg.sender != listing.seller, "You cannot buy your own listing");
        require(msg.sender == listing.buyer, "You are not the specified buyer");

        if (listing.tokenType == TokenType.ERC20) {
            
            require(IERC20(listing.tokenAddress).balanceOf(listing.seller) >= listing.tokenIdOrAmount, "Seller don't have enough ERC20 tokens");
            IERC20(listing.tokenAddress).transferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount);

            if(listing.swapDetails.swapTokenType == TokenType.ERC20){
                require(IERC20(listing.swapDetails.swapTokenAddress).balanceOf(msg.sender) >= listing.swapDetails.swapTokenIdOrAmount, "You don't have enough ERC20 tokens");
                IERC20(listing.swapDetails.swapTokenAddress).transferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount);

            } else if(listing.swapDetails.swapTokenType == TokenType.ERC721){
                require(IERC721(listing.swapDetails.swapTokenAddress).ownerOf(listing.swapDetails.swapTokenIdOrAmount) == msg.sender, "You don't own the specified ERC721 token");
                IERC721(listing.swapDetails.swapTokenAddress).safeTransferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount);

            } else if(listing.swapDetails.swapTokenType == TokenType.ERC1155){
                require(IERC1155(listing.swapDetails.swapTokenAddress).balanceOf(msg.sender, listing.swapDetails.swapTokenIdOrAmount) > 0, "You don't own the specified ERC1155 token");
                IERC1155(listing.swapDetails.swapTokenAddress).safeTransferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount, 1, "");

            }
       
        } else if (listing.tokenType == TokenType.ERC721) {
            
            require(IERC721(listing.tokenAddress).ownerOf(listing.tokenIdOrAmount) == listing.seller, "Seller don't own the specified ERC721 token");
            IERC721(listing.tokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount);

            if(listing.swapDetails.swapTokenType == TokenType.ERC20){
                require(IERC20(listing.swapDetails.swapTokenAddress).balanceOf(msg.sender) >= listing.swapDetails.swapTokenIdOrAmount, "You don't have enough ERC20 tokens");
                IERC20(listing.swapDetails.swapTokenAddress).transferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount);

            } else if(listing.swapDetails.swapTokenType == TokenType.ERC721){
                require(IERC721(listing.swapDetails.swapTokenAddress).ownerOf(listing.swapDetails.swapTokenIdOrAmount) == msg.sender, "You don't own the specified ERC721 token");
                IERC721(listing.swapDetails.swapTokenAddress).safeTransferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount);

            } else if(listing.swapDetails.swapTokenType == TokenType.ERC1155){
                require(IERC1155(listing.swapDetails.swapTokenAddress).balanceOf(msg.sender, listing.swapDetails.swapTokenIdOrAmount) > 0, "You don't own the specified ERC1155 token");
                IERC1155(listing.swapDetails.swapTokenAddress).safeTransferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount, 1, "");

            }

        } else if (listing.tokenType == TokenType.ERC1155) {
            
            require(IERC1155(listing.tokenAddress).balanceOf(listing.seller, listing.tokenIdOrAmount) > 0, "Seller don't own the specified ERC1155 token");
            IERC1155(listing.tokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount, 1, "");

            if(listing.swapDetails.swapTokenType == TokenType.ERC20){
                require(IERC20(listing.swapDetails.swapTokenAddress).balanceOf(msg.sender) >= listing.swapDetails.swapTokenIdOrAmount, "You don't have enough ERC20 tokens");
                IERC20(listing.swapDetails.swapTokenAddress).transferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount);

            } else if(listing.swapDetails.swapTokenType == TokenType.ERC721){
                require(IERC721(listing.swapDetails.swapTokenAddress).ownerOf(listing.swapDetails.swapTokenIdOrAmount) == msg.sender, "You don't own the specified ERC721 token");
                IERC721(listing.swapDetails.swapTokenAddress).safeTransferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount);

            } else if(listing.swapDetails.swapTokenType == TokenType.ERC1155){
                require(IERC1155(listing.swapDetails.swapTokenAddress).balanceOf(msg.sender, listing.swapDetails.swapTokenIdOrAmount) > 0, "You don't own the specified ERC1155 token");
                IERC1155(listing.swapDetails.swapTokenAddress).safeTransferFrom(msg.sender, listing.seller, listing.swapDetails.swapTokenIdOrAmount, 1, "");

            }
        }
        
        listing.isActive = false;
    }

    /**
     * @dev Function to get details of a listing.
     * @param listingId The ID of the listing.
     * @return Listing Returns the details of the listing.
     */
    function getListingDetails(uint256 listingId) external view returns (Listing memory) {
        return listings[listingId];
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
