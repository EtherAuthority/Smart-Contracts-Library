make sure your "example.config.json" contents looks like this in remix
If your config file is missing "viaIR" flag then contract wont compile

{
	"language": "Solidity",
	"settings": {
		"optimizer": {
			"enabled": true,
			"runs": 200
		},
		"viaIR": true,
		"outputSelection": {
			"*": {
			"": ["ast"],
			"*": ["abi", "metadata", "devdoc", "userdoc", "storageLayout", "evm.legacyAssembly", "evm.bytecode", "evm.deployedBytecode", "evm.methodIdentifiers", "evm.gasEstimates", "evm.assembly"]
			}
		}
	}
}
