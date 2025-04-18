const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS, GAS_LIMIT, CUSTOM_GAS_GWEI } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const [owner] = await ethers.getSigners();
  const gasPrice = await ethers.provider.getFeeData().then(data => data.gasPrice);
  const customGasPrice = ethers.parseUnits(CUSTOM_GAS_GWEI, "gwei"); // 45 Gwei
  const gasLimit = ethers.toBigInt(GAS_LIMIT);

  //console.log("Gas Limit:", gasLimit);
  console.log("Current gas price (Gwei):", gasPrice);
  //console.log("Custom gas price (Gwei) :", customGasPrice);

  const tokenURIs = [
    "ipfs://bafybeiavk4yxck57raantcnwi5wx2gnxhuzmesdhnn7lxuq7bolrhc6qpq/5.json",
    "ipfs://bafybeiavk4yxck57raantcnwi5wx2gnxhuzmesdhnn7lxuq7bolrhc6qpq/6.json"
  ];

  const tx = await contract.bulkMint(tokenURIs);

  const receipt = await tx.wait();
  console.log("✅ Gas used:", receipt.gasUsed.toString());
  console.log("✅ Bulk mint done!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
