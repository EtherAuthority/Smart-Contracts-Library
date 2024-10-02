// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//import 'hardhat/console.sol';

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

/**
 * @title Context
 * @dev The base contract that provides information about the message sender
 * and the calldata in the current transaction.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Locked(address owner, address newOwner,uint256 lockTime);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract TokenSale is Context, Ownable{
    using SafeMath for uint256;
    address public susdtokenAdd;
    address public usdttokenAdd;
    address public tokenSaleAddress;
    uint256 public endSaledate;
    struct _Stages{
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        uint256 tokenAmount;
        uint256 soldTokens;
    }

    _Stages[] public Stages;

    struct _users{
        uint256 purchaseTime;
        uint256 tokenAmount;
        uint256 lastClaimTime;
        uint256 lastClaimIndexTime;
        uint256 calculationStartTime;
        uint256 claimCount;
        uint256 claimed;
    }

    mapping(address=>_users[]) public userPurchase;

    uint256 public constant claimInterval=10;//2592000

    mapping(address=>uint256) public claimedIndex;

    uint256 public claimStartDate;

    event BuyToken(address indexed user,uint256 indexed amount,uint256 indexed price,uint256 time);
    event ClaimToken(address indexed user,uint256 indexed amount,uint256 time);
    event SetTokenAddress(address indexed _susd,address indexed _usdt,uint256 time);

    constructor(address _tokensale,uint256 _claimstarttime) {
       require(_tokensale!=address(0),"Invalid Address");
       tokenSaleAddress=_tokensale;
       claimStartDate=_claimstarttime;
    }

    // Set Both token address from which user can Purcase your token
    // First parameter SUSD token address
    // Second parameter USDT token address
    // It only called by owner
    function setTokenAddress(address _susdadd,address _usdtadd) public onlyOwner{
        require(_susdadd!=address(0) && _usdtadd!=address(0),"Invalid Token Address");
        susdtokenAdd=_susdadd;
        usdttokenAdd=_usdtadd;
        emit SetTokenAddress(_susdadd,_usdtadd,block.timestamp);
    }

    // Set Stage price and token amount for sale for a given time period
    // Add start Date and End date in unixtimstamp format
    // Start date should be less than End date
    // _tokenamt this should with 10**18 zeroes value
    // price in single unit value like if one token price is 5$ then  just provide 5
    function setStage(uint256 _start,uint256 _end,uint256 _price,uint256 _tokenamt) public onlyOwner{
        require(_start<=_end,"Invalid Duration");
        require(_price>0,"Invalid Price");
        require(_tokenamt!=0,"Invalid Token Amount");
        
        if(Stages.length>0)
        {
            require(Stages[Stages.length-1].endTime<=_start,"Conflict Stage");
        }

        _Stages memory stage = _Stages({
            startTime:_start,
            endTime:_end,
            price:_price,
            tokenAmount:_tokenamt,
            soldTokens:0
        });

        Stages.push(stage);

        IERC20(tokenSaleAddress).transferFrom(msg.sender,address(this),_tokenamt);

        if(_end>endSaledate)
        {
            endSaledate=_end;
        }
    }

    // User can buy token using this fucntion 
    // Need to pass _tokenAmount with 10**18 zeroes value
    // _tokenaddress should be one of the token between SUSD or USDT
    function buyToken(uint256 _tokenAmount,address _tokenaddress) external {
        require(_tokenaddress==susdtokenAdd || _tokenaddress==usdttokenAdd,"Invalid Token Address Provided");
        require(_tokenAmount>0,"Invalid Token Amount");
        require(endSaledate>block.timestamp,"Sale Ended");
        for(uint256 i=0;i<Stages.length;i++)
        {
            require(Stages[i].startTime<=block.timestamp,"Sale Not Started");
            if(block.timestamp>=Stages[i].startTime && block.timestamp<=Stages[i].endTime)
            {
                require(Stages[i].tokenAmount-Stages[i].soldTokens>=_tokenAmount,"Insufficient Balance");
                
                IERC20(_tokenaddress).transferFrom(msg.sender,address(this),_tokenAmount*Stages[i].price);

                IERC20(tokenSaleAddress).transfer(msg.sender,(_tokenAmount*10)/100);
                
                uint256 calc=block.timestamp;
                if(claimStartDate>block.timestamp)
                {
                    calc=claimStartDate;
                }

                _users memory user = _users({
                    purchaseTime:block.timestamp,
                    tokenAmount:_tokenAmount,
                    lastClaimTime:block.timestamp,
                    lastClaimIndexTime:calc,
                    calculationStartTime:calc,
                    claimCount:0,
                    claimed:(_tokenAmount*10)/100
                });
                
                userPurchase[msg.sender].push(user);
                Stages[i].soldTokens+=_tokenAmount;
                emit BuyToken(msg.sender,_tokenAmount,Stages[i].price,block.timestamp);
                break;
            }
        }

    }

    // User can claim the  5% of his purchase amount in a interval of 30 days
    function claimToken() external{
        require(claimStartDate<=block.timestamp,"Claim Process Not Started Yet");
        for(uint256 i=claimedIndex[msg.sender];i<userPurchase[msg.sender].length;i++)
        {
            if(userPurchase[msg.sender][i].claimCount<18)
            {
                uint256 totalMonth;
                if(userPurchase[msg.sender][i].calculationStartTime+(claimInterval*18)<=block.timestamp)
                {
                    totalMonth=18-userPurchase[msg.sender][i].claimCount;
                }
                else 
                {
                    totalMonth=(block.timestamp-userPurchase[msg.sender][i].lastClaimIndexTime)/claimInterval;
                }
                
                userPurchase[msg.sender][i].lastClaimIndexTime+=claimInterval*totalMonth;
                userPurchase[msg.sender][i].lastClaimTime=block.timestamp;
                userPurchase[msg.sender][i].claimCount+=totalMonth;
                userPurchase[msg.sender][i].claimed+=((userPurchase[msg.sender][i].tokenAmount*5)/100)*totalMonth;
                IERC20(tokenSaleAddress).transfer(msg.sender,((userPurchase[msg.sender][i].tokenAmount*5)/100)*totalMonth);
                emit ClaimToken(msg.sender, ((userPurchase[msg.sender][i].tokenAmount*5)/100)*totalMonth, block.timestamp);
                if(userPurchase[msg.sender][i].claimCount==18)
                {
                    claimedIndex[msg.sender]++;
                }                
                  
            }
            
        }
    }

    // Get the length of the userPurchase record
    function purchaseLength(address _add) public view returns(uint256){
        return userPurchase[_add].length;
    }

    // Get the length of the Stages
    function stagelength() public view returns(uint256){
        return Stages.length;
    }

    // User can Check his Avalailable balance to claim here
    function viewClaimAmount() public view returns(uint256){
        require(claimStartDate<block.timestamp,"Claim Process Not Started");
        uint256 totalclaim;
        for(uint256 i=claimedIndex[msg.sender];i<userPurchase[msg.sender].length;i++)
        {
            if(userPurchase[msg.sender][i].claimCount<18)
            {
                uint256 totalMonth;
                if(userPurchase[msg.sender][i].calculationStartTime+(claimInterval*18)<=block.timestamp)
                {
                    totalMonth=18-userPurchase[msg.sender][i].claimCount;
                }
                else 
                {
                    totalMonth=(block.timestamp-userPurchase[msg.sender][i].lastClaimIndexTime)/claimInterval;
                }
                
                totalclaim+=((userPurchase[msg.sender][i].tokenAmount*5)/100)*totalMonth;       
                  
            }
            
        }

        return totalclaim;
    }

    function viewClaimedAmount() public view returns(uint256){

        uint256 totalclaim;
        for(uint256 i=0;i<userPurchase[msg.sender].length;i++)
        {
            totalclaim+=userPurchase[msg.sender][i].claimed;
        }

        return totalclaim;
    }

    function withdrawTokens(address _tokenadd,uint256 _amount) public onlyOwner{
        IERC20(_tokenadd).transfer(msg.sender,_amount);
    }

    function withdrawNative() public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

    function getActiveStage() public view returns(uint256){
        uint256 stage=0;
        for(uint256 i=0;i<Stages.length;i++)
        {
           
            if(block.timestamp>=Stages[i].startTime && block.timestamp<=Stages[i].endTime)
            {
                stage=i+1;
            }
        }

        return stage;
    }

    function getTokenToBeClaim() public view returns(uint256){
        uint256 totalclaim;
        for(uint256 i=0;i<userPurchase[msg.sender].length;i++)
        {
            totalclaim+=userPurchase[msg.sender][i].tokenAmount-userPurchase[msg.sender][i].claimed;
        }

        return totalclaim;
    }

    receive() external payable { }
}
