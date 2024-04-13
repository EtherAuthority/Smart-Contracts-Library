// SPDX-License-Identifier: MIT
pragma solidity 0.8.25; 

// ERC20 Token contract interface
interface Token {    
    function transfer(address to, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function balanceOf(address to) external returns(uint256);
    function decimals() external view returns (uint8);
}

contract Vesting { 
    address public immutable tokenContract; // Address of the token contract   
    uint256 private immutable onemonth = 31 days; // set onemonth
    uint256 public immutable maxWalletLimit=100; //set wallet limit
    uint256 public immutable maxVestingTime=100; // set vesting time limit
    uint256 private totalNoOfvesting=0; //set total number of vesting
    uint256 private totalVestingAMT; // set total vesting amount 

    // Mapping to store locked token amounts for each wallet
    mapping(address => uint256) private lockingWallet;

    // Mapping to store locked token amounts for each wallet
    mapping(address => uint256) public lockedAmount;
    
    // Mapping to store vesting periods for each wallet
    mapping(address => uint256) public vestingTime;
    
    // Mapping to store cliff periods for each wallet
    mapping(address => uint256) public cliffperiod;

    // Mapping to store starting withdrawable amount of each wallet
    mapping(address => uint256) public readytoUseAmt;
    
    // Mapping to store unlock dates for each wallet
    mapping(address => uint256) public unlockDate;

    // Struct to store withdrawal details
    struct _withdrawdetails {
        uint256 time; // Timestamp of the withdrawal
        uint256 amount; // Amount withdrawn
    }
    mapping(address=>mapping(uint=>_withdrawdetails)) public withdrawdetails;
    // Event to log token withdrawals
    event withdraw(address indexed _to, uint256 _amount);
  
    /**
    * @dev Constructor function to initialize the vesting contract.   
    * @param _tokenContract The address of the token contract.
    */
    constructor(address _tokenContract) {          
        tokenContract = _tokenContract; // Set the address of the token contract             
    } 

    /**
    * @dev Function to add investors and initialize vesting parameters for each investor.
    * @param _wallet An array of addresses representing the wallets of the investors.
    * @param _tokenamount An array of token amounts corresponding to each investor.
    * @param _vestingTime An array of vesting periods in months for each investor.
    * @param _cliffperiod An array of cliff periods in months for each investor.
    * @param _readytoUsePercentage An array of percentages representing the portion of tokens ready to use for each investor.
    * Auditor Note:- To overcome infinite loop of wallet length, we set max wallet array limit, to any one can add only 100 wallet addresses Max.
    *                To overcome infinite loop of vesting time array length, we set max vesting time limit, to any one can add only 100 months Max.
    **/
    
    function createVesting(
        address[] memory _wallet,
        uint[] memory _tokenamount,
        uint[] memory _vestingTime,
        uint[] memory _cliffperiod,
        uint[] memory _readytoUsePercentage       
    ) public { 
       
        require(Token(tokenContract).balanceOf(msg.sender)>0,"Only token holder can create vesting!");
        // Validate input parameter lengths
        require(
            _wallet.length == _tokenamount.length && 
            _wallet.length == _vestingTime.length &&
            _wallet.length == _cliffperiod.length &&
            _wallet.length == _readytoUsePercentage.length,
            "Please check parameter values"
        );

        // check max wallet limit
        require(maxWalletLimit >= _wallet.length ,"You can add maximum 100 wallets!");
       
         // Initialize vesting parameters for each wallet
        for(uint i = 0; i < _wallet.length; i++) {  
            
            if(_tokenamount[i]>0 && _vestingTime[i]>0 && _readytoUsePercentage[i] >0){ 

            require(_wallet[i]!=address(0),"Please add valid wallet address!"); 
            require(_readytoUsePercentage[i] <= 100,"You can add maximum 100 Percentage!");
            readytoUseAmt[_wallet[i]]=((_tokenamount[i]) * _readytoUsePercentage[i]) / 100;
            
            require(lockingWallet[_wallet[i]] == 0, "Wallet Address is already Exist");              
            require(maxWalletLimit > totalNoOfvesting,"You can add maximum 100 wallets!");
            lockingWallet[_wallet[i]] = ((_tokenamount[i]) * (100-_readytoUsePercentage[i])) / 100; // Set the locked token amount for the wallet
            lockedAmount[_wallet[i]] = lockingWallet[_wallet[i]];
            totalVestingAMT += _tokenamount[i]; // all wallet token amount

            require(maxVestingTime >= _vestingTime[i],"You can add maximum 100 months!");
            vestingTime[_wallet[i]] = _vestingTime[i]; // Set the vesting period for the wallet

            require(maxVestingTime >= _cliffperiod[i],"You can add maximum 100 months!");
            cliffperiod[_wallet[i]] = _cliffperiod[i]; // Set the cliff period for the wallet
            
            // Calculate and set the unlock date for the wallet based on the cliff period
            unlockDate[_wallet[i]] = block.timestamp + (_cliffperiod[i] * (31 days)); 
            totalNoOfvesting++; 
            }             
        } 
        // transfer total vesting amount to the vesting contract
        Token(tokenContract).transferFrom(msg.sender,address(this),totalVestingAMT);       
    }   

    /**
    * @dev View the number of completed vesting months for the specified user.
    * @param user The address of the user for whom the completed vesting months are being viewed.
    * @return The number of completed vesting months.   
    */
    function CompletedVestingMonth(address user) public view returns(uint){
        uint vestingMonth = 0; // Initialize the number of completed vesting months        

            // Iterate over the vesting periods
            for(uint i = 0; i < vestingTime[user]; i++) { 
                // Ensure the unlock date has passed for the current period
                if(unlockDate[user] <= block.timestamp){ 
                
                    // Check if the current period's unlock date has been reached
                    if(block.timestamp >= unlockDate[user] + (onemonth * i)) { 
                        // Check if the withdrawal for this period has not already occurred
                        if(withdrawdetails[user][i].time == 0) { 
                            // Increment the count of completed vesting months
                            vestingMonth++;                        
                        } 
                    } else { 
                        break; // Exit loop if the current period is not yet unlocked 
                    } 
                }
            } 
        
        return vestingMonth; // Return the number of completed vesting months 
    }
   
    /**
    * @dev View the total vesting amount available for withdrawal by the specified user.
    * @param user The address of the user for whom the vesting amount is being viewed.
    * @return The total vesting amount available for withdrawal.    
    */
    function withdrawableAmount(address user) public view returns (uint){ 
        uint vestingAmt = 0; // Initialize the vesting amount
        
            // Iterate over the vesting periods
            for(uint i = 0; i < vestingTime[user]; i++) { 
                // Ensure the unlock date has passed for the current period
                if(unlockDate[user] <= block.timestamp){         
                    // Check if the current period's unlock date has been reached
                    if(block.timestamp >= unlockDate[user] + (onemonth * i)) { 
                    // Check if the withdrawal for this period has not already occurred
                        if(withdrawdetails[user][i].time == 0) { 
                        // Accumulate the vesting amount
                        vestingAmt += lockingWallet[user] / vestingTime[user];                        
                        } 
                    } else { 
                        break; // Exit loop if the current period is not yet unlocked 
                    } 
                }
            } 
        
        return (readytoUseAmt[user]+vestingAmt); // Return the total vesting amount 
    }
    
    /**
    * @dev Allows users to withdraw tokens based on a vesting schedule.
    * @return A boolean indicating the success of the withdrawal operation.
    */
    function withdrawTokens() public returns (bool){
        // Ensure the sender has a locked wallet
        require(lockingWallet[msg.sender] > 0, "Wallet Address is not Exist");

        // Initialize the withdrawal amount
        uint withdrawAMT = 0; 
       
            // Iterate over the vesting periods
            for(uint i = 0; i < vestingTime[msg.sender]; i++) {
                // Ensure the unlock date has passed for the current period
                if(unlockDate[msg.sender] <= block.timestamp){ 
            
                    // Check if the current period's unlock date has been reached
                    if(block.timestamp >= unlockDate[msg.sender] + (onemonth * i)) {
                        // Check if the withdrawal for this period has not already occurred
                        if(withdrawdetails[msg.sender][i].time == 0) {
                            // Calculate and accumulate the withdrawal amount
                            withdrawAMT += (lockingWallet[msg.sender] / vestingTime[msg.sender]); 
                            // Record the withdrawal details
                            withdrawdetails[msg.sender][i] = _withdrawdetails(block.timestamp, (lockingWallet[msg.sender] / vestingTime[msg.sender]));
                        }
                        
                    } else {
                        break; // Exit loop if the current period is not yet unlocked
                    }
                }
            }

         
        
        withdrawAMT=(withdrawAMT+readytoUseAmt[msg.sender]);
        require(withdrawAMT!=0, "Unable to Withdraw"); 

        
        
        // Transfer the accumulated withdrawal amount to the sender
        Token(tokenContract).transfer(msg.sender, withdrawAMT);
        lockedAmount[msg.sender]=lockedAmount[msg.sender]-(withdrawAMT-readytoUseAmt[msg.sender]);
        readytoUseAmt[msg.sender]=0;
    
        // Emit an event to log the withdrawal
        emit withdraw(msg.sender, withdrawAMT);
    
        // Return success
        return true;
    }
}
