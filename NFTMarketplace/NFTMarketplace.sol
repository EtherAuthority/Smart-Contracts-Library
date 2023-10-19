// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract NFTMarketplace {
    enum TokenType { ERC20, ERC721, ERC1155 }
    mapping(uint256 => bool) public listingExists;
    
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
        bool isSwap; // isSwap is set to false for sale
        uint256 swapTokenId; // swapTokenId is not used for sale
        address swapTokenAddress; // swapTokenAddress is not used for sale
    }

    mapping(uint256 => Listing) public listings;
    
    modifier onlySeller(uint256 listingId) {
        require(listings[listingId].seller == msg.sender, "You are not the seller");
        _;
    }

    modifier isActiveListing(uint256 listingId) {
        require(listings[listingId].isActive, "Listing is not active");
        _;
    }

    function checkDefinedTokenType(TokenType tokenType) internal pure returns (bool) {
        return tokenType != TokenType.ERC20 && tokenType != TokenType.ERC721 && tokenType != TokenType.ERC1155;
    }

    function createListingCommon(
        uint256 listingId,
        address seller,
        address buyer,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        bool isActive,
        TokenType tokenType,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenId,
        address swapTokenAddress
    ) internal {

        require(!listingExists[listingId], "Listing ID already exists");
        require(feeAmount <= 15, "Fee should not be greater than 15%.");
        require(tokenIdOrAmount > 0, "Invalid amount");
        require(listingId > 0, "Invalid listingId");
        require(tokenAddress != address(0), "Invalid tokenAddress");
        require(price > 0, "Invalid price");
        require(feeAmount > 0, "Invalid feeAmount");

        if(isSwap){
            require(swapTokenId > 0, "Invalid swapTokenId");
            require(swapTokenAddress != address(0), "Invalid swapTokenAddress");
        }

        listings[listingId] = Listing({
            listingId: listingId,
            ownerof: msg.sender,
            seller: seller,
            buyer: buyer,
            tokenIdOrAmount: tokenIdOrAmount,
            tokenAddress: tokenAddress,
            price: price,
            isActive: isActive,
            tokenType: tokenType,
            feeAmount: feeAmount,
            feeToken: feeToken,
            isSwap: isSwap,
            swapTokenId: swapTokenId,
            swapTokenAddress: swapTokenAddress
        });
    }

    function hasRequiredTokens(address seller, TokenType tokenType, address tokenAddress, uint256 tokenId) internal view returns (bool) {
        if (tokenType == TokenType.ERC20) {
            return IERC20(tokenAddress).balanceOf(seller) >= tokenId;
        } else if (tokenType == TokenType.ERC721) {
            return IERC721(tokenAddress).ownerOf(tokenId) == seller;
        } else if (tokenType == TokenType.ERC1155) {
            return IERC1155(tokenAddress).balanceOf(seller, tokenId) > 0;
        } else {
            return false;
        }
    }

    function createListingERC20(
        uint256 listingId,
        address buyer,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenId,
        address swapTokenAddress
    ) external {

        require(hasRequiredTokens(msg.sender, TokenType.ERC20, tokenAddress, tokenIdOrAmount), "Seller doesn't have the required tokens");
        
        createListingCommon(
            listingId,
            msg.sender,
            buyer,
            tokenIdOrAmount,
            tokenAddress,
            price,
            true,
            TokenType.ERC20,
            feeAmount,
            feeToken,
            isSwap,
            swapTokenId,
            swapTokenAddress
        );

        listingExists[listingId] = true;
    }

    function createListingERC721(
        uint256 listingId,
        address buyer,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenId,
        address swapTokenAddress
    ) external {

        require(hasRequiredTokens(msg.sender, TokenType.ERC721, tokenAddress, tokenIdOrAmount), "Seller doesn't have the required tokens");
        
        createListingCommon(
            listingId,
            msg.sender,
            buyer,
            tokenIdOrAmount,
            tokenAddress,
            price,
            true,
            TokenType.ERC721,
            feeAmount,
            feeToken,
            isSwap,
            swapTokenId,
            swapTokenAddress
        );
    }

    function createListingERC1155(
        uint256 listingId,
        address buyer,
        uint256 tokenIdOrAmount,
        address tokenAddress,
        uint256 price,
        uint256 feeAmount,
        address feeToken,
        bool isSwap,
        uint256 swapTokenId,
        address swapTokenAddress
    ) external {

        require(hasRequiredTokens(msg.sender, TokenType.ERC1155, tokenAddress, tokenIdOrAmount), "Seller doesn't have the required tokens");
        
        createListingCommon(
            listingId,
            msg.sender,
            buyer,
            tokenIdOrAmount,
            tokenAddress,
            price,
            true,
            TokenType.ERC1155,
            feeAmount,
            feeToken,
            isSwap,
            swapTokenId,
            swapTokenAddress
        );
    }
    /*
    function cancelListing(uint256 listingId) external onlySeller(listingId) isActiveListing(listingId) {
        Listing storage listing = listings[listingId];
        listing.isActive = false;

        if (listing.tokenType == TokenType.ERC721) {
            IERC721(listing.tokenAddress).safeTransferFrom(address(this), msg.sender, listing.tokenId);
        } else if (listing.tokenType == TokenType.ERC1155) {
            IERC1155(listing.tokenAddress).safeTransferFrom(address(this), msg.sender, listing.tokenId, 1, "");
        } else if (listing.tokenType == TokenType.ERC20) {
            IERC20(listing.tokenAddress).transfer(msg.sender, listing.tokenId);
        }

        if (listing.isSwap) {
            if (listing.tokenType == TokenType.ERC721) {
                IERC721(listing.swapTokenAddress).safeTransferFrom(address(this), msg.sender, listing.swapTokenId);
            } else if (listing.tokenType == TokenType.ERC1155) {
                IERC1155(listing.swapTokenAddress).safeTransferFrom(address(this), msg.sender, listing.swapTokenId, 1, "");
            } else if (listing.tokenType == TokenType.ERC20) {
                IERC20(listing.swapTokenAddress).transfer(msg.sender, listing.swapTokenId);
            }
        }
    }
    */

    function buyListing(uint256 listingId) external payable isActiveListing(listingId) {
        
        Listing storage listing = listings[listingId];
        require(listing.isSwap == false, "This listing is not for a buy");
        require(msg.sender != listing.seller, "You cannot buy your own listing");
        require(msg.sender == listing.buyer, "You are not the specified buyer");

        uint256 totalPrice = listing.price;
        uint256 fee = 0;
        
        if (listing.tokenType == TokenType.ERC721) {
            IERC721(listing.tokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount);
        } else if (listing.tokenType == TokenType.ERC1155) {
            IERC1155(listing.tokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount, 1, "");
        } else if (listing.tokenType == TokenType.ERC20) {
            IERC20(listing.tokenAddress).transferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount);
        } else {
            require(msg.value >= totalPrice, "Insufficient funds");
            fee = (totalPrice * listing.feeAmount) / 100;
            payable(listing.seller).transfer(totalPrice - fee);
        }
        
        //if(checkDefinedTokenType(listing.tokenType)){}
        if (fee > 0) {
            IERC20(listing.feeToken).transfer(listing.seller, fee);
        }
        
        listing.isActive = false;
    }

    function confirmSwap(uint256 listingId) external isActiveListing(listingId) {
        Listing storage listing = listings[listingId];
        require(listing.isSwap, "This listing is not for a swap");
        
        require(msg.sender != listing.seller, "You cannot buy your own listing");
        require(msg.sender == listing.buyer, "You are not the specified buyer");


        if (listing.tokenType == TokenType.ERC721) {
            require(IERC721(listing.tokenAddress).ownerOf(listing.tokenIdOrAmount) == msg.sender, "You don't own the specified ERC721 token");
            IERC721(listing.swapTokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.swapTokenId);
            IERC721(listing.tokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount);
        } else if (listing.tokenType == TokenType.ERC1155) {
            require(IERC1155(listing.tokenAddress).balanceOf(msg.sender, listing.tokenIdOrAmount) > 0, "You don't own the specified ERC1155 token");
            IERC1155(listing.swapTokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.swapTokenId, 1, "");
            IERC1155(listing.tokenAddress).safeTransferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount, 1, "");
        } else if (listing.tokenType == TokenType.ERC20) {
            require(IERC20(listing.tokenAddress).balanceOf(msg.sender) >= listing.tokenIdOrAmount, "You don't have enough ERC20 tokens");
            IERC20(listing.swapTokenAddress).transferFrom(listing.seller, msg.sender, listing.swapTokenId);
            IERC20(listing.tokenAddress).transferFrom(listing.seller, msg.sender, listing.tokenIdOrAmount);
        }
        
        listing.isActive = false;
    }

    // Function to get listing details
    function getListingDetails(uint256 listingId) external view returns (Listing memory) {
        return listings[listingId];
    }
}
