const { ethers } = require("hardhat");

async function main() {
  try {
    
    const { CONTRACT_ADDRESS, GAS_LIMIT, CUSTOM_GAS_GWEI } = process.env;
    const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

    const [owner] = await ethers.getSigners();
    const gasPrice = await ethers.provider.getFeeData().then(data => data.gasPrice);
    const customGasPrice = ethers.parseUnits(CUSTOM_GAS_GWEI, "gwei"); // 45 Gwei

    console.log("Current gas price (Gwei):", gasPrice);
    console.log("Custom gas price (Gwei) :", customGasPrice);

    const maxSupply = 1000; // 🔧 Change this to your desired max supply

    const tx = await contract.connect(owner).setMaxSupply(maxSupply, {
                gasLimit: GAS_LIMIT,
                gasPrice: customGasPrice
              });
    console.log(`⏳ Setting max supply to ${maxSupply}...`);
    await tx.wait();
    console.log(`✅ Max supply set to ${maxSupply}`);
  } catch (error) {
    console.error("❌ Error setting max supply:", error.message);
  }
}

main();
