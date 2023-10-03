// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {

    mapping(uint256 => Listing) public listings;
    address payable public immutable owner;
    uint256 public minAmount = 1000 wei;
    uint256 public maxMarketplaceFee = 100; // 1% fee

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Define an event
    event PaymentProcessed(uint256 indexed listingID, address indexed buyer, address indexed seller, uint256 amount);
    event ListingCreated(
        uint256 indexed listingID,
        address indexed sellerAddress,
        address marketplaceAddress,
        uint256 amount,
        string currency,
        uint256 marketplaceFee
    );
    event listingInitialized(uint256 indexed listingID);
    event listingStatusSet(uint256 indexed listingID, bool status);
    event listingRemoved(uint256 indexed listingID);
    event marketplaceFeeSet(uint256 indexed listingID, uint256 newFee);

    struct Listing {
        uint256 listingID;
        address ownerof;
        address payable sellerAddress;
        address payable buyerAddress;
        address marketplaceAddress;
        uint256 amount;
        string currency;
        uint256 marketplaceFee;
        bool isPayed;
        string transactionHash;
        bool initialized;
        bool isCompleted;
    }

    function createListing(
        uint256 listingID,
        address sellerAddress,
        address marketplaceAddress,
        uint256 amount,
        string memory currency,
        uint256 marketplaceFee
    ) public returns (bool) {

        require(listingID > 0, "Invalid listingID");
        require(sellerAddress != address(0), "Invalid sellerAddress");
        //require(buyerAddress != address(0), "Invalid buyerAddress");
        require(marketplaceAddress != address(0), "Invalid marketplaceAddress");
        require(amount > 0, "Invalid amount");
        require(amount >= minAmount, "Amount must be greater than or equal to the minimum amount");
        require(bytes(currency).length > 0, "Invalid currency");
        require(marketplaceFee <= maxMarketplaceFee, "Marketplace fee exceeds maximum allowed");
        require(listings[listingID].listingID != listingID, "Listing already exists");

        listings[listingID] = Listing({
            listingID: listingID,
            ownerof: msg.sender,
            sellerAddress: payable(sellerAddress),
            buyerAddress:  payable(address(0)),
            marketplaceAddress: marketplaceAddress,
            amount: amount,
            currency: currency,
            marketplaceFee: marketplaceFee,
            isPayed: false,
            transactionHash: "",
            initialized: false,
            isCompleted: false
        });

        // Emit the event
        emit ListingCreated(listingID, sellerAddress, marketplaceAddress, amount, currency, marketplaceFee);

        return true;
    }
    
    // function to initialize listing
    function initializeListing(uint256 listingID) public onlyOwner {
        Listing storage listing = listings[listingID];

        require(listing.listingID > 0, "Invalid listing ID");
        require(listing.initialized == false, "Listing already initialized");

        listing.initialized = true;
        emit listingInitialized(listingID);
    }

    // function to set the status
    function setListingStatus(uint256 listingID, bool status) public onlyOwner {
        require(listings[listingID].isCompleted = false, "Listing already completed");
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
    function paySeller(uint256 listingID, address sellerAddress, string memory currency, string memory transactionHash) public payable returns (bool) {
        Listing storage listing = listings[listingID];
        require(listing.ownerof != msg.sender, "You cannot be the buyer");
        require(listing.sellerAddress == sellerAddress, "Invalid seller address");
        require(listing.initialized == true, "Listing not initialized");
        require(listing.isCompleted == false, "Listing already completed");
        require(keccak256(abi.encodePacked(listing.currency)) == keccak256(abi.encodePacked(currency)), "Invalid currency");
        require(msg.value == listing.amount, "Incorrect amount to buy listing");

        uint256 marketplaceFee = (listing.amount * listing.marketplaceFee) / 10000; // 10000 = 100% 
        listing.sellerAddress.transfer(listing.amount - marketplaceFee);
        owner.transfer(marketplaceFee);

        listing.buyerAddress = payable(msg.sender);
        listing.ownerof = msg.sender;
        listing.isPayed = true;
        listing.isCompleted = true;
        listing.transactionHash = transactionHash;

        emit PaymentProcessed(listingID, msg.sender, listing.sellerAddress, msg.value);
        
        return true;
    }
}