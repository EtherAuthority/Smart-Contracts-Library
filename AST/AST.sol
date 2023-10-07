// SPDX-License-Identifier: GPL-3.0
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.19;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


interface IAST {
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

   
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address to, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    function burn(uint amount,address _user)external returns(bool);
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


interface IASTMetadata is IAST {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

   
    function decimals() external view returns (uint8);
}


interface IAATY {
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function Mint(uint amount,address _wallet) external;

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
}


interface IAATYMetadata is IAATY {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

   
    function decimals() external view returns (uint8);
}


contract AST is Context, IAST, IASTMetadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private  _decimal;

    
    constructor(string memory name_, string memory symbol_, uint256 decimal_ ,uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimal=decimal_;
        _balances[tx.origin]=totalSupply_/2;
        _balances[msg.sender]=totalSupply_/2;
        _totalSupply=totalSupply_;

    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

   
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

   
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

   
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function burn(uint amount,address _user)external returns(bool){
        
        _burn(_user,amount);
       return true;
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

   
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

   
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/1_Storage.sol

abstract contract Ownable is Context {
    address public _contractOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function contractOwner() public view virtual returns (address) {
        return _contractOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_contractOwner, address(0));
        _setContractOwner(address(0));
    }

    modifier onlyOwner() {
        require(contractOwner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(_contractOwner, newOwner);
        _setContractOwner(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_contractOwner, newOwner);
        _setContractOwner(newOwner);
    }

    function _setContractOwner(address newOwner) internal {
        _contractOwner = newOwner;
    }
}



contract ERC20TokenFactory is Ownable{

    address[] public ASTs;
    mapping(address=>uint) public AATYConvertion;
    address public poolwallet;
    uint TokenCount=1;
    address aatytoken;

    function SetAATYContrct(address _token) public onlyOwner returns(bool){
        require(_token!=address(0),"Invalid Address");
        aatytoken=_token;
        return true;
    }

    function SetPoolWallet(address _wallet) public onlyOwner{
        require(_wallet!=address(0),"Invalid Address");
        
        poolwallet=_wallet;
        
    }

    //_ratio=2;  2AST=1AATY

    function CreateASTToken(string memory name_, string memory symbol_, uint8 decimal_, uint256 totalSupply_ ,uint256 _ratio) public onlyOwner returns (AST) {
        require(_ratio>0,"Invalid Amount");
        require(aatytoken!=address(0),"AATY Token Not Set");
        require(poolwallet!=address(0),"Invalid Pool Wallet");
        
        AST token= new AST(name_ , symbol_ , decimal_, totalSupply_);
        ASTs.push(address(token));
        TokenCount++;

        
        AATYConvertion[address(token)]=_ratio;
        
        IAATY(aatytoken).Mint((totalSupply_/2)/_ratio,poolwallet);

        return token;
    }

    function ASTConvertionAmount(address _astToken,uint256 _aatyAmount) external view returns(uint256 astamt_,uint256 needToBurn){
        require(_astToken!=address(0),"Invalid Address");
        require(_aatyAmount>0,"Invalid Amount");
        uint256 convratio=AATYConvertion[_astToken];
         needToBurn=IAST(_astToken).totalSupply()-IAST(_astToken).balanceOf(_contractOwner);
         astamt_=_aatyAmount*convratio;

         return (astamt_,needToBurn);
    }

    function AATYBurnAmount(address _astToken) public view returns(uint256 aatyamt_){
        require(_astToken!=address(0),"Invalid Address");
        
        return aatyamt_=(IAST(_astToken).totalSupply()-IAST(_astToken).balanceOf(_contractOwner))/AATYConvertion[_astToken];
    }

    function returnAstToLockedOwner(address _astToken,uint256 _astAmount) external returns(bool) {
        require(_astToken!=address(0),"Invalid Address");
        require(_astAmount>0,"Invalid Amount");

        IAST(_astToken).transfer(_contractOwner,_astAmount);
        return true;
    }

    function burnAstToken(address _astToken) public onlyOwner returns(bool){
        require(_astToken!=address(0),"Invalid Address");
        IAST(_astToken).burn(IAST(_astToken).balanceOf(_contractOwner),msg.sender);

        return true;
    }

    function balanceOf(address _astToken,address _user) public view returns(uint256,uint256){
            return (IAST(_astToken).totalSupply(),IAST(_astToken).balanceOf(_user));
    }

    
    
}