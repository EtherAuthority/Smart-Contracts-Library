pragma solidity 0.5.2; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_


    
     ██████╗ █████╗               ██████╗  █████╗ ████████╗ █████╗ 
    ██╔════╝██╔══██╗              ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
    ██║     ███████║    █████╗    ██║  ██║███████║   ██║   ███████║
    ██║     ██╔══██║    ╚════╝    ██║  ██║██╔══██║   ██║   ██╔══██║
    ╚██████╗██║  ██║              ██████╔╝██║  ██║   ██║   ██║  ██║
     ╚═════╝╚═╝  ╚═╝              ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
                                                                   
                                                                   

THE MAIN LOGIC:

Certificate Authorities (CAs) will be triggered when a 3 type of Process Type (Revoked, Hold, Unhold) is occurred. 
All CAs needs to have a blockchain access in order to write/read data to/from blockchain network.
A user certificate can be revoked, holded and unholded if user request it from CA (It’s not our business). 
Our project is starts on this point. When CA triggered for “revoked, holded and unholded” certificate status, CAs will send some information to the Blockchain Platform.
 

THE MAIN COMPONENT OF THE DATA

(1) CA ID: This value will hold CA Certificate ID. It shows that which CA sended this data to the blockchain.  

(2) Certificate Serial No: This value represent serial number for certificate owner. 
(3) Date:Process Date
(4) Process Type: 4 type of certificates will be hold on the blockchain. We will hold a number on this colomn.
    1 => Revoke
    2 => Hold
    3 => Unhold
    4 => Initia certificate issue
(5) Process Reason: This colomn represents process reason. We will hold a number on this column.
    0 => Unknown
    1 => Stolen
    2 => Information Change
    3 => CA Key Stolen
    4 => Get Instead
    5 => Break for a while
    6 => Hold
    7 => Unhold
    8 => Claims
    9 => Initial certificate issue


*/



//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address public owner;
    
     constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}



//*********************************************************************//
//------------------ CA Data Contract Starts Here -------------------//
//*********************************************************************//
    
