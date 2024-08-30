// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//

// Contract to manage ownership of the contract with transfer and acceptance functionality
contract owned {
    address payable public owner;  // Current owner of the contract
    address payable internal newOwner;  // Address of the proposed new owner

    event OwnershipTransferred(address indexed _from, address indexed _to);  // Event for ownership transfer

    // Constructor sets the initial owner to the address deploying the contract
    constructor() {
        owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), owner);
    }

    // Modifier to restrict access to only the current owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Function to propose a new owner (can only be called by the current owner)
    function transferOwnership(address payable _newOwner) external onlyOwner {
        newOwner = _newOwner;
    }

    // Function for the proposed new owner to accept ownership
    function acceptOwnership() external {
        require(msg.sender == newOwner, "Not the proposed new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = payable(0);  // Clear the proposed new owner
    }
}

// Interface for ERC20 token with essential functions
interface ERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function owner() external view returns (address);
}

//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//

// Contract for a multisignature proposal and voting system
contract Multisign is owned {

    // Structure to hold proposal details
    struct _proposal {
        address user;      // Address of the user who created the proposal
        uint256 amount;    // Amount requested in the proposal
        uint256 time;      // Timestamp of when the proposal was created
        uint256 votes;     // Number of votes the proposal has received
        bool isOpen;       // Status of the proposal (open or closed)
    }

    mapping(address => bool) public user;               // Mapping to check if an address is a signer
    mapping(address => _proposal[]) public proposal;    // Mapping to store proposals for each user
    mapping(uint256 => mapping(address => bool)) public votes; // Mapping to track votes for each proposal
    uint256 public userCount = 0;                       // Total number of signers
    address public CPTTokenAddress;                      // Address of the CPT token

    event CreateProposal(address indexed _user, uint256 indexed _amount, uint256 _time);  // Event for proposal creation
    event Vote(address indexed _user, uint256 indexed _time, uint256 indexed _proposalID, uint256 _totalVotes);  // Event for voting

    // Constructor to set the CPT token address
    constructor(address CPTToken) {
        CPTTokenAddress = CPTToken;
    }

    // Function to add new signers
    function addSigner(address[] memory _user) public onlyOwner {
        for (uint256 i = 0; i < _user.length; i++) {
            if (user[_user[i]] == false) {
                user[_user[i]] = true;
                userCount++;
            }
        }
    }

    // Function to remove signers
    function removeSigner(address[] memory _user) public onlyOwner {
        for (uint256 i = 0; i < _user.length; i++) {
            if (user[_user[i]] == true) {
                user[_user[i]] = false;
                userCount--;
            }
        }
    }

    // Function to create a new proposal
    function createProposal(uint256 _amount) public returns (uint256) {
        require(_amount > 0, "Invalid Amount");  // Ensure the amount is positive
        _proposal memory newproposal = _proposal({
            user: msg.sender,
            amount: _amount,
            time: block.timestamp,
            votes: 0,
            isOpen: true
        });
        proposal[address(this)].push(newproposal);
        emit CreateProposal(msg.sender, _amount, block.timestamp);
        return proposal[address(this)].length - 1;  // Return the index of the newly created proposal
    }

    // Function to vote on a proposal
    function vote(uint256 _proposalId) public {
        require(proposal[address(this)][_proposalId].isOpen == true, "Proposal Already Closed");  // Ensure the proposal is still open
        require(user[msg.sender] == true, "You are not a signer");  // Ensure the sender is a signer
        require(votes[_proposalId][msg.sender] == false, "You have already Voted for this proposal");  // Ensure the sender hasn't already voted

        votes[_proposalId][msg.sender] = true;  // Record the vote
        proposal[address(this)][_proposalId].votes++;  // Increment the vote count

        // If the number of votes exceeds half of the total signers, execute the proposal
        if (proposal[address(this)][_proposalId].votes * 2 > userCount) {
            ERC20(CPTTokenAddress).transfer(proposal[address(this)][_proposalId].user, proposal[address(this)][_proposalId].amount);
            proposal[address(this)][_proposalId].isOpen = false;  // Close the proposal
        }

        emit Vote(msg.sender, block.timestamp, _proposalId, proposal[address(this)][_proposalId].votes);
    }

    // Function to remove a proposal (only the owner can do this)
    function removeProposal(uint256 _proposalId) public onlyOwner {
        require(proposal[address(this)][_proposalId].isOpen == true, "Proposal Already Closed");  // Ensure the proposal is still open
        proposal[address(this)][_proposalId].isOpen = false;  // Close the proposal
    }

    // Function to withdraw all tokens from the contract (only the owner can do this)
    function withdrawTokens(address _token) public onlyOwner {
        uint256 balance = ERC20(_token).balanceOf(address(this));  // Get the contract's token balance
        require(balance > 0, "Insufficient Amount to withdraw");  // Ensure there are tokens to withdraw
        ERC20(_token).transfer(owner, balance);  // Transfer tokens to the owner
    }
}
