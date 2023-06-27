// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract VRFv2DirectFundingConsumer is VRFV2WrapperConsumerBase, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);

    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) internal s_requests;
    uint256[] public requestIds;
    uint256 private lastRequestId;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    address linkAddress = 0xb0897686c545045aFc77CF20eC7A532E3120E0F1; // Address LINK - hardcoded for Mumbai (make updatable)
    address wrapperAddress = 0x4e42f0adEB69203ef7AaA4B7c414e5b1331c14dc; // address WRAPPER - hardcoded for Mumbai (make updatable)

    constructor()
        ConfirmedOwner(msg.sender)
        VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {}

    function requestRandomWords() external returns (uint256 requestId) {
        requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].paid > 0, "Request doesn't exist. Please try again.");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords, s_requests[_requestId].paid);
    }

    function getRandomWordByRequestId(uint256 _requestId) public view returns (uint256[] memory) {
        return s_requests[_requestId].randomWords;
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (
            uint256 paid,
            bool fulfilled,
            uint256[] memory randomWords
        )
    {
        require(s_requests[_requestId].paid > 0, "Request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    function withdrawLink() external onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function checkLinkBalance() external view onlyOwner returns (uint256) {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        return link.balanceOf(address(this));
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

interface IVRFv2DirectFundingConsumer {
    function requestRandomWords() external returns (uint256 requestId);
    function getRequestStatus(uint256 _requestId) external view returns (uint256 paid, bool fulfilled);
    function getRandomWordByRequestId(uint256 _requestId) external view returns (uint256[] memory);
}

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CustomNFT is ReentrancyGuard {
    struct NFT {
        uint256 nftNumber;
        uint256 timestamp;
        bool paidOrFree;
    }

    struct NFTInfo {
        address nftOwner;
        uint256 timestamp;
        bool paidOrFree;
    }

    struct WinnerDetails {
        uint256 randomWord;
        uint256 winningNftNumber;
        address winningWallet;
        bytes32 claimPrizeTransferHash;
        bool prizeClaimed;
    }

    address payable public raffleOrganizer;
    address internal factoryAddress;

    uint256 public NFTprice;
    uint256 public maxNFTSupply;
    uint256 public freeMintLimit;
    uint256 public freeNFTsClaimed;
    uint256 public nftsMinted;

    mapping(address => NFT[]) internal nftsOwned;
    mapping(uint256 => address) internal nftOwners;
    mapping(uint256 => bool) private nftExists;
    mapping(address => bool) private isUniqueOwner;
    mapping(uint256 => NFT) internal nfts;
    mapping(address => WinnerDetails) private winners;

    address[] private uniqueOwners;
    uint256[] internal nftNumbers;
    uint256 public prizeAmount;
    uint256 public drawTimeLimit;
    uint256 public requestId;
    IVRFv2DirectFundingConsumer public vrfConsumer;

    bool private randomnessRequested;

    constructor(
        address payable _raffleOrganizer,
        address _factoryAddress,
        uint256 _NFTprice,
        uint256 _maxNFTSupply,
        uint256 _freeMintLimit,
        uint256 _prizeAmount,
        uint256 _drawTimeLimit
    ) {
        raffleOrganizer = _raffleOrganizer;
        factoryAddress = _factoryAddress;
        NFTprice = _NFTprice;
        maxNFTSupply = _maxNFTSupply;
        freeMintLimit = _freeMintLimit;
        freeNFTsClaimed = 0;
        nftsMinted = 0;
        prizeAmount = _prizeAmount;
        vrfConsumer = IVRFv2DirectFundingConsumer(0x9f1946fc9063995D2BbfB4CD91FE968f5ea9457e); // VRF consumer contract address
        drawTimeLimit = _drawTimeLimit; // Initialize drawTimeLimit variable
    }

    modifier onlyRaffleOrganizer() {
        require(
            msg.sender == raffleOrganizer,
            "This function is reserved for the Raffle Organizer."
        );
        _;
    }

    function mint(address to, bool paid) private {
        nftsMinted++;

        NFT memory newNft = NFT(nftsMinted, block.timestamp, paid);
        nftsOwned[to].push(newNft);
        nftOwners[newNft.nftNumber] = to;
        nftExists[newNft.nftNumber] = true;

        nfts[newNft.nftNumber] = newNft;

        nftNumbers.push(newNft.nftNumber);

        if (!isUniqueOwner[to]) {
            isUniqueOwner[to] = true;
            uniqueOwners.push(to);
        }

        if (nftsMinted >= maxNFTSupply) {
            requestRandomness();
        }
    }

    function mintNFT(uint256 amount) public payable nonReentrant {
        require(
            !randomnessRequested,
            "Raffle has already been drawn. Use the getWinner function to see winning ticket number."
        );
        require(
            amount <= 25,
            "You may not buy more than 25 NFTs at once"
        );
        require(
            nftsMinted + amount <= maxNFTSupply,
            "Tickets for this raffle are now sold out."
        );
        uint256 totalCost = NFTprice * amount;
        require(
            msg.value >= totalCost,
            "Your payment amount was too low. Please check your wallet balance and try again."
        );

        for (uint256 i = 0; i < amount; i++) {
            mint(msg.sender, true);
        }
        if (msg.value > totalCost) {
            uint256 overPaymentAmount = msg.value - totalCost;
            payable(msg.sender).transfer(overPaymentAmount);
        }
    }

    function freeMintTo(address to) public onlyRaffleOrganizer nonReentrant {
        require(
            !randomnessRequested,
            "This raffle has now concluded."
        );
        require(
            freeNFTsClaimed < freeMintLimit,
            "Free mint limit has been reached."
        );

        freeNFTsClaimed++;

        mint(to, false);
    }

    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";

        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return string(s);
    }

    function getNFTInfo(uint256 nftNumber) public view returns (string memory, string memory, string memory) {
        require(nftExists[nftNumber], "NFT does not exist");

        string memory nftOwner = _toAsciiString(nftOwners[nftNumber]);
        string memory timestamp = uintToString(nfts[nftNumber].timestamp);
        string memory paid = nfts[nftNumber].paidOrFree ? "paid" : "free";

        return (nftOwner, timestamp, paid);
    }

    function ticketsOwned(uint256 startIndex) public view returns (uint256[] memory) {
        require(nftsOwned[msg.sender].length > startIndex, "Start index is out of range.");

        uint256 count = nftsOwned[msg.sender].length - startIndex;
        if (count > 50) {
            count = 50;
        }

        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = nftsOwned[msg.sender][startIndex + i].nftNumber;
        }

        return result;
    }

    function getAllNFTOwners(uint256 page) public view returns (string memory) {
        require(page > 0, "Page number must be greater than 0");
        uint256 start = (page - 1) * 50;
        require(start < uniqueOwners.length, "Page number doesn't exist. Try a lower page number.");

        string memory ownersList = "";
        for (uint256 i = 0; i < 50; i++) {
            if (start + i >= uniqueOwners.length) {
                break;
            }
            ownersList = string(abi.encodePacked(ownersList, _toAsciiString(uniqueOwners[start + i]), ","));
        }

        return ownersList;
    }

    function _toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(abi.encodePacked("0x", s));
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function freeNFTsRemaining() public view returns (uint256) {
        if (freeNFTsClaimed >= freeMintLimit) {
            return 0;
        }
        return freeMintLimit - freeNFTsClaimed;
    }

    function NFTsRemaining() public view returns (uint256) {
        if (nftsMinted >= maxNFTSupply) {
            return 0;
        }
        return maxNFTSupply - nftsMinted;
    }

    function requestRandomness() public {
        require(block.timestamp > drawTimeLimit  || nftsMinted >= maxNFTSupply, "Raffle can't be manually drawn until after the time limit is reached");
        require(!randomnessRequested, "Randomness already requested. Use the getWinner function to view the winning ticket number.");
    
        requestId = vrfConsumer.requestRandomWords();
        randomnessRequested = true;
    }

    function checkRandomWord() public view returns (uint256[] memory) {
        return vrfConsumer.getRandomWordByRequestId(requestId);
    }

    function getWinner() public view returns (uint256) {
        uint256[] memory randomWords = checkRandomWord();
        require(randomWords.length > 0, "Random words is empty");

        uint256 winner = randomWords[0] % nftsMinted + 1;

        return winner;
    }

    function isWinner() public view returns (bool) {
        uint256 winner = getWinner();
        address winnerAddress = nftOwners[winner];
        
        return winnerAddress == msg.sender;
    }

    function claimPrize() public nonReentrant {
        require(isWinner(), "You didn't win this time.");

        WinnerDetails storage winner = winners[msg.sender];

        require(
            !winner.prizeClaimed,
            "Prize has already been successfully claimed."
        );

        uint256 prize =
            prizeAmount <= address(this).balance
                ? prizeAmount
                : address(this).balance;

        winner.randomWord = checkRandomWord()[0];
        winner.winningNftNumber = getWinner();
        winner.winningWallet = msg.sender;
        winner.claimPrizeTransferHash = keccak256(
            abi.encodePacked(msg.sender, block.timestamp, prize)
        );
        winner.prizeClaimed = true;

        (bool success, ) = payable(msg.sender).call{value: prize}("");
        require(success, "Transfer failed.");
    }

    function checkWinnerDetails() public view returns (WinnerDetails memory) {
        return winners[msg.sender];
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

contract TicketsFactory {
    struct NftRaffleData {
        address raffleContractAddress;
        uint256 nftPrice;
        uint256 maxSupply;
        uint256 freeMintLimit;
        uint256 prizeAmount;
        uint256 timeLimit;
        address owner;
    }

    mapping(uint256 => NftRaffleData) public raffleDataByIndex;
    uint256 public rafflesCount = 0;

    Verification private verificationContract;

    constructor(address _verificationContractAddress) {
        verificationContract = Verification(_verificationContractAddress);
    }

    function createCustomNFT(
        uint256 _NFTprice,
        uint256 _maxNFTSupply,
        uint256 _freeMintLimit,
        uint256 _prizeAmount,
        uint256 _drawTimeLimit
        
        ) public payable 
        {
        require(msg.value >= 1000000 wei, "Insufficient payment, you must pay 1000000 wei to deploy a raffle.");
        uint256 overpayment = msg.value - 1000000 wei;

        if (overpayment > 0) {
            payable(msg.sender).transfer(overpayment);
        }

        require(verificationContract.isVerifiedAddress(address(this)), "The deployer you are using is cloned may not be safe. Please use the genuine deployer at rafflemint.io");

        CustomNFT newCustomNFT = new CustomNFT(
            payable(msg.sender),
            address(this),
            _NFTprice,
            _maxNFTSupply,
            _freeMintLimit,
            _prizeAmount,
            _drawTimeLimit
        );

        verificationContract.addGenuineRaffleContract(address(newCustomNFT));

        NftRaffleData memory newRaffleData = NftRaffleData({
            raffleContractAddress: address(newCustomNFT),
            nftPrice: _NFTprice,
            maxSupply: _maxNFTSupply,
            freeMintLimit: _freeMintLimit,
            prizeAmount: _prizeAmount,
            timeLimit: _drawTimeLimit,
            owner: msg.sender
        });

        raffleDataByIndex[rafflesCount] = newRaffleData;
        rafflesCount++;
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

contract Verification {
    address private owner;
    address private verificationAddress;
    address[] private genuineRaffleContracts;

    modifier onlyOwner {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyVerificationAddress {
        require(msg.sender == verificationAddress, "Caller is not the verification address");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setVerificationAddress(address _verificationAddress) public onlyOwner {
        verificationAddress = _verificationAddress;
    }

    function addGenuineRaffleContract(address _contractAddress) public onlyVerificationAddress {
        genuineRaffleContracts.push(_contractAddress);
    }

    function isVerifiedAddress(address _address) public view returns (bool) {
        return _address == verificationAddress;
    }

    function isGenuineRaffleAddress(address _address) public view returns (bool) {
        for (uint i = 0; i < genuineRaffleContracts.length; i++) {
            if (genuineRaffleContracts[i] == _address) {
                return true;
            }
        }
        return false;
    }
}

