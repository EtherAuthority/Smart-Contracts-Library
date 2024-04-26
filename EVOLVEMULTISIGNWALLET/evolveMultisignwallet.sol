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
    }

    struct UpdateGasSetting{
        uint validatorPer;
        uint burnPartPer;
        uint burnStopPer;
        uint coinPoolPer;
        uint ownerPoolPer;
        uint foundationPer;
    }
    UpdateGasSetting[] public updateGasSettingInfo;

    struct TransferOwnerTo{
        address to;
        bool  isExecuted;
        string txType;
    }

    TransferOwnerTo[] public transferOwner;

    struct UpdateParam{
       address foundationWal;
       address ownPool;
       address cPool;
       uint256 ownerPoolCoLimit;
       uint16 maxvaldt;
       uint256 minStakCoin;
       uint256 minValStk;
    }
   
   UpdateParam[] public paramsInfo;

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
        validatorContract = Ivalidator(otherContractAddress);
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

    function transferOwnership(address _to) external onlyOwner returns(uint256){
       transferOwner.push(TransferOwnerTo({
        to:_to,
        isExecuted:false,
        txType:"transferOwnership"

       }));


        transactions.push(Transaction({
        isExecuted:false,
        functionTracker:4
        }));
        emit AssignTransferOwnershipTx(transactions.length-1);
        return transactions.length-1;
    }

    function renounceOwnership() external onlyOwner returns(uint) {
        emit AssignUpdateGasTx(transactions.length-1);
        transactions.push(Transaction({
        isExecuted:false,
        functionTracker:3
        }));
        emit AssignRenounceOwnershipTx(transactions.length-1);
        return transactions.length-1;
    }

    function updateGasSettings(uint _validatorPer,uint _burnPartPer,uint _burnStopPer,uint _coinPoolPer,uint _ownerPoolPer,uint _foundationPer) external onlyOwner returns(uint256){
        updateGasSettingInfo.push(UpdateGasSetting({
            validatorPer: _validatorPer,
            burnPartPer:_burnPartPer,
            burnStopPer:_burnStopPer,
            coinPoolPer:_coinPoolPer,
            ownerPoolPer:_ownerPoolPer,
            foundationPer:_foundationPer
        }));
         
        transactions.push(Transaction({
        isExecuted:false,
        functionTracker:1
        }));
        emit AssignUpdateGasTx(transactions.length-1);
        return transactions.length-1;
    }

    function updateParams(address _foundationWal,address _ownPool,address _cPool,uint _ownerPoolCoLimit,uint16 _maxvaldt, uint256 _minStakCoin, uint256 _minValStk) external onlyOwner returns(uint256){
        paramsInfo.push(UpdateParam({
            foundationWal:_foundationWal,
            ownPool:_ownPool,
            cPool:_cPool,
            ownerPoolCoLimit:_ownerPoolCoLimit,
            maxvaldt:_maxvaldt,
            minStakCoin:_minStakCoin,
            minValStk:_minValStk
        }));


        transactions.push(Transaction({
        isExecuted:false,
        functionTracker:2
        }));
        emit AssignparamUpdateTx(transactions.length-1);
        return transactions.length-1;
    }


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


    function executeTransaction(uint256 _trnxId) internal trnxExists(_trnxId) notExecuted(_trnxId){
        require(_getAprrovalCount(_trnxId)>=WalletRequired,"you don't have sufficient approval");
        Transaction storage _transactions = transactions[_trnxId];

        if(_transactions.functionTracker == 1)
        {
                UpdateGasSetting  storage _updateGasSettings = updateGasSettingInfo[updateGasSettingInfo.length-1];
                validatorContract.updateGasSettings(_updateGasSettings.validatorPer,_updateGasSettings.burnPartPer,
                _updateGasSettings.burnStopPer, _updateGasSettings.coinPoolPer,
                _updateGasSettings.ownerPoolPer, _updateGasSettings.foundationPer);
                
        }
        else if(_transactions.functionTracker == 2){
                UpdateParam  storage _updateParams = paramsInfo[paramsInfo.length-1];
                validatorContract.updateParams(_updateParams.foundationWal,_updateParams.ownPool, _updateParams.cPool,
                _updateParams.ownerPoolCoLimit, _updateParams.maxvaldt, _updateParams.minStakCoin,
                _updateParams.minValStk);
                
        }
         else if(_transactions.functionTracker == 3){
                validatorContract.renounceOwnership();
                
        }
         else if(_transactions.functionTracker == 4){
                TransferOwnerTo storage _transferOwnership = transferOwner[transferOwner.length-1];
                validatorContract.transferOwnership(_transferOwnership.to);
                
        }

        _transactions.isExecuted=true;
        emit Execute(_trnxId);

    }

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

// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
