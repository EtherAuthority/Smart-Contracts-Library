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

    const maxPerTx = 5; // 🔧 Max mints per transaction
    const maxPerWallet = 20; // 🔧 Max mints per wallet
  
    const tx = await contract.connect(owner).setMintLimits(maxPerTx, maxPerWallet, {
                gasLimit: GAS_LIMIT,
                gasPrice: customGasPrice
              });
    console.log(`⏳ Setting mint limits (perTx: ${maxPerTx}, perWallet: ${maxPerWallet})...`);
    await tx.wait();
    console.log(`✅ Mint limits set successfully.`);
  } catch (error) {
    console.error("❌ Error setting mint limits:", error.message);
  }
}

main();
