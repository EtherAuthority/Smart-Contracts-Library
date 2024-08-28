import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  defender: {
    apiKey: process.env.DEFENDER_KEY as string,
    apiSecret: process.env.DEFENDER_SECRET as string,

  },
  networks: {
    matic: {
      url: "https://polygon-bor-rpc.publicnode.com",
      chainId: 137,
      accounts: ['your metamask wallet private key'],

    },
  },
  etherscan : {
    apiKey: 'your polygonscan  API key', // polygon
    
  },
};
export default config;

