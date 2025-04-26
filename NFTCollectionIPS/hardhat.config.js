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

    SCAIMainnet: {
      url: "https://mainnet-rpc.scai.network",
      chainId: 34,      
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
    
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      //url: "https://bsc-testnet-rpc.publicnode.com",
      chainId: 97,      
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
    
    poodlTestnet: {
      url: "https://testnet-rpc.poodl.org",
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
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

    customChains: [
      {
        network: "SCAIMainnet",
        chainId: 34,
        urls: {
          apiURL: "https://explorer.securechain.ai/api",
          browserURL: "https://explorer.securechain.ai"
        }
      },

      {
        network: "bscTestnet",
        chainId: 97,
        urls: {
          apiURL: "https://api-testnet.bscscan.com/api",
          browserURL: "https://testnet.bscscan.com"
        }
      },

      {
        network: "poodlTestnet",
        chainId: 15257,
        urls: {
          apiURL: "https://testnet.poodl.org/api",
          browserURL: "https://testnet.poodl.org"
        }
      },
      
    ]

  },
  optimizer: {
    enabled: true,
    runs: 200,
  },
};
