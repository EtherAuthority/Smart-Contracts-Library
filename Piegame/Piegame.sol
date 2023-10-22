// SPDX-License-Identifier: MIT


pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns(bool);
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract PieGame is Ownable(msg.sender){

    uint256 public gameCount=1;
    uint256 public gameFee;
    address public tokenAddress;

    uint256 public gameTimer=3600;

    struct _game{
        uint256 gameFinishTime;
        address[] lastPlayer;
        uint256 balance;
    }

    mapping(uint256=>_game) public games;

    mapping(uint256=>mapping(address=>bool)) public players;

    constructor(address _tokenAddress,uint256 _gamefee){
        tokenAddress=_tokenAddress;
        gameFee=_gamefee;
    }

    function setGameTimer(uint256 _time) public onlyOwner returns(bool){
        require(_time!=0,"Cannot Be 0");
        gameTimer=_time;
        return true;
    }


    function stopGame() public onlyOwner returns(bool){
        games[gameCount].gameFinishTime=block.timestamp;
        return true;
    }

    function joinGame() public returns(bool){
        _game storage objgame=games[gameCount];
        require(objgame.gameFinishTime==0 || objgame.gameFinishTime>=block.timestamp,"Game Over");
        
        if(players[gameCount][msg.sender]==false)
        {
            //IERC20(tokenAddress).transferFrom(msg.sender,address(this),gameFee);
            //IERC20(tokenAddress).burn((gameFee*10)/100);

            objgame.balance+=(gameFee*50)/100;
            objgame.lastPlayer.push(msg.sender);
            objgame.gameFinishTime=block.timestamp+gameTimer;    

            players[gameCount][msg.sender]=true; 
        }
        else
        {
            //IERC20(tokenAddress).transferFrom(msg.sender,address(this),(gameFee*60)/100);
            objgame.balance+=(gameFee*60)/100;
            objgame.lastPlayer.push(msg.sender);
            objgame.gameFinishTime=block.timestamp+gameTimer;
        }

       
        return true;
    }


    function ExitAndWithdrawAmount(uint256 _gameId) public returns(bool){
        require(players[_gameId][msg.sender]==true,"Already Withdrawn From Game");

        uint256 useramt=(gameFee*40)/100;

        if(games[_gameId].gameFinishTime==0 || games[_gameId].gameFinishTime>=block.timestamp)
        {
            //IERC20(tokenAddress).transfer(msg.sender,(useramt*90)/100);
            games[_gameId].balance+=(useramt*5)/100;
            //IERC20(tokenAddress).burn((useramt*5)/100);
            removeAddress(_gameId,msg.sender);
        }
        else
        {
            if(games[_gameId].lastPlayer[games[_gameId].lastPlayer.length-1]==msg.sender)
            {
                //IERC20(tokenAddress).transfer(msg.sender,(games[_gameId].balance+useramt));
            }
            else
            {
                //IERC20(tokenAddress).transfer(msg.sender,useramt);
            }
        }

        players[_gameId][msg.sender]=false;
       
        return true;
    }

    function removeAddress(uint256 _gameid,address _user) internal returns(bool){

        _game storage objgame=games[_gameid];

        for(uint i=0;i<objgame.lastPlayer.length;i++)
        {
            if(objgame.lastPlayer[i]==_user)
            {
                delete objgame.lastPlayer[i];
               
            }
        }
        return true;
    }

    function winner(uint256 _gameid) public view returns(address){
        return games[_gameid].lastPlayer[games[_gameid].lastPlayer.length-1];
    }

    


}