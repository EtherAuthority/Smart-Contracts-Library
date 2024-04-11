// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IERC20{
 function transfer(address to, uint256 numberOfTokens) external;
  function balanceOf(address account) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

contract Ownable is Context {
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

contract ICO is Ownable{
    IERC20 public token; // The token being sold
    
    uint256 public tokenPrice; // Price of each token in Wei

    // Event token purchase
    event TokensPurchased(address buyer, uint256 amount, uint256 totalCost);
    // Event recover token
    event RecoveredToken(uint256 recoverToken);

    constructor(address _tokenAddress, uint256 _tokenPriceInWei) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
        tokenPrice = _tokenPriceInWei;
    }

    /* 
     * @notice Allows users to buy tokens by sending ETH to the contract.
     * @dev Users must send enough ETH to cover the total cost of tokens.
     *      The contract calculates the total cost based on the number of tokens requested
     *      and the current token price.
     *      If the amount of ETH sent is insufficient, the transaction reverts.
     * @param numberOfTokens The number of tokens to buy.
     * @return No return value. Emits a TokensPurchased event upon successful token purchase.
    */
    function buyTokens(uint256 numberOfTokens) external payable {
        uint256 totalCost = numberOfTokens * tokenPrice;
        require(msg.value >= totalCost, "Insufficient ETH sent");
        token.transfer(msg.sender, numberOfTokens*10**18);
        payable(owner()).transfer(totalCost);
        emit TokensPurchased(msg.sender, numberOfTokens, totalCost);
    }
    
    /* 
     * @notice Allows the contract owner to recover any excess tokens left in the contract.
     * @dev Only the contract owner can call this function.
     *      It retrieves the token balance of the contract and transfers the entire balance of tokens
     *      to the owner's address.
     *      If there are no excess tokens to recover, the transaction reverts.
     * @return No return value.
    */
    function recoverToken() external onlyOwner {
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0,"Not sufficient token balance");
        token.transfer((owner()), tokenBalance);
        emit RecoveredToken(tokenBalance);
    }
    /**
    * @notice Retrieves the number of tokens available in the ICO contract.
    * @dev This function allows external callers to check the balance of tokens held by the ICO contract.
    * @return The number of tokens available in the ICO contract.
    */
    function availableToken() external view returns(uint256){
        return token.balanceOf(address(this));
    }
}
