// SPDX-License-Identifier: MIT
pragma solidity 0.8.17; 

interface Ivalidator {
    function renounceOwnership() external;
    function transferOwnership(address newOwner) external ;
    function updateGasSettings(uint _validatorPartPercent, uint _burnPartPercent,
        uint _burnStopAmount, uint _coinPoolPercent,
        uint _ownerPoolPercent, uint _foundationPercent) external;

    function updateParams(address _foundationWallet, address _ownerPool, address _coinPool,
        uint256 _ownerPoolColLimit, uint16 _MaxValidators, uint256 _MinimalStakingCoin,
        uint256 _minimumValidatorStaking) external;
}

contract MultiSignWallet{

    //--------------------Storage-------------------

    address[] public owners;
    mapping(address=>bool) public isOwner;

    Ivalidator public validatorContract;

    uint256 public WalletRequired;
    Transaction[] public transactions;
    mapping(uint256=> mapping(address=>bool)) public approved;

    struct Transaction{
        bool  isExecuted;
        uint functionTracker;
        string functionName;
    }

    struct UpdateGasSetting{
        uint validatorPartPercent;
        uint burnPartPercent;
        uint burnStopAmount;
        uint coinPoolPercent;
        uint ownerPoolPercent;
        uint foundationPercent;
    }
    UpdateGasSetting public updateGasSettingInfo;

    struct TransferOwnerTo{
        address to;
    }

    TransferOwnerTo public transferOwner;


    struct UpdateParam{
       address foundationWallet;
       address  ownerPool;
       address coinPool;
       uint256 ownerPoolColLimit;
       uint16 maxValidators;
       uint256 minimalStakingCoin;
       uint256 minimumValidatorStaking;
    }
   
   UpdateParam public paramsInfo;

   /*
    Constructor Function:

    - Initializes the contract with provided parameters.
    - Requires at least one owner and a valid number of required wallets.
    - Validates and adds owners to the contract.
    - Sets required wallets for transaction execution.
    - Assigns the address of another contract interface.

    Parameters:
    @_owners: Array of owner addresses.
    @_requiredWallet: Number of wallets needed for transaction execution.
    @validatorContractAddress: Address of another contract interface.

    Note:
    Ensure this constructor is only called once during contract deployment.
   */

    constructor(address[] memory _owners,uint256 _requiredWallet,address validatorContractAddress){
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
        validatorContract = Ivalidator(validatorContractAddress);
    }


    //-----------------------EVENTS-------------------

    event AssignRenounceOwnershipTx(uint256 trnx);
    event AssignTransferOwnershipTx(uint256 trnx);
    event AssignUpdateGasTx(uint256 trnx);
    event AssignparamUpdateTx(uint256 trnx);
    event Approve(address owner, uint256 trnxId);
    event Revoke(address owner, uint256 trnxId);
    event Execute(uint256 trnxId);

    //----------------------Modifier-------------------

    modifier onlyOwner(){
        require(isOwner[msg.sender],"you are not the owner");
        _;
    }

    modifier trnxExists(uint256 _trnxId){
        require(_trnxId<transactions.length,"Transaction does not exist");
        _;
    }

    modifier notApproved(uint256 _trnxId){
        require(!approved[_trnxId][msg.sender],"Transaction has already done");
        _;
    }

    modifier notExecuted(uint256 _trnxId){
        Transaction storage _transactions = transactions[_trnxId];
        require(!_transactions.isExecuted,"Transaction has already executed");
        _;
    }

    /*
     Description:
    - Enables an owner to transfer ownership of the contract to another address.
    - Registers the transfer request and logs a new transaction for tracking purposes.

    Parameters:
    @_to: The address to which ownership will be transferred.

    Modifiers:
    - onlyOwner: Restricts execution to only owners.

    Returns:
    - The index of the recorded transaction in the transactions array.

    Note:
    - This function appends a transfer ownership request to the transferOwner array.
    - It also creates a new transaction entry in the transactions array with a functionTracker value of 4.
    - An event is emitted to signify the assignment of a transfer ownership transaction.
   */
    function transferOwnership(address _to) external onlyOwner returns(uint256){
       transferOwner=(TransferOwnerTo({
        to:_to

       }));
        transactions.push(Transaction({
        isExecuted:false,
        functionName:"transferOwnership",
        functionTracker:4
        }));
        emit AssignTransferOwnershipTx(transactions.length-1);
        return transactions.length-1;
    }


   /*
    Description:
    - Allows an owner to renounce their ownership of the contract.
    - Logs a new transaction for tracking purposes and emits events for the renouncement and gas update.

    Modifiers:
    - onlyOwner: Ensures that only owners can execute this function.

    Returns:
    - The index of the recorded transaction in the transactions array.

    Note:
    - This function records a new transaction in the transactions array with a functionTracker value of 3,
      indicating a renouncement of ownership.
    - Emits events to signal the assignment of a gas update transaction and the renouncement of ownership.
   */
    function renounceOwnership() external onlyOwner returns(uint) {
        emit AssignUpdateGasTx(transactions.length-1);
        transactions.push(Transaction({
        isExecuted:false,
        functionName:"renounceOwnership",
        functionTracker:3
        }));
        emit AssignRenounceOwnershipTx(transactions.length-1);
        return transactions.length-1;
    }


   /*
    Function: updateGasSettings

    Description:
    - Allows the contract owner to update gas settings.
    - Records the updated gas settings and logs a new transaction for tracking purposes.

    Parameters:
    @_validatorPartPercent: The percentage of gas allocated for validators.
    @_burnPartPercent: The percentage of gas allocated for burning tokens.
    @_burnStopAmount: The amount at which burning of tokens stops.
    @_coinPoolPercent: The percentage of gas allocated for the coin pool.
    @_ownerPoolPercent: The percentage of gas allocated for the owner pool.
    @_foundationPercent: The percentage of gas allocated for the foundation.

    Modifiers:
    - onlyOwner: Ensures that only owners can execute this function.

    Returns:
    - The index of the recorded transaction in the transactions array.
    */
    function updateGasSettings(uint _validatorPartPercent,uint _burnPartPercent,uint _burnStopAmount,uint _coinPoolPercent,uint _ownerPoolPercent,uint _foundationPercent) external onlyOwner returns(uint256){
        updateGasSettingInfo=(UpdateGasSetting({
            validatorPartPercent: _validatorPartPercent,
            burnPartPercent:_burnPartPercent,
            burnStopAmount:_burnStopAmount,
            coinPoolPercent:_coinPoolPercent,
            ownerPoolPercent:_ownerPoolPercent,
            foundationPercent:_foundationPercent
        }));
         
        transactions.push(Transaction({
        isExecuted:false,
        functionName:"updateGasSettings",
        functionTracker:1
        }));
        emit AssignUpdateGasTx(transactions.length-1);
        return transactions.length-1;
    }

    /*
    Function: updateParams

    Description:
    - Allows the contract owner to update various parameters of the contract.
    - Records the updated parameters and logs a new transaction for tracking purposes.

    Parameters:
    @_foundationWallet: The address of the foundation wallet.
    @_ownerPool: The address of the owner pool.
    @_coinPool: The address of the coin pool.
    @_ownerPoolColLimit: The limit for owner pool collections.
    @_MaxValidators: The maximum number of validators.
    @_MinimalStakingCoin: The minimal staking amount of coins.
    @_minimumValidatorStaking: The minimum staking amount for validators.

    Modifiers:
    - onlyOwner: Ensures that only owners can execute this function.

    Returns:
    - The index of the recorded transaction in the transactions array.
   */
    function updateParams(address _foundationWallet,address _ownerPool,address _coinPool,uint _ownerPoolColLimit,uint16 _MaxValidators, uint256 _MinimalStakingCoin, uint256 _minimumValidatorStaking) external onlyOwner returns(uint256){
        paramsInfo=(UpdateParam({
            foundationWallet:_foundationWallet,
            ownerPool:_ownerPool,
            coinPool:_coinPool,
            ownerPoolColLimit:_ownerPoolColLimit,
            maxValidators:_MaxValidators,
            minimalStakingCoin:_MinimalStakingCoin,
            minimumValidatorStaking:_minimumValidatorStaking
        }));

        transactions.push(Transaction({
        isExecuted:false,
        functionName:"updateParams",
        functionTracker:2
        }));
        emit AssignparamUpdateTx(transactions.length-1);
        return transactions.length-1;
    }

    /*
    Function: approveTransaction

    Description:
    - Allows an owner to approve a transaction.
    - Marks the transaction as approved by the owner and emits an approval event.
    - If the transaction receives the required number of approvals, it is executed.

    Parameters:
    @_trnxId: The ID of the transaction to be approved.

    Modifiers:
    - onlyOwner: Ensures that only owners can execute this function.
    - trnxExists: Ensures that the transaction exists.
    - notApproved: Ensures that the transaction has not been previously approved by the caller.
    - notExecuted: Ensures that the transaction has not been executed.

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

    /*
    Internal Function: _getApprovalCount

    Description:
    - Calculates the number of approvals for a transaction.
    - Iterates through the list of owners and checks if each owner has approved the transaction.
    - Returns the count of approvals.

    Parameters:
    @_trnxId: The ID of the transaction for which to count approvals.

    Returns:
    - The count of approvals for the specified transaction.
   */
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
    Internal Function: executeTransaction

    Description:
    - Executes a transaction by calling the appropriate function on the validator contract.
    - Marks the transaction as executed and emits an execution event.

    Parameters:
    @_trnxId: The ID of the transaction to be executed.

    Modifiers:
    - trnxExists: Ensures that the transaction exists.
    - notExecuted: Ensures that the transaction has not been executed.

    Note:
    - Depending on the functionTracker value of the transaction, different functions on the validator contract are called.
   */
    function executeTransaction(uint256 _trnxId) internal trnxExists(_trnxId) notExecuted(_trnxId){
        require(_getAprrovalCount(_trnxId)>=WalletRequired,"you do not have sufficient approval");
        Transaction storage _transactions = transactions[_trnxId];

        if(_transactions.functionTracker == 1)
        {
                UpdateGasSetting  storage _updateGasSettings = updateGasSettingInfo;
                validatorContract.updateGasSettings(_updateGasSettings.validatorPartPercent,_updateGasSettings.burnPartPercent,
                _updateGasSettings.burnStopAmount, _updateGasSettings.coinPoolPercent,
                _updateGasSettings.ownerPoolPercent, _updateGasSettings.foundationPercent);
                
        }
        else if(_transactions.functionTracker == 2){
                UpdateParam  storage _updateParams = paramsInfo;
                validatorContract.updateParams(_updateParams.foundationWallet,_updateParams.ownerPool, _updateParams.coinPool,
                _updateParams.ownerPoolColLimit, _updateParams.maxValidators, _updateParams.minimalStakingCoin,
                _updateParams.minimumValidatorStaking);
                
        }
         else if(_transactions.functionTracker == 3){
                validatorContract.renounceOwnership();
                
        }
         else if(_transactions.functionTracker == 4){
                TransferOwnerTo storage _transferOwnership = transferOwner;
                validatorContract.transferOwnership(_transferOwnership.to);
                
        }

        _transactions.isExecuted=true;
        emit Execute(_trnxId);

    }

    /*
    Description:
    - Allows an owner to revoke their approval for a transaction.
    - Marks the owner's approval for the transaction as false and emits a revoke event.

    Parameters:
    @_trnxId: The ID of the transaction for which to revoke approval.

    Modifiers:
    - onlyOwner: Ensures that only owners can execute this function.
    - trnxExists: Ensures that the transaction exists.
    - notExecuted: Ensures that the transaction has not been executed.

    Reverts:
    - If the transaction has not been approved by the caller.

    */
    function revoke(uint256 _trnxId) external
    onlyOwner
    trnxExists(_trnxId)
    notExecuted(_trnxId)
    {
        require(approved[_trnxId][msg.sender],"Transaction has not been approve");
        approved[_trnxId][msg.sender]=false;

       emit Revoke(msg.sender,_trnxId);
    }
}


