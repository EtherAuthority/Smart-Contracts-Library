const { ethers } = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  const developmentWallet = '0xD4eff55D5569931F1FC4b3f738bd372caeDF2B7e';
  const marketingWallet = '0xD4eff55D5569931F1FC4b3f738bd372caeDF2B7e';
  const reserveWallet = '0xD4eff55D5569931F1FC4b3f738bd372caeDF2B7e';
  const Token = await ethers.getContractFactory("AppleHead");
  const token = await Token.deploy(developmentWallet,marketingWallet,reserveWallet);
  console.log("Token address:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


