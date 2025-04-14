const { ethers } = require("hardhat");

async function main() {
  try {
    
    const { CONTRACT_ADDRESS } = process.env;
    const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

    const maxPerTx = 5; // 🔧 Max mints per transaction
    const maxPerWallet = 20; // 🔧 Max mints per wallet

    const [owner] = await ethers.getSigners();
  
    const tx = await contract.connect(owner).setMintLimits(maxPerTx, maxPerWallet);
    console.log(`⏳ Setting mint limits (perTx: ${maxPerTx}, perWallet: ${maxPerWallet})...`);
    await tx.wait();
    console.log(`✅ Mint limits set successfully.`);
  } catch (error) {
    console.error("❌ Error setting mint limits:", error.message);
  }
}

main();
