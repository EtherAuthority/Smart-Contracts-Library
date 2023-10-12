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
        uint founderVoteInFavor;
        uint founderVoteAgainst;
        uint sbtVoteInFavor;
        uint sbtVoteAgainst;
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



    function initialize(address _sbtAddress, address _tokenAddress, uint _requiredSBTPercent, uint _requiredFounderPercent, uint _requiredRescuePercent) public {
        require(msg.sender == owner, "invalid caller");
        require(sbtAddress == address(0), "can't call twice");
        sbtAddress = _sbtAddress;
        tokenAddress = _tokenAddress;
        requiredRescuePercent = _requiredRescuePercent;
        requiredFounderPercent = _requiredFounderPercent;
        requiredSBTPercent = _requiredSBTPercent;
    }

    function ChangeSBTAddress(address _sbtAddress) public returns(bool) {
        require(msg.sender == owner, "invalid caller");
        sbtAddress = _sbtAddress;
        return true;
    }

    function ChangeTokenAddress(address _tokenAddress) public returns(bool) {
        require(msg.sender == owner, "invalid caller");
        tokenAddress = _tokenAddress;
        return true;
    }


     function ChangeRequiredFounderPercent(uint _requiredFounderPercent) public returns(bool) {
        require(msg.sender == owner, "invalid caller");
        requiredFounderPercent = _requiredFounderPercent;
        return true;
    }   

     function ChangeRequiredSBTPercent(uint _requiredSBTPercent) public returns(bool) {
        require(msg.sender == owner, "invalid caller");
        requiredSBTPercent = _requiredSBTPercent;
        return true;
    }  

    function MakeFounder(address _founder) public returns(bool) {
        require(msg.sender == owner, "invalid caller");
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

    function RecordMyVote(uint _voterId, uint _proposalIndex, bool _favor) public returns(bool){
        if(founder[msg.sender]) FounderVoteOnProposal(_proposalIndex, _favor);
        else if(contractInterface(sbtAddress).hasSoul(msg.sender,_voterId)) SbtVoteOnProposal(_proposalIndex, _favor);
        else  revert();
        return true;
    }


    function SbtVoteOnProposal(uint _proposalIndex, bool _favor) internal returns(bool) {
        uint ot = Proposals[_proposalIndex].voteOpeningTime;
        require( ot < block.timestamp , "voting not started yet");
        require( ot + Proposals[_proposalIndex].votingPeriodInSeconds > block.timestamp , "voting time is over");

        if (_favor == false) {
            Proposals[_proposalIndex].sbtVoteAgainst++;
        }
        else {
            Proposals[_proposalIndex].sbtVoteInFavor++;
        }

        return true;
    } 


    function FounderVoteOnProposal(uint _proposalIndex, bool _favor) internal returns(bool) {
        uint ot = Proposals[_proposalIndex].voteOpeningTime;
        require( ot < block.timestamp , "voting not started yet");
        require( ot + Proposals[_proposalIndex].votingPeriodInSeconds > block.timestamp , "voting time is over");

        if (_favor == false) {
            Proposals[_proposalIndex].founderVoteAgainst++;
        }
        else {
            Proposals[_proposalIndex].founderVoteInFavor++;
        }
        return true;
    } 

    function IsVotePassed(uint _proposalIndex) public view returns(bool) {
        uint totalSBT = contractInterface(sbtAddress)._nextTokenId() - 1;
        uint vf = Proposals[_proposalIndex].sbtVoteInFavor;
        uint va = Proposals[_proposalIndex].sbtVoteAgainst;
        uint voteDifference;
        if (va > vf ) return false;
        else voteDifference = vf - va;
        uint countPercent = voteDifference * 100 / totalSBT;

        vf = Proposals[_proposalIndex].founderVoteInFavor;
        va = Proposals[_proposalIndex].founderVoteAgainst;
        if (va > vf ) return false;
        else voteDifference = vf - va;
        uint countPercent2 = voteDifference * 100 / totalFounders;
        if (countPercent >= requiredSBTPercent && countPercent2 >= requiredFounderPercent ) return true;
        else if(countPercent2 > requiredRescuePercent) return true;
        return false;
    }

    function ReleaseToken(uint _proposalIndex) public returns(bool) {
        require(IsVotePassed(_proposalIndex), "proposal index not passed");
        require(!Proposals[_proposalIndex].released, "proposal index not passed");
        uint amount = Proposals[_proposalIndex].totalTokenToRelease;
        address receiver = Proposals[_proposalIndex].tokenHolder;
        Proposals[_proposalIndex].released = true;
        contractInterface(tokenAddress).mint(receiver,amount);
        return true;
    }


}
