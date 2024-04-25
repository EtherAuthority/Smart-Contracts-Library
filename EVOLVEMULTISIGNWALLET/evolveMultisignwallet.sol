// SPDX-License-Identifier: MIT
pragma solidity 0.8.17; 

interface AnotherContract {
    function ownerFunction() external ;
}

contract MultiSignWallet{

    //--------------------Storage-------------------

    address[] public owners;
    mapping(address=>bool) public isOwner;

    AnotherContract public otherContract;

    uint256 public WalletRequired;
    Transaction[] public transactions;
    mapping(uint256=> mapping(address=>bool)) public approved;

    struct Transaction{
        bool  isExecuted;
    }

    /*
    Constructor function to initialize the MultiSigWallet contract with a list of owners,
    the required number of owner wallets for transaction execution, and the address of
    another contract to interact with.
    Parameters:
    - _owners: An array of addresses representing the owners of the MultiSigWallet.
    - _requiredWallet: The minimum number of owner wallets required to execute a transaction.
    - otherContractAddress: The address of another contract with owner functions that can
      be executed by this MultiSigWallet.
    It validates the inputs, initializes the owners, sets the required number of owner wallets,
    and initializes the interface with the specified address for interacting with the other contract.
    */
    constructor(address[] memory _owners,uint256 _requiredWallet,address otherContractAddress){
        require(_owners.length>0,"owner required");
        require(_requiredWallet>0 && _requiredWallet<=_owners.length,"invalid required number of owner wallets");

        for(uint256 i=0;i<_owners.length;i++){

            address owner = _owners[i];
            require(owner!=address(0),"invalid owner");
            require(!isOwner[owner],"owner is already there!");
            isOwner[owner]=true;
            owners.push(owner);

        }

        WalletRequired =_requiredWallet; // you need at least this number wallet to execute transaction
        otherContract = AnotherContract(otherContractAddress);
    }


    //-----------------------EVENTS-------------------

    event assignTrnx(uint256 trnx);
    event Approve(address owner, uint256 trnxId);
    event Revoke(address owner, uint256 trnxId);
    event Execute(uint256 trnxId);

    //----------------------Modifier-------------------

    modifier onlyOwner(){
        require(isOwner[msg.sender],"you are not the owner");
        _;
    }

    modifier trnxExists(uint256 _trnxId){
        require(_trnxId<transactions.length,"trnx does not exist");
        _;
    }

    modifier notApproved(uint256 _trnxId){
        require(!approved[_trnxId][msg.sender],"trnx has already done");
        _;
    }

    modifier notExecuted(uint256 _trnxId){
        Transaction storage _transactions = transactions[_trnxId];
        require(!_transactions.isExecuted,"trnx has already executed");
        _;
    }

    /*
    Adds a new transaction to the MultiSigWallet.
    Each transaction is represented by a Transaction struct,
    initialized with the flag isExecuted set to false.
    This function can only be called by the owners of the wallet.
    Returns: The ID of the newly created transaction.
    */
    function newTransaction() external onlyOwner returns(uint256){
        transactions.push(Transaction({
            isExecuted:false
        }));

        emit assignTrnx(transactions.length-1);
        return transactions.length-1;
    }

    /*
    Allows an owner to approve a transaction identified by its ID.
    The transaction must exist, must not have been previously approved,
    and must not have been executed.
    If the approval count reaches the required number of approvals,
    the transaction is automatically executed.
    Parameters:
    - _trnxId: The ID of the transaction to approve.
    */
    function approveTransaction(uint256 _trnxId)
     external onlyOwner
     trnxExists(_trnxId)
     notApproved(_trnxId)
     notExecuted(_trnxId)

    {
        approved[_trnxId][msg.sender]=true;
        emit Approve(msg.sender,_trnxId);
        if(_getAprrovalCount(_trnxId) >= WalletRequired){
            executeTransaction(_trnxId); 
        }
    }

    // GET APPROVAL COUNT OF TRANSACTION
    function _getAprrovalCount(uint256 _trnxId) public view returns(uint256 ){

        uint256 count;
        for(uint256 i=0; i<owners.length;i++){

            if (approved[_trnxId][owners[i]]){

                count+=1;
            }
        }

        return count;
     
    }

    /*
    Executes a transaction identified by its ID.
    The transaction must exist and must not have been previously executed.
    If the required number of approvals is met, the function calls the ownerFunction
    of the other contract and marks the transaction as executed.
    Parameters:
    - _trnxId: The ID of the transaction to execute.
    */
    function executeTransaction(uint256 _trnxId) internal trnxExists(_trnxId) notExecuted(_trnxId){
        require(_getAprrovalCount(_trnxId)>=WalletRequired,"you don't have sufficient approval");
        Transaction storage _transactions = transactions[_trnxId];
        otherContract.ownerFunction();
        _transactions.isExecuted = true;
        emit Execute(_trnxId);

    }

    /*
    Allows an owner to revoke their approval for a transaction identified by its ID.
    The transaction must exist and must not have been previously executed.
    The calling owner must have previously approved the transaction.
    Parameters:
    - _trnxId: The ID of the transaction to revoke approval for.
    */
    function revoke(uint256 _trnxId) external
    onlyOwner
    trnxExists(_trnxId)
    notExecuted(_trnxId)
    {
        require(approved[_trnxId][msg.sender],"trnx has not been approve");
        approved[_trnxId][msg.sender]=false;

       emit Revoke(msg.sender,_trnxId);
    }
}

// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
