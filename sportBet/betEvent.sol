// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SportsBet {
    address public playerA;
    address public playerB;
    uint256 public betAmount;
    uint256 public expirationTime;
    uint8 public outcomeA; // Player A's predicted outcome
    uint8 public outcomeB; // Player B's predicted outcome
    uint8 public actualResult; // Result declared for the bet
    address public organiser;
    uint256 public organiserFee; // Fee percentage (e.g., 5%)
    bool public isResolved;
    bool public isLocked;

    event BetCreated(address indexed playerA, address indexed playerB, uint256 amount, uint256 expirationTime);
    event BetLocked(address indexed playerA, address indexed playerB, uint256 totalLocked);
    event BetResolved(address indexed winner, uint256 winnings, uint256 fee);
    event BetRefunded(address indexed player, uint256 amount);

    constructor(
        address _playerA,
        address _playerB,
        uint8 _outcomeA,
        uint8 _outcomeB,
        uint256 _betAmount,
        uint256 _expirationTime,
        address _organiser,
        uint256 _organiserFee
    ) {
        require(_playerA != _playerB, "Players must be different");
        require(_betAmount > 0, "Bet amount must be greater than zero");
        require(block.timestamp < _expirationTime, "Expiration time must be in the future");

        playerA = _playerA;
        playerB = _playerB;
        outcomeA = _outcomeA;
        outcomeB = _outcomeB;
        betAmount = _betAmount;
        expirationTime = _expirationTime;
        organiser = _organiser;
        organiserFee = _organiserFee;

        emit BetCreated(playerA, playerB, betAmount, expirationTime);
    }

    // Lock funds for both players
    function lockBet() external payable {
        require(!isLocked, "Bet is already locked");
        require(msg.sender == playerA || msg.sender == playerB, "Only players can lock funds");
        require(msg.value == betAmount, "Incorrect bet amount");

        if (msg.sender == playerA) {
            require(address(this).balance == betAmount, "Player A's funds not fully locked");
        } else if (msg.sender == playerB) {
            require(address(this).balance == 2 * betAmount, "Player B's funds not fully locked");
        }

        if (address(this).balance == 2 * betAmount) {
            isLocked = true;
            emit BetLocked(playerA, playerB, address(this).balance);
        }
    }

    // Resolve the bet by declaring the winner
    function resolveBet(uint8 _actualResult) external {
        require(msg.sender == organiser, "Only organiser can resolve the bet");
        require(isLocked, "Bet is not locked yet");
        require(!isResolved, "Bet is already resolved");
        require(block.timestamp <= expirationTime, "Bet has expired");

        actualResult = _actualResult;
        isResolved = true;

        address winner;
        if (actualResult == outcomeA) {
            winner = playerA;
        } else if (actualResult == outcomeB) {
            winner = playerB;
        } else {
            revert("No winner determined");
        }

        // Calculate winnings and organiser fee
        uint256 totalAmount = address(this).balance;
        uint256 fee = (totalAmount * organiserFee) / 100;
        uint256 winnings = totalAmount - fee;

        // Transfer funds
        payable(winner).transfer(winnings);
        payable(organiser).transfer(fee);

        emit BetResolved(winner, winnings, fee);
    }

    // Refund bet if expired without resolution
    function refundBet() external {
        require(block.timestamp > expirationTime, "Bet has not expired yet");
        require(!isResolved, "Bet is already resolved");
        require(msg.sender == playerA || msg.sender == playerB, "Only players can claim refunds");

        uint256 refundAmount = betAmount;
        if (msg.sender == playerA || msg.sender == playerB) {
            payable(msg.sender).transfer(refundAmount);
            emit BetRefunded(msg.sender, refundAmount);
        }
    }
}

