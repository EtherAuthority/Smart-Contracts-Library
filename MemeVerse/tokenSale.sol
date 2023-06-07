// SPDX-License-Identifier: GPL-3.0
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.7.6;



library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = -denominator & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}


// IERC20 standard interface
interface IERC20
{
    function balanceOf(address user) external view returns(uint256);
    function decimals() external view returns(uint8);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
} 


//USDT contract in Ethereum does not follow ERC20 standard so it needs different interface
interface IERC20_USDT
{
    function transferFrom(address _from, address _to, uint256 _amount) external;
}


// Interface for Uniswap V3 Pool contract
interface Pool{
    function token0() external view returns(address);
    function slot0() external view returns( uint160, int24,  uint16,  uint16,  uint16,  uint8,  bool);
}


// Ownership smart contract
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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


// Main Token sale smart contract 
contract TokenSale is Ownable{

    //public variables
    uint256 public tokensSold;
    uint256 public referrerRewardPercent;
    IERC20 public token;
    mapping(address => bool) public pools;

    // Events
    event TokensPurchased(address indexed buyer, address tokenAddress, uint256 amount);
    event TokensReferralRewarded(
        address indexed referrer,
        address indexed referee,
        uint256 amount
    );

    constructor(
        IERC20 _token,
        uint256 _referrerRewardPercent
    ) {
        token = _token;
        referrerRewardPercent = _referrerRewardPercent;
    }

    /**
    * Token Buy
    */
    function buyTokens(address referrer, uint256 tokenAmount, address poolAddress) external payable {
        uint256 tokenPrice;
        uint256 amount;
        address token0;
        uint8 decimalsToken0;
        if(msg.value > 0){
            /* spend token is ETHER*/
            (tokenPrice,,decimalsToken0) = getBuyPrice(poolAddress);
            amount = msg.value * tokenPrice / (10**decimalsToken0);
            token.transfer(msg.sender, amount);
            payable(owner()).transfer(msg.value);
        
        }else{
            require(tokenAmount > 0, "Token amount should be greater than zero");
            (tokenPrice, token0, decimalsToken0) = getBuyPrice(poolAddress);
            amount = tokenAmount * tokenPrice / (10**decimalsToken0);
            
            // This is special condition for USDT in ethereum network.
            // It does not follow ERC20 standard and thus it requires different interface
            // This is a special case, and it only applies to following USDT address only
            if(token0 == 0xdAC17F958D2ee523a2206206994597C13D831ec7){
                IERC20_USDT(token0).transferFrom(msg.sender, owner(), tokenAmount);
            }else{
                IERC20(token0).transferFrom(msg.sender, owner(), tokenAmount);
            }
            
            token.transfer(msg.sender, amount);

        }

        tokensSold += amount;

        emit TokensPurchased(msg.sender, token0, amount);

        // Referral bonus
        if (referrer != address(0)) {
            uint256 bonus = (amount * referrerRewardPercent) / 1e4; // Calculating the referral bonus 
            token.transfer(referrer, bonus);

            emit TokensReferralRewarded(referrer, msg.sender, bonus);
        }
    }

    /**
    * return buy price of Token for any pool pair.
    * i.e., How many tokens will be given by paying 1 ETH or any such pair currency.
    */
    function getBuyPrice(address poolAddress)
        public
        view
        returns (uint256, address, uint8)
    {
      
        address token0 = Pool(poolAddress).token0();
        uint8 decimalsToken0 = IERC20(token0).decimals();
        
        (uint160 sqrtPriceX96,,,,,,) =  Pool(poolAddress).slot0();
        uint256 numerator1 = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        uint256 numerator2 = 10**decimalsToken0;
        return ((FullMath.mulDiv(numerator1, numerator2, 1 << 192)),token0, decimalsToken0);
    }

    /**
    * Owner can set referral commission percentage.
    * It should be in precision of 100, which means: 100 = 1%
    */
    function setReferrerRewardPercent(uint256 _referrerRewardPercent) external onlyOwner{
        require(_referrerRewardPercent > 0, "Invalid amount");
        referrerRewardPercent = _referrerRewardPercent;
    }

    /**
    * Owner can add or remove whitelisted pool address.
    * This simply means to add or remove any tokens.
    */
    function whitelistPool(address poolAddress, bool status) external onlyOwner{
        require(poolAddress != address(0), "Invalid address");
        pools[poolAddress] = status;
    }

    /**
    * This lets owner to withdraw any leftover tokens.
    */
    function withdrawLeftoverTokens() external onlyOwner{
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        token.transfer(msg.sender, balance);
    }
}
