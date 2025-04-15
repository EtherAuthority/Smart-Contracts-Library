const { ethers } = require("hardhat");

async function main() {
  try {
    
    const { CONTRACT_ADDRESS } = process.env;
    const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);
    
    const enabled = true; // Change to false to disable

    const [owner] = await ethers.getSigners();

    const tx = await contract.connect(owner).setWhitelistMintEnabled(enabled);
    await tx.wait();

    console.log(`✅ Whitelist minting has been ${enabled ? "enabled" : "disabled"}`);
  } catch (error) {
    console.error("❌ Failed to set whitelist mint enabled:");
    console.error(error.reason || error.message);
    process.exit(1);
  }
}

main();
