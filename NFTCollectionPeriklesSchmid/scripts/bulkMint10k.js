const { ethers } = require("hardhat");
const fs = require("fs");
const path = require('path');

async function main() {
  const [deployer] = await ethers.getSigners();

  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  // Load your full array of tokenURIs (e.g., from JSON file or direct array)
  const filePath = path.join(__dirname, 'tokenURIs_10k.json');
  const tokenURIs = JSON.parse(fs.readFileSync(filePath, 'utf8')); // 10000 tokens uri

  //console.log('Loaded', tokenURIs.length, 'token URIs');


  const batchSize = 100; // divided all tokens into 1000 part with 100 token uri batch

  for (let i = 0; i < tokenURIs.length; i += batchSize) {
    const batch = tokenURIs.slice(i, i + batchSize);
    const tx = await contract.bulkMint(batch);
    await tx.wait(); // after 100 tokens mint success, after it will start next 100 tokens - till 10000 tokens
    console.log(`✅ Minted batch ${i / batchSize + 1}:`, batch.length);
  }
}

main().catch(console.error);
