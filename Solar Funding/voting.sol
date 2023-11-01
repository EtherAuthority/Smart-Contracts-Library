// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title Contract Interface
/// @dev This interface defines the functions for interacting with the contract.
interface contractInterface {
    /// @notice Check if a token holder has a soul.
    /// @param _tokenHolder The address of the token holder.
    /// @return Whether the token holder has a soul.
    function hasSoul(address _tokenHolder) external view returns (bool);

    /// @notice Get the next token ID.
    /// @return The next token ID.
    function _nextTokenId() external view returns (uint);

    /// @notice Mint a specified amount of tokens to an address.
    /// @param to The recipient address.
    /// @param amount The amount of tokens to mint.
    /// @return Whether the minting was successful.
    function mint(address to, uint256 amount) external returns (bool);
}

/// @title Owned Contract
/// @dev This contract provides ownership management functionality.
contract owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    /// @dev Initializes the owner as the deployer of the contract.
    constructor() {
        owner = msg.sender;
    }

    /// @dev Modifier that allows only the owner to execute a function.
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /// @notice Transfer ownership to a new address.
    /// @param _newOwner The address to transfer ownership to.
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    /// @notice Accept the pending ownership transfer.
    function acceptOwnership() public {
        require(msg.sender == newOwner, "Only the new owner can accept ownership");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

/// @title VotingForSolar
/// @dev A smart contract for voting on solar-related proposals, with ownership management.

contract VotingForSolar is owned {
    mapping(address => bool) public founder;
    uint public totalFounders;

    struct Proposal {
        address tokenHolder;
        uint powerInMW;
        uint totalTokenToRelease;
        uint founderVoteCount;
        uint sbtVoteCount;
        uint voteOpeningTime;
        uint votingPeriodInSeconds;
        bool released;
    }

    /// @dev An array of proposals.
    Proposal[] public Proposals;

    uint public requiredSBTPercent;
    uint public requiredFounderPercent;
    uint public requiredRescuePercent;

    address public sbtAddress;
    address public tokenAddress;
    mapping(address => mapping(uint => bool)) voted;

    /// @notice all required events
    event SBTAddressChangedEv(address _sbtAddress);
    event tokenAddressChangedEv(address _tokenAddress);
    event founderVotepercentChanged(uint _requiredFounderPercent);
    event SBTPercentChangedEv(uint _requiredSBTPercent);
    event founderMadeEv(address _founder);
    event proposalPostedEv(address _founder,uint _powerInMW,uint _totalTokenToRelease,address _tokenHolder,uint _voteOpeningTime,uint _votingPeriodInSeconds,uint _proposalIndex);
    event founderVoteRecordedEv(uint _proposalIndex,address _voter);
    event sbtVoteRecorded(uint _proposalIndex,address _voter);

    /// @notice Initialize the contract with required parameters.
    /// @param _sbtAddress The address of the SBT (Solar Token) contract.
    /// @param _tokenAddress The address of the token contract.
    /// @param _requiredSBTPercent The required percentage of SBT tokens for voting.
    /// @param _requiredFounderPercent The required percentage of founder votes for proposal approval.
    /// @param _requiredRescuePercent The required percentage of rescue votes for proposal approval.
    function initialize(address _sbtAddress, address _tokenAddress, uint _requiredSBTPercent, uint _requiredFounderPercent, uint _requiredRescuePercent) public onlyOwner {
        require(sbtAddress == address(0), "Initialization can only occur once");
        sbtAddress = _sbtAddress;
        tokenAddress = _tokenAddress;
        requiredRescuePercent = _requiredRescuePercent;
        requiredFounderPercent = _requiredFounderPercent;
        requiredSBTPercent = _requiredSBTPercent;
    }

    /// @notice Change the address of the SBT contract.
    /// @param _sbtAddress The new SBT contract address.
    /// @return Whether the change was successful.
    function ChangeSBTAddress(address _sbtAddress) public onlyOwner returns(bool) {
        sbtAddress = _sbtAddress;
        emit SBTAddressChangedEv(_sbtAddress);
        return true;
    }

    /// @notice Change the address of the token contract.
    /// @param _tokenAddress The new token contract address.
    /// @return Whether the change was successful.
    function ChangeTokenAddress(address _tokenAddress) public onlyOwner returns(bool) {
        tokenAddress = _tokenAddress;
        emit tokenAddressChangedEv(_tokenAddress);
        return true;
    }

    /// @notice Change the required percentage of founder votes for proposal approval.
    /// @param _requiredFounderPercent The new required founder vote percentage.
    /// @return Whether the change was successful.
    function ChangeRequiredFounderPercent(uint _requiredFounderPercent) public onlyOwner returns(bool) {
        requiredFounderPercent = _requiredFounderPercent;
        emit founderVotepercentChanged(_requiredFounderPercent);
        return true;
    }

    /// @notice Change the required percentage of SBT tokens for voting.
    /// @param _requiredSBTPercent The new required SBT vote percentage.
    /// @return Whether the change was successful.
    function ChangeRequiredSBTPercent(uint _requiredSBTPercent) public onlyOwner returns(bool) {
        requiredSBTPercent = _requiredSBTPercent;
        emit SBTPercentChangedEv(_requiredSBTPercent);
        return true;
    }

    /// @notice Make an address a founder.
    /// @param _founder The address to be granted founder status.
    /// @return Whether the address was successfully made a founder.
    function MakeFounder(address _founder) public onlyOwner returns(bool) {
        require(founder[_founder] == false, "Address is already a founder");
        founder[_founder] = true;
        totalFounders++;
        emit founderMadeEv(_founder);
        return true;
    }

/// @notice Post a new proposal to be voted on.
/// @param _powerInMW The power in megawatts for the proposal.
/// @param _totalTokenToRelease The total number of tokens to release for the proposal.
/// @param _tokenHolder The address of the token holder for the proposal.
/// @param _voteOpeningTime The opening time for voting on the proposal (in seconds since the Unix epoch).
/// @param _votingPeriodInSeconds The duration of the voting period in seconds.
/// @return The index of the newly posted proposal.
function PostProposal(uint _powerInMW, uint _totalTokenToRelease, address _tokenHolder, uint _voteOpeningTime, uint _votingPeriodInSeconds) public returns(bool) {
    require(founder[msg.sender], "Only founders can post proposals");
    require(_voteOpeningTime > block.timestamp, "Opening time can't be in the past");
    Proposal memory temp;
    temp.powerInMW = _powerInMW;
    temp.tokenHolder = _tokenHolder;
    temp.totalTokenToRelease = _totalTokenToRelease;
    temp.voteOpeningTime = _voteOpeningTime;
    temp.votingPeriodInSeconds = _votingPeriodInSeconds;

    Proposals.push(temp);
    emit proposalPostedEv(msg.sender, _powerInMW, _totalTokenToRelease, _tokenHolder, _voteOpeningTime,_votingPeriodInSeconds,Proposals.length - 1);
    return true;
}

/// @notice Record a vote on a specific proposal.
/// @param _proposalIndex The index of the proposal to vote on.
/// @return Whether the vote was recorded successfully.
function RecordMyVote(uint _proposalIndex) public returns(bool) {
    require(!voted[msg.sender][_proposalIndex], "Already voted");
    if (founder[msg.sender]) {
        FounderVoteOnProposal(_proposalIndex);
        emit founderVoteRecordedEv(_proposalIndex, msg.sender);
    } else if (contractInterface(sbtAddress).hasSoul(msg.sender)) {
        SbtVoteOnProposal(_proposalIndex);
        emit sbtVoteRecorded(_proposalIndex, msg.sender);
    } else {
        revert("Invalid voter");
    }
    return true;
}

/// @dev Handle a vote by an SBT holder on a specific proposal.
/// @param _proposalIndex The index of the proposal to vote on.
/// @return Whether the vote was recorded successfully.
function SbtVoteOnProposal(uint _proposalIndex) internal returns(bool) {
    uint ot = Proposals[_proposalIndex].voteOpeningTime;
    require(ot < block.timestamp, "Voting has not started yet");
    require(ot + Proposals[_proposalIndex].votingPeriodInSeconds > block.timestamp, "Voting time is over");
    voted[msg.sender][_proposalIndex] = true;
    Proposals[_proposalIndex].sbtVoteCount++;
    return true;
}

/// @dev Handle a vote by a founder on a specific proposal.
/// @param _proposalIndex The index of the proposal to vote on.
/// @return Whether the vote was recorded successfully.
function FounderVoteOnProposal(uint _proposalIndex) internal returns(bool) {
    uint ot = Proposals[_proposalIndex].voteOpeningTime;
    require(ot < block.timestamp, "Voting has not started yet");
    require(ot + Proposals[_proposalIndex].votingPeriodInSeconds > block.timestamp, "Voting time is over");
    voted[msg.sender][_proposalIndex] = true;
    Proposals[_proposalIndex].founderVoteCount++;
    return true;
}


/// @notice Check if a proposal has received enough votes to pass and retrieve the vote counts.
/// @param _proposalIndex The index of the proposal to check.
/// @return passed Whether the proposal has received enough votes to pass.
/// @return sbtVoteCount The number of SBT (Solar Token) votes on the proposal.
/// @return founderVoteCount The number of founder votes on the proposal.
function IsVotePassed(uint _proposalIndex) public view returns(bool passed, uint sbtVoteCount, uint founderVoteCount) {
    uint totalSBT = contractInterface(sbtAddress)._nextTokenId();
    uint sVc = Proposals[_proposalIndex].sbtVoteCount;
    uint fVc = Proposals[_proposalIndex].founderVoteCount;
    uint countPercent = sVc * 100 / totalSBT;
    uint countPercent2 = fVc * 100 / totalFounders;
    if (countPercent >= requiredSBTPercent && countPercent2 >= requiredFounderPercent) {
        return (true, sVc, fVc);
    } else if (countPercent2 > requiredRescuePercent) {
        return (true, sVc, fVc);
    }
    return (false, sVc, fVc);
}


/// @notice Release tokens for a passed proposal to the specified recipient.
/// @param _proposalIndex The index of the proposal to release tokens for.
/// @return Whether the tokens were successfully released.
function ReleaseToken(uint _proposalIndex) public returns(bool) {
    bool passed;
    (passed,,) = IsVotePassed(_proposalIndex);
    require(passed, "Proposal index not passed");
    require(!Proposals[_proposalIndex].released, "Proposal index already released");
    uint amount = Proposals[_proposalIndex].totalTokenToRelease;
    address receiver = Proposals[_proposalIndex].tokenHolder;
    Proposals[_proposalIndex].released = true;
    contractInterface(tokenAddress).mint(receiver, amount);
    return true;
}

/// @notice View the current timestamp (block timestamp).
/// @return The current timestamp in seconds since the Unix epoch.
function viewCurrentTime() public view returns(uint) {
    return block.timestamp;
}


}
