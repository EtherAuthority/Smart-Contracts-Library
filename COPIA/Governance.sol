/**
 *Submitted for verification at testnet.bscscan.com on 2024-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
interface ICOPIA
{

    function balanceOf(address user) external view returns(uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
}

contract COPIAGovernance is Ownable, ReentrancyGuard {
    enum ProjType {
        BusinessProject,
        SocialService
    }
    enum AppType {
        Loan,
        Grant
    }
    struct proposalData
    {
        address proposer;
        string projTitle;
        string prodDetails;
        uint256 projFund;
        ProjType projType;
        AppType typeOfApp;
        uint256 createTime;
        uint16 agree;
        uint16 reject;
        uint8 resultExist;
    }
    mapping(uint256 => proposalData) public proposalInfo;
    mapping(uint256 => uint256) public pendingFund;
    uint256 public proposalCount;
    struct VoteInfo {
        address voter;
        uint256 voteTime;
        bool auth;
    }
    mapping(address => mapping(uint256 => VoteInfo)) public votes;
    struct contractValues
    {
        ICOPIA  COPIAToken;        
        uint256  proposalFee;
        uint256  voteFee;
        uint256 proposalFeeColl;
        uint256 voteFeeColl;
        uint256 minAmountHolding;
        uint256 proposalLastingPeriod;
        uint16 minVoters;
    }

    contractValues public contractInfo;

    //events
    event EVAddProposal(uint256 indexed proposalId, address indexed proposer, uint256 createtime);
    event EVVote(
        uint256 indexed id,
        address indexed voter,
        bool auth,
        uint256 time
    );
    event EVPassProposal(
        uint256 indexed id,
        address indexed dst,
        uint256 time
    );
    event EVRejectProposal(
        uint256 indexed id,
        address indexed dst,
        uint256 time
    );

    /**
    * @dev Constructor for initializing the contract with necessary parameters.
    * @param _COPIAToken Address of the COPIA token contract used in voting and proposals.
    * @param _proposalFee Fee required to submit a proposal, in the COPIA token.
    * @param _voteFee Fee required to cast a vote on a proposal, in the COPIA token.
    * @param _proposalLastingPeriod The time period (in seconds) for which a proposal remains active for voting.
    * @param _minAmountHolding Minimum amount of COPIA tokens a user must hold to be eligible to submit a proposal.
    * @param _minVoters Minimum number of voters required for a proposal to be valid.
    */ 
    constructor(address _COPIAToken, uint256 _proposalFee, uint256 _voteFee, uint256 _proposalLastingPeriod, uint256 _minAmountHolding, uint16 _minVoters)  {
        require(_COPIAToken != address(0) ,"Invalid token address");

        contractInfo.COPIAToken = ICOPIA(_COPIAToken);        
        contractInfo.proposalFee = _proposalFee;
        contractInfo.voteFee = _voteFee;
        contractInfo.proposalLastingPeriod = _proposalLastingPeriod;
        contractInfo.minAmountHolding = _minAmountHolding;
        contractInfo.minVoters = _minVoters;
    }

    /**
     * @dev Creates a new proposal with project details and deducts a proposal fee if applicable.
     * @param _projTitle The title of the project (cannot be empty).
     * @param _prodDetails Description of the project.
     * @param _projFund Requested funding amount.
     * @param _prjType Type of the project (enum).
     * @param _typeOfApp Application type (enum).
     * 
     * Requirements:
     * - Caller must hold at least `minAmountHolding` tokens.
     * - If a proposal fee is set, it must be approved and will be transferred.
     * 
     * Emits:
     * - `EVAddProposal` event with proposal ID, sender, and timestamp.
     */
    function createProposal(string calldata _projTitle, string memory _prodDetails, uint256 _projFund, ProjType _prjType, AppType _typeOfApp) external nonReentrant
    {
        require(keccak256(abi.encodePacked(_projTitle)) != keccak256(abi.encodePacked("")) , "Project title is blank");
        require(contractInfo.COPIAToken.balanceOf(msg.sender) >= contractInfo.minAmountHolding, "Not enough tokens");
        if(contractInfo.proposalFee > 0){
          require(contractInfo.COPIAToken.allowance(msg.sender, address(this)) >= contractInfo.proposalFee,"Not enough allowances");
          contractInfo.COPIAToken.transferFrom(msg.sender, address(this), contractInfo.proposalFee);
          contractInfo.proposalFeeColl += contractInfo.proposalFee;
        }
        uint256 id = proposalCount ;
        proposalData memory proposal;
        proposal.proposer = msg.sender;
        proposal.projTitle = _projTitle;
        proposal.prodDetails = _prodDetails;
        proposal.projFund = _projFund;
        proposal.projType = _prjType;
        proposal.typeOfApp = _typeOfApp;
        proposal.createTime = block.timestamp;

        proposalInfo[id] = proposal;
        proposalCount += 1;
        emit EVAddProposal(id, msg.sender, block.timestamp);

    }

    /**
     * @dev Casts a vote on a proposal and processes the vote fee if applicable.
     * @param id The ID of the proposal to vote on.
     * @param auth Boolean indicating whether the vote is in favor (`true`) or against (`false`).
     * 
     * Requirements:
     * - The proposal must exist and not be expired.
     * - The caller cannot vote on their own proposal.
     * - The caller must not have voted on the proposal before.
     * - If a vote fee is set, the caller must have enough tokens and allowance to pay the fee.
     * 
     * Emits:
     * - `EVVote` event upon casting a vote.
     * - `EVPassProposal` or `EVRejectProposal` if the proposal passes or is rejected based on votes.
     */
    function vote(uint256 id, bool auth) external nonReentrant returns(bool)  
    {
      require(proposalInfo[id].createTime != 0, "Invalid Proposal");
      require(proposalInfo[id].proposer != msg.sender, "Cannot vote for own proposal");
      require(
            block.timestamp < proposalInfo[id].createTime + contractInfo.proposalLastingPeriod,
            "Proposal expired"
        );
      if(contractInfo.voteFee > 0){
        require(contractInfo.COPIAToken.balanceOf(msg.sender) >= contractInfo.voteFee, "Not enough tokens");
        require(contractInfo.COPIAToken.allowance(msg.sender, address(this)) >= contractInfo.voteFee,"Not enough allowances");
        contractInfo.COPIAToken.transferFrom(msg.sender, address(this), contractInfo.voteFee);
        contractInfo.voteFeeColl += contractInfo.voteFee;
      }
      require(
            votes[msg.sender][id].voteTime == 0,
            "You can't vote for a proposal twice"
        );
        votes[msg.sender][id].voteTime = block.timestamp;
        votes[msg.sender][id].voter = msg.sender;
        votes[msg.sender][id].auth = auth;
        emit EVVote(id, msg.sender, auth, block.timestamp);

        if (auth) {
            proposalInfo[id].agree = proposalInfo[id].agree + 1;
        } else {
            proposalInfo[id].reject = proposalInfo[id].reject + 1;
        }
        if(proposalInfo[id].resultExist > 0) {
            // do nothing if dst already passed or rejected.
            return true;
        }
        uint16 totalVotes = proposalInfo[id].agree + proposalInfo[id].reject;
        if ( contractInfo.minVoters <=  totalVotes &&
            (proposalInfo[id].agree >= ((totalVotes / 2) + 1))
        ) {
            proposalInfo[id].resultExist = 1;
            //transfer fund
            if(contractInfo.COPIAToken.balanceOf(address(this)) >= proposalInfo[id].projFund)
            {
              contractInfo.COPIAToken.transfer(proposalInfo[id].proposer, proposalInfo[id].projFund);
            }
            else
            {
              pendingFund[id] = proposalInfo[id].projFund;
            }
            emit EVPassProposal(id, proposalInfo[id].proposer, block.timestamp);
            return true;
        }

        if ( contractInfo.minVoters <=  totalVotes &&
            (proposalInfo[id].reject >= ((totalVotes / 2) + 1))
        ) {
            proposalInfo[id].resultExist = 2;
            emit EVRejectProposal(id, proposalInfo[id].proposer, block.timestamp);
        }
         return true;
    }

    /**
     * @dev Allows the proposer to claim pending funds for a successful proposal.
     * @param id The ID of the proposal for which the funds are being claimed.
     * 
     * Requirements:
     * - Caller must be the proposer of the specified proposal.
     * - There must be pending funds to claim.
     * - The contract must have enough tokens to fulfill the claim.
     */
    function claimPendingFund(uint256 id) external nonReentrant
    {
      uint256 amount = pendingFund[id];
      require(msg.sender == proposalInfo[id].proposer && amount>0, "Invalid proposal");
      require(contractInfo.COPIAToken.balanceOf(address(this)) >= amount , "Not enough tokens");
      pendingFund[id] = 0;
      contractInfo.COPIAToken.transfer(proposalInfo[id].proposer, amount);
    }

    //---------------owner functions ---------
    /**
    * @dev Allows the contract owner to rescue tokens from the contract.
    * @param amount The amount of tokens to be transferred to the owner.
    * 
    * Requirements:
    * - The contract must have at least the specified `amount` of tokens.
    * - Only the owner can call this function.
    */
    function rescuTokens(uint256 amount) external onlyOwner nonReentrant
    {
      require(contractInfo.COPIAToken.balanceOf(address(this)) >= amount, "Not enough tokens");
      contractInfo.COPIAToken.transfer(msg.sender, amount);
    }

    /**
     * @dev Updates contract parameters. Only callable by the owner.
     * @param _COPIAToken Address of the COPIA token.
     * @param _proposalFee Fee for creating proposals.
     * @param _voteFee Fee for voting.
     * @param _proposalLastingPeriod Duration a proposal remains active.
     * @param _minAmountHolding Minimum tokens required to create a proposal.
     * @param _minVoters Minimum number of voters required.
     */
    function setParams(address _COPIAToken, uint256 _proposalFee,uint256 _voteFee, uint256 _proposalLastingPeriod, uint256 _minAmountHolding, uint16 _minVoters) external onlyOwner
    {
      require(_COPIAToken != address(0),"Invalid token address");
      contractInfo.COPIAToken = ICOPIA(_COPIAToken);      
      contractInfo.proposalFee = _proposalFee;
      contractInfo.voteFee = _voteFee;
      contractInfo.proposalLastingPeriod = _proposalLastingPeriod;
      contractInfo.minAmountHolding = _minAmountHolding;
      contractInfo.minVoters = _minVoters;
    }
}