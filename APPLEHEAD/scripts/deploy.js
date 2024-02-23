const { ethers } = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  const developmentWallet = '--devWallet--';
  const marketingWallet = '--marketing Wallet--';
  const reserveWallet = '-- reserve Wallet--';
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


