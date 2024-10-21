// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./DarkDOGEcoin.sol";

contract Create {
    event ContractAddress(address contractAddress);
    address addr;
    address charityWallet = 0x8bCAdD633b090678EE5dF92D8Bed797406bFec4B;
    address marketingWallet = 0x453a4192Abb2c30af0f5fb397Fa604F41d86fa25;
    address initialOwnerAddress = 0x4E0BdcfBAF1A59C78270e1164e571697489783CB;
    bytes public creationCode = type(DARKDOGECOIN).creationCode;

    // Function to deploy the contract using a string as the salt
    function deployContract(bytes32 _salt) external returns (bool) {
        // bytes32 salt = stringToBytes32(_salt);
        //    bytes32 salt = bytes32(_salt);

        
        addr = Create2.deploy(
            0,
            _salt,
            abi.encodePacked(type(DARKDOGECOIN).creationCode, abi.encode(charityWallet, marketingWallet,initialOwnerAddress))
        );
        
        emit ContractAddress(addr);
        return true;
    }

    // perfect working with two digit like:- 0x24
    //please enter only 2 digit like :- 0x47
     function findAddressWithPrefix(uint256 start,uint256 end,bytes memory startCode) public view returns (bytes32, address) {
        bytes32 salt;
        address generatedAddress;

        // Loop through 100,000 iterations to generate addresses
        for (uint256 i = start; i < end; i++) {
            // Use the loop index (i) as the unique salt for each iteration
            salt = bytes32(i);

            // Generate the contract address using CREATE2
            generatedAddress = Create2.computeAddress(
            salt,
            keccak256(abi.encodePacked(type(DARKDOGECOIN).creationCode, abi.encode(charityWallet, marketingWallet,initialOwnerAddress)))
        );

            // Check if the generated address starts with the passed prefix (startCode)
            bool matchFound = true;
            for (uint256 j = 0; j < startCode.length; j++) {
                if (bytes20(generatedAddress)[j] != startCode[j]) {
                    matchFound = false;
                    break;
                }
            }

            // If the address matches the prefix, return the salt and generated address
            if (matchFound) {
                return (salt, generatedAddress);
            }
        }

        // Return empty values if no matching address is found
        return (bytes32(0), address(0));
    }
}