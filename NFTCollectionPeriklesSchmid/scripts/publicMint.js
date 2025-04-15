const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS, GAS_LIMIT, CUSTOM_GAS_GWEI } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const [owner] = await ethers.getSigners();
  const gasPrice = await ethers.provider.getFeeData().then(data => data.gasPrice);
  const customGasPrice = ethers.parseUnits(CUSTOM_GAS_GWEI, "gwei"); // 45 Gwei

  console.log("Current gas price (Gwei):", gasPrice);
  console.log("Custom gas price (Gwei) :", customGasPrice);

  const tokenURIs = [
    "ipfs://test.json",
    "ipfs://testnew.json"
  ];
  const quantity = tokenURIs.length;

  const mintPrice = await contract.mintPrice();
  const totalCost = mintPrice * BigInt(quantity);

  const tx = await contract.publicMint(quantity, tokenURIs, {
    gasLimit: GAS_LIMIT,
    gasPrice: customGasPrice,
    value: totalCost,
  });
  
  const receipt = await tx.wait();

  console.log(`✅ Successfully minted ${quantity} NFTs`);
  console.log("🧾 Transaction hash:", receipt.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});