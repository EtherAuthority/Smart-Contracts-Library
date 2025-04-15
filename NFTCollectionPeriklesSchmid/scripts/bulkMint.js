const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const tokenURIs = [
    "ipfs://bafybeiavk4yxck57raantcnwi5wx2gnxhuzmesdhnn7lxuq7bolrhc6qpq/5.json",
    "ipfs://bafybeiavk4yxck57raantcnwi5wx2gnxhuzmesdhnn7lxuq7bolrhc6qpq/6.json"
  ];

  const tx = await contract.bulkMint(tokenURIs);
  await tx.wait();
  console.log("Bulk mint done!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
