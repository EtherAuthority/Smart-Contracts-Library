// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

interface INLC{
 function transfer(address to, uint256 numberOfTokens) external;
  function balanceOf(address account) external view returns (uint256);
}

contract  AirdropToken {
    INLC public token;
    address private _owner;

    event Airdrop(address indexed to, uint256 amount);
    event TokensWithdrawn(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == _owner, "NLC_Airdrop: Only owner can execute this");
        _;
    }

    constructor(address tokenAddress) {
        token = INLC(tokenAddress);
        _owner = msg.sender;  // Set the contract deployer as the owner
    }
    

    /**
     * @dev Airdrop tokens to multiple addresses.
     * @param recipients List of addresses to receive tokens.
     * @param amounts List of amounts corresponding to each address.
     */
    function airdrop(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "NLC_Airdrop: Recipients and amounts length mismatch");
        
        uint256 totalAmount = 0;  // Track the total amount to airdrop
        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "NLC_Airdrop: Invalid recipient address");
            require(amounts[i] > 0, "NLC_Airdrop: Amount must be greater than 0");
            totalAmount = totalAmount + (amounts[i]);
        }
    
        require(token.balanceOf(address(this)) >= totalAmount, "NLC_Airdrop: Insufficient contract balance");
    
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transfer(recipients[i], amounts[i]);
            emit Airdrop(recipients[i], amounts[i]);
        }
    }

    /**
     * @notice Withdraw remaining tokens from the contract.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawTokens(uint256 amount) external onlyOwner  {
        require(amount > 0, "SecureAirdrop: invalid amount");
        uint256 balance = token.balanceOf(address(this));
        require(amount <= balance, "SecureAirdrop: insufficient balance");

        token.transfer(msg.sender, amount);
        emit TokensWithdrawn(amount);
    }
}

