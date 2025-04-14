const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const userAddress = "0xWHITELISTED_ADDRESS";
  const status = true;

  const [owner] = await ethers.getSigners();

  const tx = await contract.setWhitelistStatus(userAddress, status);
  await tx.wait();

  console.log(`Whitelist status of ${userAddress} set to ${status}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
