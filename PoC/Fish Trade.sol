pragma solidity 0.5.1; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



███████╗██╗███████╗██╗  ██╗    ████████╗██████╗  █████╗ ██████╗ ███████╗
██╔════╝██║██╔════╝██║  ██║    ╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝
█████╗  ██║███████╗███████║       ██║   ██████╔╝███████║██║  ██║█████╗  
██╔══╝  ██║╚════██║██╔══██║       ██║   ██╔══██╗██╔══██║██║  ██║██╔══╝  
██║     ██║███████║██║  ██║       ██║   ██║  ██║██║  ██║██████╔╝███████╗
╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
                                                                        



THE LOGIC:

A buys 5 kg fresh fish of good quality from B for 12 Ether. 

B sends the order, as soon as the escrow receives the money from A. The fish must be delivered the next day (1st of February 2019) to A. 
If -    5 KG of the fish; In a good quality; Is Delivered on time -> B will get the money from the escrow. 


MAIN COMPONENTS
=> Ownership of contract
=> Oracle system
=> Main Fish Trade
=> Escrow system



POSSIBLE EVENTS: 
If the fish is not of good quality: A has to report to B that the fish is not of good quality. 
If A reports that the fish is not of good quality in 2 hours, A will get his money back from the escrow.
If the fish is not delivered in time, that means not on the 1st of February 2019:
If the fish does not get delivered to A in time, that means not on the 1st of February 2019, A will get his money back from the escrow. 

If A doesn’t accept the delivery: If A does not accept the right delivery, 
(The delivery is right when: -  The delivery of 5kg fish -  In Good Quality -   On the 1st of February 2019. -  At A’s place. ) 
B still gets the money from the escrow.

The data about fish is coming from the Oracle, which handled by the Oracle Contract


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

//*******************************************************************//
//--------------------- Contract for Oracle -------------------------//
//*******************************************************************//
        
    contract Oracle is owned {
        
        /* Public variables of Oracle  */
        bool fishQuality;
        uint256 fishQuantity;
        uint256 deliveryDate;
        
        /* Struct which holds all the requests received by the oracle for the logging purpose */
        struct Request {
            bool fishQuality;
            uint256 fishQuantity;
            uint256 deliveryDate;
        }
        
        /* This array will hold all the structs */
        Request[] requests;
        
        
        /**
         * @dev This event will be emitted when there is need to update the Fish data
         * @dev Which will cause oracle script, who listen for this event, to respond
         * @dev Which will then call reply() function with valid parameters which will be unpdate in smart contract
         * @dev parameter will be requet ID used to validate the each request
         */
        event NewRequest();
        
        
        /**
         * @dev This function will be called to request data from outside source
         * @dev It will emit event for oracles
         * 
         * 
         */
        function queryOracle() public {
            emit NewRequest();
        }
        
        /**
         * @dev This function will be called by the Oracle to supply the data to update the smart contract
         * @dev To check validity of the response, we will be making sure the caller must be owner
         * 
         * @param fishQualityNew The quality of the fish, data provided by Oracle
         * @param fishQuantityNew The quantity of the fish, data provided by Oracle
         * @param deliveryDateNew The delivery date of the fish, data provided by Oracle
         */
        function responseFromOracle(bool fishQualityNew, uint256 fishQuantityNew, uint256 deliveryDateNew) public onlyOwner {
            
            //validate the incoming data
            require(fishQuantityNew > 0 && fishQuantityNew <= 5);
            require(deliveryDateNew > 0 && deliveryDateNew <= 999999999999999999);  //this is to prevent over flow or under flow
            
            // update the fish data
            fishQuality = fishQualityNew;
            fishQuantity = fishQuantityNew;
            deliveryDate = deliveryDateNew;
            
            // adding those data into an struct and array for the logging purpose
            requests.push(Request(fishQualityNew, fishQuantityNew, deliveryDateNew));
        }
        
        
    }    
    
   

