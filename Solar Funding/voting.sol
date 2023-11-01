// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;



interface contractInterface{
    function hasSoul(address _tokenHolder, uint _tokenId) external view returns (bool);
    function _nextTokenId() external view returns(uint);
    function mint(address to, uint256 amount) external returns(bool); 
}

contract owned {
    address  public owner;
    address  public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address  _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract VotingForSolar is owned {

    mapping (address => bool) public founder;
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

    Proposal[] public Proposals;

    uint public requiredSBTPercent;
    uint public requiredFounderPercent;
    uint public requiredRescuePercent;

    address public sbtAddress;
    address public tokenAddress;
    mapping(address => mapping(uint => bool)) voted;



    function initialize(address _sbtAddress, address _tokenAddress, uint _requiredSBTPercent, uint _requiredFounderPercent, uint _requiredRescuePercent) public onlyOwner
{
        require(sbtAddress == address(0), "can't call twice");
        sbtAddress = _sbtAddress;
        tokenAddress = _tokenAddress;
        requiredRescuePercent = _requiredRescuePercent;
        requiredFounderPercent = _requiredFounderPercent;
        requiredSBTPercent = _requiredSBTPercent;
    }

    function ChangeSBTAddress(address _sbtAddress) public onlyOwner returns(bool) {
        sbtAddress = _sbtAddress;
        return true;
    }

    function ChangeTokenAddress(address _tokenAddress) public onlyOwner returns(bool) {
        tokenAddress = _tokenAddress;
        return true;
    }


     function ChangeRequiredFounderPercent(uint _requiredFounderPercent) public onlyOwner returns(bool) {
        requiredFounderPercent = _requiredFounderPercent;
        return true;
    }   

     function ChangeRequiredSBTPercent(uint _requiredSBTPercent) public onlyOwner returns(bool) {
        requiredSBTPercent = _requiredSBTPercent;
        return true;
    }  

    function MakeFounder(address _founder) public onlyOwner returns(bool) {
        require(founder[_founder] == false, "Already Founder");
        founder[_founder] = true;
        totalFounders++;
        return true;
    }

    function PostProposal(uint _powerInMW, uint _totalTokenToRelease, address _tokenHolder, uint _voteOpeningTime, uint _votingPeriodInSeconds) public returns(uint) {
        require(founder[msg.sender], "invalid caller");
        require(_voteOpeningTime > block.timestamp,"opening time can't be in past");
        Proposal memory temp;
        temp.powerInMW = _powerInMW;
        temp.tokenHolder = _tokenHolder;
        temp.totalTokenToRelease = _totalTokenToRelease;
        temp.voteOpeningTime = _voteOpeningTime;
        temp.votingPeriodInSeconds = _votingPeriodInSeconds;

        Proposals.push(temp);
        
        return Proposals.length - 1;
    }

    function RecordMyVote(uint _voterId, uint _proposalIndex) public returns(bool){
        require(!voted[msg.sender][_proposalIndex], "already voted");
        if(founder[msg.sender]) FounderVoteOnProposal(_proposalIndex);
        else if(contractInterface(sbtAddress).hasSoul(msg.sender,_voterId)) SbtVoteOnProposal(_proposalIndex);
        else  revert();
        return true;
    }


    function SbtVoteOnProposal(uint _proposalIndex) internal returns(bool) {
        uint ot = Proposals[_proposalIndex].voteOpeningTime;
        require( ot < block.timestamp , "voting not started yet");
        require( ot + Proposals[_proposalIndex].votingPeriodInSeconds > block.timestamp , "voting time is over");
        voted[msg.sender][_proposalIndex]  =  true;
        Proposals[_proposalIndex].sbtVoteCount++;
        return true;
    } 


    function FounderVoteOnProposal(uint _proposalIndex) internal returns(bool) {
        uint ot = Proposals[_proposalIndex].voteOpeningTime;
        require( ot < block.timestamp , "voting not started yet");
        require( ot + Proposals[_proposalIndex].votingPeriodInSeconds > block.timestamp , "voting time is over");
        voted[msg.sender][_proposalIndex]  =  true;
        Proposals[_proposalIndex].founderVoteCount++;
        return true;
    } 

    function IsVotePassed(uint _proposalIndex) public view returns(bool) {
        uint totalSBT = contractInterface(sbtAddress)._nextTokenId();
        uint sVc = Proposals[_proposalIndex].sbtVoteCount;
        uint fVc = Proposals[_proposalIndex].founderVoteCount;
        uint countPercent = sVc * 100 / totalSBT;
        uint countPercent2 = fVc * 100 / totalFounders;
        if (countPercent >= requiredSBTPercent && countPercent2 >= requiredFounderPercent ) return true;
        else if(countPercent2 > requiredRescuePercent) return true;
        return false;
    }

    function ReleaseToken(uint _proposalIndex) public returns(bool) {
        require(IsVotePassed(_proposalIndex), "proposal index not passed");
        require(!Proposals[_proposalIndex].released, "proposal index already released");
        uint amount = Proposals[_proposalIndex].totalTokenToRelease;
        address receiver = Proposals[_proposalIndex].tokenHolder;
        Proposals[_proposalIndex].released = true;
        contractInterface(tokenAddress).mint(receiver,amount);
        return true;
    }

    function viewCurrentTime() public view returns(uint) {
        return block.timestamp;
    }

}
