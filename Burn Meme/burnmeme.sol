// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract Ownable is Context {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Treasury is Ownable {


    string public MEME;

    IERC20 public XDC;

    uint256 public userCount;
    uint256 public MAX_USER_LIMIT = 500000;

    
    uint256 public MaintainenceFee;
    uint256 public DeadFee;
    uint256 public PERCENT_DIVIDER = 1e4;

    address public MaintainenceWallet;
    address public DeadWallet;
    address public Signer;

    address internal FirstWinner;
    address internal SecondWinner;
    address internal ThirdWinner;

    bool public paused;
    uint256 public totalDeposit;

    struct data {
        uint256 _amount;
        uint256 _index;
        uint256 totalWithdrawals;
        uint256 totalWithdrawables;
    }
    mapping(address => data) public userRecord;
    mapping (address => uint256) public UserToId; 
    mapping (uint256 => address) public IdToUser;
    address[] public users;

    event Deposit(address indexed MadeBy, uint256 indexed ForAmount, uint256 indexed LeftAfterTax);

    modifier onlySigner(){
        require(_msgSender() == Signer, "error: Not Signer");
        _;
    }

    constructor(address _token, address _signer) {
        XDC = IERC20(_token); 
        Signer = _signer;
    }
    
    function deposit(uint _amount) external {

        require(!paused,"Error: Contract is Paused Right Now!!");
        require(_amount != 0,"Error: Invalid Amount!");

        address _to = msg.sender;
        uint256 currentLength = users.length;
        createUserIdList(_to);
        XDC.transferFrom(_to, address(this), _amount);

        if (userRecord[_to]._amount == 0) {
            maxUserChecker();
            userRecord[_to] = data({
                _amount: 0,
                _index: currentLength,
                totalWithdrawals: 0,
                totalWithdrawables: 0 
            });
            users.push(_to);
            userCount++;
        }

        userRecord[_to]._amount += _amount;
        totalDeposit = totalDeposit + _amount;
        
        uint256 _afterTax = deductTax(_amount);
        emit Deposit(_to, _amount, _afterTax);      

    }

    function deductTax(uint256 _beforeTax) internal returns(uint256 _afterTax){
        /*4% goes to Maintainence Wallet*/
        uint256 toMaintainence = (_beforeTax * MaintainenceFee) / PERCENT_DIVIDER;
        XDC.transfer(MaintainenceWallet, toMaintainence);

        /*30% goes to Dead Wallet*/
        uint256 toDead = (_beforeTax * DeadFee) / PERCENT_DIVIDER;
        XDC.transfer(DeadWallet, toDead);
        
        _afterTax = _beforeTax - (toMaintainence + toDead);
    }

    function maxUserChecker() internal view {
        if(userCount + 1 > MAX_USER_LIMIT) {
            revert("Error: Max User Limit Exceeded!!");
        }
    }

    function getUserLength() external view returns(uint256 length) {
        length = users.length;
    }

    function getTopThreeWinner() external view returns(address _first, address _second, address _third) {
        _first = FirstWinner;
        _second = SecondWinner;
        _third = ThirdWinner;
    }

    function setTopThreeWinner(address _first, address _second, address _third) external onlySigner {
        FirstWinner = _first;
        SecondWinner = _second;
        ThirdWinner = _third;
    }

    function updateUserReward(address _user, uint256 _reward) external onlySigner returns(uint256 rewardAfterUpdate){
        userRecord[_user].totalWithdrawables += _reward;
        rewardAfterUpdate = userRecord[_user].totalWithdrawables;
    }

    function withdraw() external returns(uint256 claimed) {
        address owner = _msgSender();
        uint256 rewards = userRecord[owner].totalWithdrawables;
        userRecord[owner].totalWithdrawables = 0;
        userRecord[owner].totalWithdrawals += rewards;
        XDC.transfer(owner, rewards);
        claimed = rewards;
    }

    /*
    * Get random user*/
    function randomPicker(uint256 limit) external view returns(address _randomlyPicked) {
        uint256 randomId = randomNumberGenerator(limit);
        _randomlyPicked = IdToUser[randomId];
    }

    /*
    * Create user id list*/
    function createUserIdList(address userAddress) internal{
        uint256 userId = UserToId[userAddress];
        uint256 incr = userCount + 1;
        if(userId == 0){
            UserToId[userAddress] = incr;
            IdToUser[incr] = userAddress;
        }
    }

    /*
    *   Cool random user generator*/
    function randomNumberGenerator(uint256 _upto) internal view returns(uint256){
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        uint256 randomNumber = seed - ((seed / _upto) * _upto);
        if(randomNumber == 0){
            randomNumber++;
        }
        return randomNumber;
    }

    /*
    *    These Function are for emergency senarios
    */

    function rescueFunds() external onlyOwner {
        require(address(this).balance > 0, "error: no funds to transfer");
        (bool os,) = payable(owner()).call{value: address(this).balance}("");
        require(os,"Transaction Failed!");
    }

    function rescueTokens(IERC20 _token, address _recipient, uint256 _amount) external onlyOwner {
        _token.transfer(_recipient,_amount);
    }

    function togglePause() external onlyOwner returns(bool isPaused){
        paused = !paused;
        isPaused = paused;
    }

    function setMaxUserLimit(uint _newLimit) external onlyOwner {
        require(_newLimit > 0, "error: zero value");
        MAX_USER_LIMIT = _newLimit;
    }

    function setMaintainenceFee(uint256 _fee) external onlyOwner returns(uint256 _mainstainenceFee){
        require(_fee > 0, "error: zero value");
        MaintainenceFee = _fee;
        _mainstainenceFee = MaintainenceFee;
    }
    function setDeadWalletFee(uint256 _fee) external onlyOwner returns(uint256 _deadFee){
        require(_fee > 0, "error: zero value");
        DeadFee = _fee;
        _deadFee = DeadFee;
    }
    
    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "error: zero address");
        XDC = IERC20(_token);
    }

    function setSigner(address _address) external onlyOwner returns(address _signer) {
        require(_address != address(0), "error: zero address");
        Signer = _address;
        _signer = Signer;
    }

    function setMaintainenceWallet(address _address) external onlyOwner returns(address maintainence){
        require(_address != address(0), "error: zero address");
        MaintainenceWallet = _address;
        maintainence = MaintainenceWallet;
    }

    function setDeadWallet(address _address) external onlyOwner returns(address deadWallet) {
        require(_address != address(0), "error: zero address");
        DeadWallet = _address;
        deadWallet = DeadWallet;
    }

    function setmem(string memory _str) external onlyOwner returns(string memory _newMeme){
        MEME = _str;
        _newMeme = MEME;
    }

}