//*********************************************************************//
//------------------ FishTrade Contract Starts Here -------------------//
//*********************************************************************//
    
    contract FishTrade is owned, Oracle {
        
        /***********************************/
        /*     Use case of Fish Trade      */
        /***********************************/


        /**
         * @dev Payable function. As for our case, it will only accept 12 Ether
         * @dev Buyer (person A) will send money to escrow using this function 
         * @dev Buyer also have to specify the Seller address
         * @dev The reason to specify Seller is because it will tag to this trade. 
         * @dev So, when buyer will release escrow, then fund will be transfered to seller
         * 
         * @param _seller The address of seller
         */ 
        function buyerDeposit(address _seller) payable public {
            require(msg.value == 12 ether, 'Ether value must be 12 Ether');
            payToEscrow(_seller);
        }        
        
        
        /**
         * @dev This function must be called by seller to check if buyer has deposited 12 ether 
         * 
         * @param _buyer The address of the buyer
         * @param _seller The address of the seller
         * @param timestamp The timestamp of the trade.
         * @param ethAmountWEI The amount of ether in WEI
         * 
         * @return bool true or false, whether buyer paid or not
         */
        function paymentConfirmationCheck(address _buyer, address _seller, uint256 timestamp, uint256 ethAmountWEI) public view returns(bool paid) {
            
            /* Calculating the hash from given parameters */
            bytes32 hash = keccak256(abi.encodePacked(this, _buyer, _seller, timestamp, ethAmountWEI));
            
            /* For our case, it should be 12 Ether */
            require( escrowBalance[_buyer][_seller][hash] == 12 ether , 'Transaction amount is zero. Most probably the input parameters are invalid.');            
            
            return paid;
            
        }
        
        /**
         * @dev This function called by buyer (Person A) when the delivery arrives 
         * @dev The data of fish coming from the Oracle
         * 
         * @dev If fish is not in good quality as well as delivery is not on time, then refund buyer
         * @dev If delivery is right and buyer accepts it, then release escrow and payment sent to seller
         * 
         * @param _seller Address of seller
         * @param ethAmountWEI The amount of ether
         * @param orderTimestamp The timestamp of order
         * 
         */
        function fishDelivered( address payable _seller, uint256 ethAmountWEI, uint256 orderTimestamp ) public {
            
            /* Getting fish data updates from Oracle */
            queryOracle();
            
            /* If A reports that the fish is not of good quality in 2 hours, A will get his money back from the escrow. */
            if(fishQuality == false){  //false means no good!
                refundBuyer(_seller, ethAmountWEI, orderTimestamp);
            }
            
            /* If the fish does not get delivered to A in time, that means not on the 1st of February 2019, A will get his money back from the escrow.  */
            if(deliveryDate != 1548979200){  //1548979200 = 01 Feb 2019 00:00:00 
                refundBuyer(_seller, ethAmountWEI, orderTimestamp);
            }
            
            /* If delivery is right, and buyer (person A)  accept it then payment sent to seller (Person B) */
            if(isRightDelivery()){
                releaseEscrow(msg.sender, address(_seller), orderTimestamp, ethAmountWEI);
            }
        
        }
        
        
        /**
         * @dev This function called by seller (Person B) when buyer (Person A) does not accept the delivery
         * @dev Escrow is relased and seller (Person B) gets the money
         * 
         * @param _buyer Address of buyer
         * @param ethAmountWEI The amount of ether
         * @param orderTimestamp The timestamp of order
         */
        function deliveryNotAccepted(address _buyer, uint256 ethAmountWEI, uint256 orderTimestamp) public {
            releaseEscrow(_buyer, msg.sender, orderTimestamp, ethAmountWEI);
        }
        
        
        /**
         * @dev This function checks whether delivery is right or not
         * @dev It considers the data updated by the Oracle
         * 
         * @return bool returns whether this is right delivery or not
         */
        function isRightDelivery() internal view returns(bool) {
            
            /* Fish quantity must be true=good */
            if(fishQuality != true){
                return false;
            }
            
            /* Fish quantity must be 5 Kg  */
            else if(fishQuantity != 5){
                return false;
            }
            
            /* Delivery date must be 01 Feb 2019  */
            else if(deliveryDate != 1548979200){   //01 Feb 2019 00:00:00 
                return false;
            }
            
            /* The deivery is right then return true */
            else{
                return true;
            }
        }
        
        
        
        /*********************************/
        /*      Section for Escrow       */
        /*********************************/
        
        /*  Mapping which will map buyer address with seller, unique transaction hash and their ETH amount  */
        mapping (address => mapping (address => mapping (bytes32 => uint256))) public escrowBalance;
        
        /* Events which logs all the transactions  */
        event EscrowDeposit(address buyer, address seller, uint256 ethAmount, uint256 timestamp, bytes32 txnHash );
        event ReleaseEscrow(address buyer, address seller, uint256 ethAmount, uint256 timestamp, bytes32 txnHash );
        
        /**
         * @dev Buyer will send money to escrow using this function 
         * @dev To make every transaction unique, we will create a simple transaction ID
         * 
         * @param _seller The address of the seller, which should be specified by buyer
         * @return success Whether payment to escrow was a success or not
         */
        function payToEscrow(address _seller) internal {
            
            /* Validating the user input  */
            require(msg.value > 0, 'Ether amount must be more than zero');
            require(_seller != address(0), 'Seller address is invalid');
            
            /*  Calculating the transaction has from the user inputf  */
            bytes32 hash = keccak256(abi.encodePacked(this, msg.sender, _seller, now, msg.value));
            
            /*  Adds the amount in Escrow balance mappubg   */
            escrowBalance[msg.sender][_seller][hash] = msg.value;
            
            /*  Emitting the event  */
            emit EscrowDeposit(msg.sender, _seller, msg.value, now, hash );
        
        }
        
        
        /**
         * Once Fishes received, then buyer will release escrow
         * It will calculate the transaction hash again from the input parameter to verify the transaction
         * 
         * @param _buyer The address of the buyer
         * @param _seller The address of the seller
         * @param ethAmountWEI The amount of ether in WEI
         * @param timestamp The timestamp of the trade.
         * 
         */
        function releaseEscrow(address _buyer, address payable _seller, uint256 timestamp, uint256 ethAmountWEI) internal {
            
            /* Calculating the hash from given parameters */
            bytes32 hash = keccak256(abi.encodePacked(this, _buyer, _seller, timestamp, ethAmountWEI));
            
            require( escrowBalance[_buyer][_seller][hash] > 0 , 'Transaction amount is zero. Most probably the input parameters are invalid.');            
            
            /* Setting Escrow amount to zerp */
            escrowBalance[_buyer][_seller][hash] = 0;
            
            /* Transferring the ETH to seller  */
            address(_seller).transfer(ethAmountWEI);
            
            /* Emitting the event */
            emit ReleaseEscrow(msg.sender, _seller, ethAmountWEI, timestamp, hash );
            
        }
        
        
        function refundBuyer(address _seller, uint256 ethAmountWEI, uint256 timestamp) public {
            
            /* Calculating the hash from given parameters */
            bytes32 hash = keccak256(abi.encodePacked(this, msg.sender, _seller, timestamp, ethAmountWEI));
            
            require( escrowBalance[msg.sender][_seller][hash] > 0 , 'Transaction amount is zero. Most probably the input parameters are invalid.');            
            
            /* Setting Escrow amount to zerp */
            escrowBalance[msg.sender][_seller][hash] = 0;
            
            /* Transferring the ETH to seller  */
            address(msg.sender).transfer(ethAmountWEI);
            
            /* Emitting the event */
            emit ReleaseEscrow(msg.sender, _seller, ethAmountWEI, timestamp, hash );
            
        }
        
        

      
}
    

   