contract CA_Data is owned {
    
    /****************************************/
    /*     Public Variables of CA Data      */
    /****************************************/
    
    /* Mapping which will hold CA wallet address and return if they are true or false */
    mapping(address => bool) public caWallets;
    
    /* An array which will hold wallet addresses of all the CAs, as well as mapping which holds index of each array element */
    address[] public caWalletsList;
    mapping(address => uint256) public caWalletsListIndex;
    mapping(address => string) public caWalletToID;
    
    /* Struct which holds Certificate Data for any particular certificate ID */
    struct CertificateDataIndividual {
        uint256 certificateID;
        string domainName;
        address caWallet;
        string caID;
        uint256 date;
        uint256 processType;
        uint256 processReason;
    }
    
    /* Mapping that maps particular CA ID to certificate ID with struct CertificateDataIndividual  */
    mapping (string => mapping(uint256 => CertificateDataIndividual)) certificateDataAll;
    
    
    
    /* Events which logs all the transaction data and display to GUI */
    event CertificateData(
        uint256 certificateID, 
        string domainName, 
        address indexed caWallet, 
        string caID,
        uint256 date, 
        uint256 processType, 
        uint256 processReason
        );
    
    /* Modifier which requires only CA Caller */
    modifier onlyCA {
        require(caWallets[msg.sender]);
        _;
    }
    
    /**
     * @dev constructor function which will run only once while deploying the contract
     * @dev we will assign all three CA wallet addresses now, which later can be removed by owner if required
     */
    constructor() public {
        
        /* updating mapping caWallets */
        caWallets[0xef9EcD8a0A2E4b31d80B33E243761f4D93c990a8] = true;
        caWallets[0x0086f09Bb9902839bFcE136F8D3c23794dcfDF40] = true;
        caWallets[0x7eF8A233AC746Ea398DED8B0536C83F55FcfCa1F] = true;
        
        /* adding all those addresses in caWalletsList Array  */
        caWalletsList.push(0xef9EcD8a0A2E4b31d80B33E243761f4D93c990a8);
        caWalletsList.push(0x0086f09Bb9902839bFcE136F8D3c23794dcfDF40);
        caWalletsList.push(0x7eF8A233AC746Ea398DED8B0536C83F55FcfCa1F);
        
        /* Updating caWalletsListIndex mapping to index all those array element */
        caWalletsListIndex[0xef9EcD8a0A2E4b31d80B33E243761f4D93c990a8] = 0;
        caWalletsListIndex[0x0086f09Bb9902839bFcE136F8D3c23794dcfDF40] = 1;
        caWalletsListIndex[0x7eF8A233AC746Ea398DED8B0536C83F55FcfCa1F] = 2;
        
        /* adding IDs of respective CA Wallet address */
        caWalletToID[0xef9EcD8a0A2E4b31d80B33E243761f4D93c990a8] = "CAID1";
        caWalletToID[0x0086f09Bb9902839bFcE136F8D3c23794dcfDF40] = "CAID2";
        caWalletToID[0x7eF8A233AC746Ea398DED8B0536C83F55FcfCa1F] = "CAID3";
    }
    
    
    /****************************************/
    /*          CA Only Functions           */
    /****************************************/

    /**
     * @dev This function called by CA only to issue certificate for very first time 
     * @dev CA provides following details
     * 
     * @param certificateID_ Unique numeric ID of the certificate
     * @param domainName_ Name of the domain for which certificate to be issued
     * @param issueDate_ Date of initial issue
     * 
     * @return bool Returns true for successful transaction
     */ 
    function issueCertificate(
        uint256 certificateID_, 
        string memory domainName_,
        uint256 issueDate_
        ) onlyCA public returns(bool) {
            string storage caID = caWalletToID[msg.sender];
            require(certificateDataAll[caID][certificateID_].certificateID == 0, 'Certificate ID is already used');
            certificateDataAll[caID][certificateID_] = CertificateDataIndividual({
                certificateID: certificateID_,
                domainName: domainName_,
                caWallet: msg.sender,
                caID: caID,
                date: issueDate_,
                processType: 4,     // 4 is default status code for initial issue of certificate
                processReason: 9    // 9 is default reason code for initial issue of certificate
            });
            
            emit CertificateData(
                certificateID_, 
                domainName_, 
                msg.sender, 
                caWalletToID[msg.sender],
                issueDate_, 
                4, 
                9
                );
                
            return true;
    }
    
    
    /**
     * @dev This function called by CA only to update certificate for any domain
     * @dev CA provides following details
     * 
     * @param processType_ Type of transaction. It would be from 1-9 as status code
     * @return bool Returns true for successful transaction
     */ 
    function updateCertificate(
        uint256 certificateID_,
        uint256 processType_,
        uint256 processReason_
        ) onlyCA public returns(bool) {
            string storage caID = caWalletToID[msg.sender];
            require(certificateDataAll[caID][certificateID_].certificateID == certificateID_, 'Certificate ID does not exist');
            require(certificateDataAll[caID][certificateID_].caWallet == msg.sender, 'Caller is not authorised CA');
            
            certificateDataAll[caID][certificateID_].date = now; 
            certificateDataAll[caID][certificateID_].processType = processType_; 
            certificateDataAll[caID][certificateID_].processReason = processReason_; 
            
            emit CertificateData(
                certificateID_, 
                certificateDataAll[caID][certificateID_].domainName,
                certificateDataAll[caID][certificateID_].caWallet,
                certificateDataAll[caID][certificateID_].caID,
                certificateDataAll[caID][certificateID_].date,
                certificateDataAll[caID][certificateID_].processType,
                certificateDataAll[caID][certificateID_].processReason
                );
                
            return true;
    }

    
    /****************************************/
    /*      Users read only functions       */
    /****************************************/
    
    /**
     * @dev Users can loop up for any certificate information using its certificate ID
     * @param certificateID_ The certificate ID
     * @return All the information of struct for that particular certificate ID
     * 
     */
    function lookUpCertificate(uint256 certificateID_, string memory _caID) public view returns(uint256, string memory, string memory, uint256, uint256, uint256){
        return (
            certificateDataAll[_caID][certificateID_].certificateID,
            certificateDataAll[_caID][certificateID_].domainName,
            certificateDataAll[_caID][certificateID_].caID,
            certificateDataAll[_caID][certificateID_].date,
            certificateDataAll[_caID][certificateID_].processType,
            certificateDataAll[_caID][certificateID_].processReason
            );
    }
    
    /**
     * @dev Function to see all the CAs authorised to write in the smart contract
     * @return address[] An array of all the CA addresses
     */
    function seeALLCA() public view returns (address[] memory){
        return caWalletsList;
    }
    
    
    /****************************************/
    /*         Owner only functions         */
    /****************************************/
    
    /**
     * @dev Owner can add new CA wallet, who then can write data in the smart contract
     * @dev It will check if CA already exist or not
     * @param caWalletAddress New wallet address of the CA
     * @return bool Returns true for successful transaction
     */
    function addNewCA(address caWalletAddress, string memory caID) onlyOwner public returns(bool){
        
        require(caWalletAddress != address(0), 'Address is invalid');
        require(!caWallets[caWalletAddress], 'CA is already exist');
        
        caWallets[caWalletAddress] = true;
        caWalletToID[caWalletAddress] = caID;
        caWalletsList.push(caWalletAddress);
        caWalletsListIndex[caWalletAddress] = caWalletsList.length-1;
        
        return true;
    }
    
    /**
     * @dev Owner can remove any CA from the system 
     * @dev It will remove CA address from the mapping as well as from the Array along with its index mapping
     * @param caWalletAddress The wallet address of the CA
     * @return bool Returns true for successful transaction
     */
    function removeAnyCA(address caWalletAddress) onlyOwner public returns(bool){
        
        require(caWalletAddress != address(0), 'Address is invalid');
        require(caWallets[caWalletAddress], 'CA does not exist');
        
        caWallets[caWalletAddress] = false;
        caWalletToID[caWalletAddress] = "";
        caWalletsList[caWalletsListIndex[caWalletAddress]] = caWalletsList[caWalletsList.length-1];
        caWalletsListIndex[caWalletsList[caWalletsList.length-1]] = caWalletsListIndex[caWalletAddress];
        caWalletsListIndex[caWalletAddress]=0;
        caWalletsList.length--;
        return true;
    }
    

}
