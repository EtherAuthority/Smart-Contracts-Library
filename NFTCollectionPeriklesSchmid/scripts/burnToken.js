const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const tokenId = 1;

  const [user] = await ethers.getSigners();

  const tx = await contract.burn(tokenId);
  await tx.wait();

  console.log("Token burned:", tokenId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
