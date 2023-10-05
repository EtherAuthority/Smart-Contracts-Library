// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface NonERCToken {
    function transfer(address recipient, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function balanceOf(address account) external view returns (uint256);
}

contract NFTEscrow is ReentrancyGuard {
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => bool) public requiresTokens;

    address payable public immutable owner;
    uint256 public maxMarketplaceFee = 100; // 1% fee

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Define an event
    event PaymentProcessed(
        uint256 indexed listingID,
        address indexed buyer,
        address indexed seller,
        uint256 amount
    );
    event ListingCreated(
        uint256 indexed listingID,
        address indexed sellerAddress,
        address marketplaceAddress,
        uint256 amount,
        string currency,
        uint256 marketplaceFee
    );
    event listingStatusSet(uint256 indexed listingID, bool status);
    event listingRemoved(uint256 indexed listingID);
    event marketplaceFeeSet(uint256 indexed listingID, uint256 newFee);

    struct Listing {
        uint256 listingID;
        address ownerof;
        address payable sellerAddress;
        address payable buyerAddress;
        address tokenAddress;
        address marketplaceAddress;
        uint256 amount;
        string currency;
        uint256 marketplaceFee;
        bool isPayed;
        bool isCompleted;
        bool IsTokenNonErc20;
    }

    function createListing(
        uint256 listingID,
        address sellerAddress,
        address buyerAddress,
        address marketplaceAddress,
        uint256 amount,
        string memory currency,
        uint256 marketplaceFee,
        address tokenAddress,
        bool IsTokenNonErc20
    ) public returns (bool) {
        require(listingID > 0, "Invalid listingID");
        require(buyerAddress != address(0), "Invalid buyerAddress");
        require(marketplaceAddress != address(0), "Invalid marketplaceAddress");
        require(amount > 0, "Invalid amount");
        require(bytes(currency).length > 0, "Invalid currency");
        require(
            marketplaceFee <= maxMarketplaceFee,
            "Marketplace fee exceeds maximum allowed"
        );
        require(
            listings[listingID].listingID != listingID,
            "Listing already exists"
        );

        if (tokenAddress != address(0)) {
            requiresTokens[listingID] = true;
        }

        listings[listingID] = Listing({
            listingID: listingID,
            ownerof: msg.sender,
            sellerAddress: payable(sellerAddress),
            buyerAddress: payable(buyerAddress),
            marketplaceAddress: marketplaceAddress,
            amount: amount,
            currency: currency,
            marketplaceFee: marketplaceFee,
            isPayed: false,
            isCompleted: false,
            tokenAddress: tokenAddress,
            IsTokenNonErc20: IsTokenNonErc20
        });

        // Emit the event
        emit ListingCreated(
            listingID,
            sellerAddress,
            marketplaceAddress,
            amount,
            currency,
            marketplaceFee
        );

        return true;
    }

    // function to set the status
    function setListingStatus(uint256 listingID, bool status) public onlyOwner {
        require(
            listings[listingID].isCompleted = false,
            "Listing already completed"
        );
        listings[listingID].isCompleted = status;
        emit listingStatusSet(listingID, status);
    }

    // function to delete listing
    function removeListing(uint256 listingID) public onlyOwner returns (bool) {
        require(listings[listingID].listingID > 0, "Listing does not exist");
        delete listings[listingID];
        emit listingRemoved(listingID);
        return true;
    }

    // function to check whi is owner of Listing ID
    function ownerof(uint256 listingID) public view returns (address) {
        Listing storage listing = listings[listingID];
        require(listing.listingID > 0, "Invalid listing ID");
        return listing.ownerof;
    }

    // function to pay for Listnig Id from buyer to seller
    function paySeller(
        uint256 listingID,
        address sellerAddress,
        string memory currency
    ) public payable returns (bool) {
        Listing storage listing = listings[listingID];
        require(
            listing.sellerAddress == sellerAddress,
            "Invalid seller address"
        );
        require(listing.buyerAddress == msg.sender, "You are not a buyer");
        require(listing.isCompleted == false, "Listing already completed");
        require(
            keccak256(abi.encodePacked(listing.currency)) ==
                keccak256(abi.encodePacked(currency)),
            "Invalid currency"
        );

        if (requiresTokens[listingID]) {
            if (listing.IsTokenNonErc20) {
                NonERCToken token = NonERCToken(listing.tokenAddress);
                token.transferFrom(msg.sender, address(this), listing.amount);
                uint256 marketplaceFee = (listing.amount *
                    listing.marketplaceFee) / 10000;
                token.transfer(listing.marketplaceAddress, marketplaceFee);
                token.transfer(
                    listing.sellerAddress,
                    listing.amount - marketplaceFee
                );
            } else {
                // Retrieve the ERC20 token contract
                IERC20 token = IERC20(listing.tokenAddress);
                require(
                    token.transferFrom(
                        msg.sender,
                        address(this),
                        listing.amount
                    ),
                    "Token transfer failed"
                );
                uint256 marketplaceFee = (listing.amount *
                    listing.marketplaceFee) / 10000;
                require(
                    token.transfer(listing.marketplaceAddress, marketplaceFee),
                    "Token transfer failed"
                );
                require(
                    token.transfer(
                        listing.sellerAddress,
                        listing.amount - marketplaceFee
                    ),
                    "Token transfer failed"
                );
            }
        } else {
            require(
                msg.value == listing.amount,
                "Incorrect amount to buy listing"
            );
            uint256 marketplaceFee = (listing.amount * listing.marketplaceFee) /
                10000; // 10000 = 100%
            listing.sellerAddress.transfer(listing.amount - marketplaceFee);
            owner.transfer(marketplaceFee);
        }

        listing.ownerof = msg.sender;
        listing.isPayed = true;
        listing.isCompleted = true;

        emit PaymentProcessed(
            listingID,
            msg.sender,
            listing.sellerAddress,
            listing.amount
        );

        return true;
    }

    // Function to check token balance
    function getTokenBalance(
        address tokenAddress,
        address accountAddress
    ) external view returns (uint256) {
        uint256 balance = 0;
        if (isERC20Token(IERC20(tokenAddress))) {
            IERC20 token = IERC20(tokenAddress);
            balance = token.balanceOf(accountAddress);
        } else {
            NonERCToken token = NonERCToken(tokenAddress);
            balance = token.balanceOf(accountAddress);
        }
        return balance;
    }

    // Function to check coin balance
    function getCoinBalance(
        address walletAddress
    ) public view returns (uint256) {
        return walletAddress.balance;
    }

    // Function to withdraw or transfer tokens to another address
    function withdrawTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (isERC20Token(IERC20(tokenAddress))) {
            // Retrieve the ERC20 token contract
            IERC20 token = IERC20(tokenAddress);
            // Ensure the contract has enough balance
            require(
                token.balanceOf(address(this)) >= amount,
                "Insufficient balance"
            );
            // Transfer tokens to the specified address
            require(token.transfer(to, amount), "Token transfer failed");
        } else {
            // Retrieve the NON ERC20 token contract
            NonERCToken token = NonERCToken(tokenAddress);
            // Ensure the contract has enough balance
            require(
                token.balanceOf(address(this)) >= amount,
                "Insufficient balance"
            );
            token.transfer(to, amount);
        }
    }

    // Function to check if a token supports the ERC20 interface
    function isERC20Token(IERC20 token) internal view returns (bool) {
        try token.totalSupply() returns (uint256) {
            return true;
        } catch (bytes memory) {
            return false;
        }
    }
}
