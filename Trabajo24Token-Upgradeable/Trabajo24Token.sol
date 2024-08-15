// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";

contract Trabajo24Token is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable {
   
    address public  marketingWallet;
    address public  developmentWallet;
    address public  sustainabilityWallet;
    
    uint256 public  marketingWalletTax; 
    uint256 public  developmentWalletTax;
    uint256 public  sustainabilityWalletTax;
    uint256 public  maxTransactionAmount;
    uint256 private _totalSupply;

    mapping(address => bool) private _blacklisted;
    mapping(address => mapping(address => uint256)) private _allowances;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    event UpdatedMarketingWalletTax(uint256 _updatedMarketingWalletTax);
    event UpdatedtDevelopmentWalletTax(uint256 _updatedtDevelopmentWalletTax);
    event UpdatedtSustainabilityWalletTax(uint256 _updatedtSustainabilityWalletTax);
    event UpdatedMaxAmount(uint256 _updatedMaxAmount);
    event UpdatedMarketingWallet(address _updatedMarketingWallet);
    event UpdatedDevelopmentWallet(address _updatedDevelopmentWallet);
    event UpdatedSustainabilityWallet(address _updatedSustainabilityWallet);

    /**
    * @dev Initializes the contract with the specified parameters.
    * This function sets up the initial state of the contract, including wallet addresses, tax rates, and Uniswap integration.
    * @param _marketingWallet The address of the marketing wallet.
    * @param _developmentWallet The address of the development wallet.
    * @param _sustainabilityWallet The address of the sustainability wallet.
    * However, while Solidity ensures that a constructor is called only once in the lifetime of a contract,
      a regular function can be called many times.
    * To prevent a contract from being initialized multiple times,
      you need to add a check to ensure the initialize function is called only once
    */
    function initialize(address _marketingWallet,address _developmentWallet,address _sustainabilityWallet) public initializer {
        __Ownable_init(msg.sender);
        __ERC20Burnable_init();
        __ERC20_init("Trabajo24","T24");
        marketingWallet= _marketingWallet;
        developmentWallet = _developmentWallet;
        sustainabilityWallet = _sustainabilityWallet;
        _totalSupply = 100000000 * 10 ** decimals();
        marketingWalletTax = 10;  // 0.1%
        developmentWalletTax = 20;  // 0.2%
        sustainabilityWalletTax =150; // 1.5%
        // Set initial max transaction amount
        maxTransactionAmount = 20000000 * 10 ** uint256(decimals());
        // Mint initial supply
        _mint(msg.sender,_totalSupply);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
           0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // BSC Testnet
        ); 

        uniswapV2Router = _uniswapV2Router;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
 
        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
 
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
    * @dev Allows the owner to mint new tokens to a specified address.
    * This function can be used to increase the total supply of tokens.
    * @param to The address to which the new tokens will be minted.
    * @param amount The amount of tokens to mint.
    */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
    /**
    * @dev Sets the marketing wallet tax percentage. This function allows the owner to update the tax percentage
    * that will be applied to marketing transactions.
    * @param _taxPercentage The new tax percentage to be set. It is expected to be in basis points (i.e., 100 basis points = 1%).
    * The maximum allowed value is 10000 basis points (100%).
    */
    function setMarketingWalletTax(uint256 _taxPercentage) external onlyOwner {
        require(_taxPercentage <= 10000,"Tax percentage cannot exceed 100%");
        marketingWalletTax = _taxPercentage;
        emit UpdatedMarketingWalletTax(marketingWalletTax);
    }
    
    /**
    * @dev Sets the development wallet tax percentage. This function allows the owner to update the tax percentage
    * that will be applied to development transactions.
    * @param _taxPercentage The new tax percentage to be set. It is expected to be in basis points (i.e., 100 basis points = 1%).
    * The maximum allowed value is 10000 basis points (100%).
    */
    function setDevelopmentWalletTax(uint256 _taxPercentage) external onlyOwner {
        require(_taxPercentage <= 10000,"Tax percentage cannot exceed 100%");
        developmentWalletTax = _taxPercentage;
        emit UpdatedtDevelopmentWalletTax(developmentWalletTax);
    }

    function setSustainabilityWalletTax(uint256 _taxPercentage) external onlyOwner {
        require(_taxPercentage <= 10000,"Tax percentage cannot exceed 100%");
        sustainabilityWalletTax = _taxPercentage;
        emit UpdatedtSustainabilityWalletTax(sustainabilityWalletTax);
    }
    
    /**
    * @dev Sets the maximum transaction amount. This function allows the owner to update the maximum amount of tokens
    * that can be transferred in a single transaction.
    * @param _amount The new maximum transaction amount. Must be greater than 0.
    */
    function setMaxAmount(uint256 _amount) external onlyOwner {
        require(_amount > 0,"amount should be greate than 0");
        maxTransactionAmount = _amount;
        emit UpdatedMaxAmount(maxTransactionAmount);
    }
    
    /**
    * @dev Sets the marketing wallet address. This function allows the owner to update the address where marketing-related 
    * funds or taxes will be sent.
    * @param _wallet The new marketing wallet address. Must not be the zero address.
    */
    function setMarketingWallet(address _wallet) external onlyOwner {
       require(_wallet != address(0),"Marketing wallet cannot be zero address");
       marketingWallet = _wallet;
       emit UpdatedMarketingWallet(marketingWallet);
    }

    /**
     * @dev Sets the Development wallet address. This function allows the owner to update the address where Development-related
     * funds or taxes will be sent.
     * @param _wallet The new Development wallet address. Must not be the zero address.
     */
    function setDevelopmentWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0),"Dev wallet cannot be zero address");
        developmentWallet = _wallet;
        emit UpdatedDevelopmentWallet(developmentWallet);
    }

    /**
    * @dev Sets the sustainability wallet address. This function allows the owner to update the address where sustainability-related
    * funds or taxes will be sent.
    * @param _wallet The new sustainability wallet address. Must not be the zero address.
    */
    function setSustainabilityWallet(address _wallet) external onlyOwner {
       require(_wallet != address(0),"stainability wallet cannot be zero address");
       sustainabilityWallet = _wallet;
       emit UpdatedSustainabilityWallet(sustainabilityWallet);
    }

    /**
     * @dev Adds an account to the blacklist. This function allows the owner to blacklist an address, preventing it from 
     * participating in transactions involving this token.
     * @param account The address to be added to the blacklist. Must not be the owner's address.
     */
    function addToBlacklist(address account) external onlyOwner{
        require(!_blacklisted[account], "Account is already blacklisted");
        require(_msgSender() != account, "Cannot blacklist self");
        _blacklisted[account] = true;
    }

    /**
     * @dev Removes an account from the blacklist. This function allows the owner to remove an address from the blacklist,
     * allowing it to participate in transactions involving this token again.
     * @param account The address to be removed from the blacklist. Must be currently blacklisted.
     */
    function removeFromBlacklist(address account) external onlyOwner{
        require(_blacklisted[account], "Account is not blacklisted");
        require(_msgSender() != account, "Cannot remove self from blacklist");
        _blacklisted[account] = false;
    }

    /**
    * @dev Checks if an address is blacklisted.
    * This function allows anyone to check if a particular address is currently blacklisted,
    * meaning it is restricted from participating in transactions involving this token.
    * @param account The address to check the blacklist status of.
    * @return bool True if the account is blacklisted, false otherwise.
    */
    function isBlacklisted(address account) external view returns (bool) {
        return _blacklisted[account];
    }

    /**
     * @dev Internal function for transferring tokens from one address to another.
     * If the sender, recipient, or token contract itself is the owner, it performs a regular transfer.
     * If the transfer involves buy or sell on Uniswap, a marketing tax is applied before transferring tokens.
     * Emits Transfer events for both the marketing tax and the token transfer.
     * @param sender The address of the sender.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal override virtual  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!_blacklisted[sender], "Sender is blacklisted");
        require(!_blacklisted[recipient], "Recipient is blacklisted");
 
        //If it's the owner, do a normal transfer
        if (sender == owner() || recipient == owner() || sender == address(this)) {
            _update(sender, recipient, amount);
            return;
        }

        bool isBuy = sender == uniswapPair;
        bool isSell = recipient == uniswapPair;

        uint256 marketingTax;
        uint256 developmentTax;
        uint256 sustainabilityTax;

        if(isBuy || isSell){
            require (amount <= maxTransactionAmount, "Cannot buy & sell more than max limit");
            marketingTax = _calculateTax(amount,marketingWalletTax);
            developmentTax = _calculateTax(amount,developmentWalletTax);
            sustainabilityTax = _calculateTax(amount,sustainabilityWalletTax);

            _update(sender, marketingWallet, marketingTax);
            _update(sender, developmentWallet, developmentTax);
            _update(sender, sustainabilityWallet, sustainabilityTax);
        }

         amount -= (marketingTax + developmentTax + sustainabilityTax);
        _update(sender, recipient, amount);
    }
    
    /**
    * @dev Calculates the tax amount based on a given tax percentage.
    * This internal function computes the tax to be applied on a specified amount based on a tax percentage.
    * The tax percentage is assumed to be given in basis points (i.e., 100 basis points = 1%).
    * @param amount The total amount on which tax is to be calculated.
    * @param taxPercentage The tax percentage to be applied, given in basis points.
    * @return uint256 The calculated tax amount.
    */
    function _calculateTax(uint256 amount, uint256 taxPercentage) internal pure returns (uint256) {
        return amount * (taxPercentage) / (10000);
    }
}
