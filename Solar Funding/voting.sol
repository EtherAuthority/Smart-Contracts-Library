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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/// @title VotingForSolar
/// @dev A smart contract for voting on solar-related proposals, with ownership management.

contract VotingForSolar is Ownable {
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
    event RescuePercentChangedEv(uint _requiredRescueTPercent);

    
    event founderMadeEv(address _founder);
    event proposalPostedEv(address _founder,uint _powerInMW,uint _totalTokenToRelease,address _tokenHolder,uint _voteOpeningTime,uint _votingPeriodInSeconds,uint _proposalIndex);
    event founderVoteRecordedEv(uint _proposalIndex,address _voter);
    event sbtVoteRecorded(uint _proposalIndex,address _voter);

    /// @notice Initialize the contract with required parameters.
    /// @param _sbtAddress The address of the SBT (Solar Token) contract.
    /// @param _tokenAddress The address of the token contract.
    /// @param _requiredSBTPercent The required percentage of SBT tokens for voting. In multiple of 100
    /// @param _requiredFounderPercent The required percentage of founder votes for proposal approval. In multiple of 100
    /// @param _requiredRescuePercent The required percentage of rescue votes for proposal approval.
    function initialize(address _sbtAddress, address _tokenAddress, uint _requiredSBTPercent, uint _requiredFounderPercent, uint _requiredRescuePercent) public onlyOwner {
        require(sbtAddress == address(0), "Initialization can only occur once");
        sbtAddress = _sbtAddress;
        tokenAddress = _tokenAddress;
        requiredRescuePercent = _requiredRescuePercent;     // Multiple the % amount with 100. for example, enter 6000 for 66%
        requiredFounderPercent = _requiredFounderPercent;   // Multiple the % amount with 100. for example, enter 6000 for 66%
        requiredSBTPercent = _requiredSBTPercent;           // Multiple the % amount with 100. for example, enter 6600 for 66%
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
    /// @param _requiredFounderPercent The new required founder vote percentage. Enter in multiple of 100. for example, enter 6600 for 66%
    /// @return Whether the change was successful.
    function ChangeRequiredFounderPercent(uint _requiredFounderPercent) public onlyOwner returns(bool) {
        requiredFounderPercent = _requiredFounderPercent;
        emit founderVotepercentChanged(_requiredFounderPercent);
        return true;
    }

    /// @notice Change the required percentage of SBT tokens for voting.
    /// @param _requiredSBTPercent The new required SBT vote percentage. Enter in multiple of 100. for example, enter 6600 for 66%
    /// @return Whether the change was successful.
    function ChangeRequiredSBTPercent(uint _requiredSBTPercent) public onlyOwner returns(bool) {
        requiredSBTPercent = _requiredSBTPercent;
        emit SBTPercentChangedEv(_requiredSBTPercent);
        return true;
    }


    /// @notice Change the required percentage of Rescue tokens for voting.
    /// @param _requiredRescuePercent The new required Rescue percentage. Enter in multiple of 100. for example, enter 6600 for 66%
    /// @return Whether the change was successful.
    function ChangeRequiredRescuePercent(uint _requiredRescuePercent) public onlyOwner returns(bool) {
        requiredRescuePercent = _requiredRescuePercent;
        emit RescuePercentChangedEv(_requiredRescuePercent);
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
    uint countPercent;
    uint countPercent2;
    if(totalSBT != 0){
        countPercent = sVc * 100 * 100 / totalSBT;         // percentage in decimal of 100
    }
    if(totalFounders != 0){
        countPercent2 = fVc * 100 * 100 / totalFounders;   // percentage in decimal of 100
    }
    
    
    if (countPercent >= requiredSBTPercent && countPercent2 >= requiredFounderPercent) {
        return (true, sVc, fVc);
    } else if (countPercent2 >= requiredRescuePercent) {
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
