const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const tokenURIs = [
    "ipfs://test.json",
    "ipfs://testnew.json"
  ];
  const quantity = tokenURIs.length;

  const [user] = await ethers.getSigners();

  const mintPrice = await contract.mintPrice();
  const totalCost = mintPrice * BigInt(quantity);

  const tx = await contract.publicMint(quantity, tokenURIs, {
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