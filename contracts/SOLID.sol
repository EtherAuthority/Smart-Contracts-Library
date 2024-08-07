// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//

contract owned {
    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) external onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = payable(0);
    }
}

//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//

contract SOLID is owned {
    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    string private constant _name = "SOLID";
    string private constant _symbol = "SOLID";
    uint256 private constant _decimals = 18;
    uint256 private _totalSupply = 1000000 * (10 ** _decimals); //1 million tokens

    // This creates a mapping with all data storage
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowance;

    /*===============================
    =         PUBLIC EVENTS         =
    ===============================*/

    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    // This will log approval of token Transfer
    event Approval(
        address indexed from,
        address indexed spender,
        uint256 value
    );

    /*======================================
    =       STANDARD ERC20 FUNCTIONS       =
    ======================================*/

    /**
     * Returns name of token
     */
    function name() external pure returns (string memory) {
        return _name;
    }

    /**
     * Returns symbol of token
     */
    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    /**
     * Returns decimals of token
     */
    function decimals() external pure returns (uint256) {
        return _decimals;
    }

    /**
     * Returns totalSupply of token.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns balance of token
     */
    function balanceOf(address user) external view returns (uint256) {
        return _balanceOf[user];
    }

    /**
     * Returns allowance of token
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowance[owner][spender];
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        //checking conditions
        require(_to != address(0)); // Prevent transfer to 0x0 address. Use burn() instead

        // overflow and undeflow checked by SafeMath Library
        _balanceOf[_from] = _balanceOf[_from] - _value; // Subtract from the sender
        _balanceOf[_to] = _balanceOf[_to] + _value; // Add the same to the recipient

        // emit Transfer event
        emit Transfer(_from, _to, _value);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success) {
        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        //checking of allowance and token value is done by SafeMath
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender] - _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success) {
        /* AUDITOR NOTE:
            Many dex and dapps pre-approve large amount of tokens to save gas for subsequent transaction. This is good use case.
            On flip-side, some malicious dapp, may pre-approve large amount and then drain all token balance from user.
            So following condition is kept in commented. It can be be kept that way or not based on client's consent.
        */
        //require(_balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*=====================================
    =       CUSTOM PUBLIC FUNCTIONS       =
    ======================================*/

    constructor() {
        //sending all the tokens to Owner
        _balanceOf[owner] = _totalSupply;

        //firing event which logs this transaction
        emit Transfer(address(0), owner, _totalSupply);
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) external returns (bool success) {
        //only token holder can burn his own tokens. owner can not burn someone else's tokens.
        _balanceOf[msg.sender] = _balanceOf[msg.sender] - _value; // Subtract from the sender
        _totalSupply = _totalSupply - _value; // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    /**
     * @notice Create `mintedAmount` tokens and send it to `target`
     * @param target Address to receive the tokens
     * @param mintedAmount the amount of tokens it will receive
     */
    function mintToken(
        address target,
        uint256 mintedAmount
    ) external onlyOwner {
        _balanceOf[target] = _balanceOf[target] + mintedAmount;
        _totalSupply = _totalSupply + mintedAmount;
        emit Transfer(address(0), target, mintedAmount);
    }

    /**
     * Owner can transfer tokens from contract to owner address
     */

    function manualWithdrawTokens(uint256 tokenAmount) external onlyOwner {
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this), owner, tokenAmount);
    }
}
