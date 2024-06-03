// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/token/ERC20/IERC20.sol";

/**
 * @title FudToken contract
 * @dev Extends ERC1155 contract 
 */
contract FudToken is ERC1155Supply, Ownable, ERC1155Pausable, ERC1155Burnable {
    using SafeMath for uint256;
        
    bool public saleIsActive;
    uint256 public tokenPrice = 1; // this price in decimal.(it means 0.000000000000000001)
    uint256 private _mintedTokens;
    uint256 constant TOKEN_ID = 7123;
    
    address private constant DEV = 0x0000000000000000000000000000000000000000;
    address private constant LAB = 0x0000000000000000000000000000000000000000;
    address public attentionFudContract;
    IERC20 public  paymentToken;

    event PriceChange(uint256 price);
    event PaymentReleased(address to, uint256 amount);
    event PaymentTokenAddressSet(IERC20 tokenAddress);
    event FlipSaleState(bool flipState);
    event SaleActive(bool saleActive);
    event AttentionContract(address attentionContractAddress);

    constructor(address _paymentToken) ERC1155("ipfs://QmbqE73ZCmMW7eVfrkp8qEgHj6xZRG67Vhm3dsgqVM9cGd") { 
        _mint(msg.sender, TOKEN_ID, 1, "");
        _mintedTokens = 1;
        paymentToken = IERC20(_paymentToken);
    }
    
    function pause() external onlyOwner {
        _pause();
        if (saleIsActive) {
            saleIsActive = false;
        }
        emit SaleActive(saleIsActive);
    }

    function unpause() external onlyOwner {
        _unpause();
    }
    
    function name() external pure returns (string memory) {
        return "Fud Token";
    }

    function symbol() external pure returns (string memory) {
        return "FUD";
    }
    
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._burn(account, id, amount);
    }
    
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._mint(account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._mintBatch(to, ids, amounts, data);
    }
    
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._burnBatch(account, ids, amounts);
    } 
    
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Pausable, ERC1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }  
    
    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
        emit FlipSaleState(saleIsActive);
    }
    
    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    /**
     * @dev Sets the address of the payment token.
     * Can only be called by the owner.
     * Emits a PaymentTokenAddressSet event.
     * @param tokenAddress The address of the new payment token.
     */
    function setPaymentTokenAddress(address  tokenAddress) external onlyOwner{
        paymentToken = IERC20(tokenAddress);
        emit  PaymentTokenAddressSet(paymentToken);
    }
    
    /**     
    * Set price to new value
    * Price set with decimal.
    */
    function setPrice(uint256 price) external  onlyOwner {
        tokenPrice = price;  
        emit PriceChange(tokenPrice);
    }
    
    /**
     * Join the Fud attention contract.
     */
    function joinFUD() external  {
        setApprovalForAll(attentionFudContract, true);
    }
    
    /**
     * Allow to change the Attention contract in case of updates.
     */
    function setAttentionContract(address contractAddress) external  onlyOwner {
        attentionFudContract = contractAddress;
        emit AttentionContract(attentionFudContract);
    }

    /**
     * Mint the requested number of tokens.
     * MAX 20!
     */
    function mint(uint256 numberOfTokens) external {
        require(saleIsActive, "FUD: Sale must be active to mint Tokens!");
        require(!paused(), "FUD: Minting is paused");
        require(numberOfTokens <= 20, "FUD: You can only mint 20 tokens at a time");
        uint256 totalPrice = tokenPrice.mul(numberOfTokens);
        require(paymentToken.transferFrom(msg.sender, address(this), totalPrice), "FUD: Insufficient allowance!");
        _mintedTokens += numberOfTokens;
        _mint(msg.sender, TOKEN_ID, numberOfTokens, "");
    }
    
    function withdrawAll() public onlyOwner {
        uint256 balance = paymentToken.balanceOf(address(this));
        require(balance > 0, "Insufficient balance");
        _withdraw(DEV, (balance * 10) / 100);
        _withdraw(LAB, paymentToken.balanceOf(address(this)));
    }

    function _withdraw(address _address, uint256 _amount) private {
        require(paymentToken.transfer(_address, _amount), "Failed to withdraw tokens");
    }
}