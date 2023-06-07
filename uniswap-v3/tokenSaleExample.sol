// SPDX-License-Identifier: GPL-3.0
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.17;
pragma abicoder v2;

import "./memeverseToken.sol";
import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";
import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/IQuoter.sol";



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}


contract TokenSale is Ownable{

    uint256 public tokensSold;
    uint256 public referrerRewardPercent;
    
    Token public token;

    IUniswapRouter public constant uniswapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IQuoter public constant quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    address private constant WETH9 = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;


    // Events
    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensReferralRewarded(
        address indexed referrer,
        address indexed referee,
        uint256 amount
    );

    constructor(
        Token _token,
        uint256 _referrerRewardPercent
    ) {

        token = _token;
        referrerRewardPercent = _referrerRewardPercent;

    }

    // Token Buy
    function buyTokens(address referrer, uint256 tokenAmount, address spendToken) external payable {
        uint256 amount;
        if(spendToken == address(0)){
            /* spend token is ETHER*/
            amount = getBuyPrice(msg.value, WETH9, 3000);
            IERC20(address(token)).transferFrom(owner(), msg.sender, amount);
        }else{
            IERC20(spendToken).transferFrom(msg.sender, owner(), amount);
            amount = getBuyPrice(tokenAmount, spendToken, 3000);
            IERC20(address(token)).transferFrom(owner(), msg.sender, amount);

        }

        tokensSold += amount;

        emit TokensPurchased(msg.sender, amount);

        // Referral bonus
        if (referrer != address(0)) {
            uint256 bonus = (amount * referrerRewardPercent) / 100; // Calculating the referral bonus 
            token.transfer(referrer, bonus);

            emit TokensReferralRewarded(referrer, msg.sender, bonus);
        }
    }

    /**
    * return buy price of address(this), 
    * i.e., how much eth you need to spend in order to buy a desired amount of address(this)(aegument: uint forHowMuchToken)
    */
    function getBuyPrice(uint amountIn, address tokenIn, uint24 fee) public payable returns (uint256 amountOut) {
        address tokenOut = address(token);
        uint160 sqrtPriceLimitX96 = 0;

        return quoter.quoteExactInputSingle(
            tokenIn,
            tokenOut,
            fee,
            amountIn,
            sqrtPriceLimitX96
        );
    }


    function setReferrerRewardPercent(uint256 _referrerRewardPercent) external onlyOwner{
        referrerRewardPercent = _referrerRewardPercent;
    }

    function withdrawLeftoverTokens() external onlyOwner{
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        token.transfer(msg.sender, balance);
    }
}
