const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS, GAS_LIMIT, CUSTOM_GAS_GWEI } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const [owner] = await ethers.getSigners();
  const gasPrice = await ethers.provider.getFeeData().then(data => data.gasPrice);
  const customGasPrice = ethers.parseUnits(CUSTOM_GAS_GWEI, "gwei"); // 45 Gwei

  console.log("Current gas price (Gwei):", gasPrice);
  //console.log("Custom gas price (Gwei) :", customGasPrice);

  const userAddress = "0xe5377E463C230c3A1e97abdF25aCDAfB51E20cDb";
  const status = true;

  const tx = await contract.setWhitelistStatus(userAddress, status);
  const receipt = await tx.wait();
  console.log("✅ Gas used:", receipt.gasUsed.toString());

  console.log(`✅ Whitelist status of ${userAddress} set to ${status}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
