const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const baseURI = "ipfs://testbaseid/";

  const [owner] = await ethers.getSigners();

  const tx = await nftContract.setBaseURI(baseURI);
  await tx.wait();

  console.log("Base URI updated to:", baseURI);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
