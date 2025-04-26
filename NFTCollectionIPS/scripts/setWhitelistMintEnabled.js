const { ethers } = require("hardhat");

async function main() {
  try {
    
    const { CONTRACT_ADDRESS, GAS_LIMIT, CUSTOM_GAS_GWEI } = process.env;
    const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

    const [owner] = await ethers.getSigners();
    const gasPrice = await ethers.provider.getFeeData().then(data => data.gasPrice);
    const customGasPrice = ethers.parseUnits(CUSTOM_GAS_GWEI, "gwei"); // 45 Gwei

    console.log("Current gas price (Gwei):", gasPrice);
    //console.log("Custom gas price (Gwei) :", customGasPrice);
    
    const enabled = true; // Change to false to disable    
    const tx = await contract.connect(owner).setWhitelistMintEnabled(enabled);
    const receipt = await tx.wait();
    console.log("✅ Gas used:", receipt.gasUsed.toString());

    console.log(`✅ Whitelist minting has been ${enabled ? "enabled" : "disabled"}`);
  } catch (error) {
    console.error("❌ Failed to set whitelist mint enabled:");
    console.error(error.reason || error.message);
    process.exit(1);
  }
}

main();
