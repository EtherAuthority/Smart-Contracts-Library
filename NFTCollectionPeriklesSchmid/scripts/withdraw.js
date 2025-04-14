const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const [owner] = await ethers.getSigners();

  const tx = await contract.withdraw();
  await tx.wait();

  console.log("Withdrawn to owner");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
