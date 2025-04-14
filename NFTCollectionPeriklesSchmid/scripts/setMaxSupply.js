const { ethers } = require("hardhat");

async function main() {
  try {
    
    const { CONTRACT_ADDRESS } = process.env;
    const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

    const maxSupply = 1000; // 🔧 Change this to your desired max supply

    const [owner] = await ethers.getSigners();

    const tx = await contract.connect(owner).setMaxSupply(maxSupply);
    console.log(`⏳ Setting max supply to ${maxSupply}...`);
    await tx.wait();
    console.log(`✅ Max supply set to ${maxSupply}`);
  } catch (error) {
    console.error("❌ Error setting max supply:", error.message);
  }
}

main();
