require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomicfoundation/hardhat-chai-matchers");

const { ACCOUNT_PRIVATE_KEY, BSCSCAN_API_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: {
    compilers: [
      
      {
        version: "0.8.24",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          /*evmVersion: "istanbul"*/
        },
      }
      /*{
        version: "0.6.12", // Second compiler version
      },*/
      // Add more compiler versions as needed
    ],
  },
  defaultNetwork: "bscTestnet",
  networks: {
    hardhat: {},
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,      
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
    poodlMainnet: {
      url: "https://rpc.poodl.org",
      chainId: 15259,      
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
    
  },
  etherscan: {
    //apiKey: ETHERSCAN_API_KEY,
    apiKey: BSCSCAN_API_KEY,
  },
  optimizer: {
    enabled: true,
    runs: 200,
  },
};
