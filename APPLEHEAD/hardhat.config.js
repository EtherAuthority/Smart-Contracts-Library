/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

const ALCHEMY_API_KEY = "---alchemy api key---";
const SEPOLIA_PRIVATE_KEY =
  "---wallet private key---";
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${SEPOLIA_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: '---etherscan apiKey---'
    }
  }
};