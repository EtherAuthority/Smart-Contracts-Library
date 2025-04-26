const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS, GAS_LIMIT, CUSTOM_GAS_GWEI } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const [owner] = await ethers.getSigners();
  const gasPrice = await ethers.provider.getFeeData().then(data => data.gasPrice);
  const customGasPrice = ethers.parseUnits(CUSTOM_GAS_GWEI, "gwei"); // 45 Gwei

  console.log("Current gas price (Gwei):", gasPrice);  

  const tokenId = 1;
  const [user] = await ethers.getSigners();

  const tx = await contract.burn(tokenId);
  const receipt = await tx.wait();
  console.log("✅ Gas used:", receipt.gasUsed.toString());
  console.log("✅ Token burned:", tokenId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
