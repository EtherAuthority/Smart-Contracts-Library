const { ethers } = require("hardhat");
const fs = require("fs");
const path = require('path');

async function main() {
  
  const { CONTRACT_ADDRESS, GAS_LIMIT, CUSTOM_GAS_GWEI } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const [owner] = await ethers.getSigners();
  const gasPrice = await ethers.provider.getFeeData().then(data => data.gasPrice);
  
  //const customGasPrice = ethers.parseUnits(CUSTOM_GAS_GWEI, "gwei"); // 45 Gwei

  const customGasPrice = ethers.toBigInt(CUSTOM_GAS_GWEI);
  const gasLimit = ethers.toBigInt(GAS_LIMIT);

  //console.log("Gas Limit:", gasLimit);
  console.log("Current gas price (Gwei):", gasPrice);
  //console.log("Custom gas price (Gwei) :", customGasPrice);

  

  // Load your full array of tokenURIs (e.g., from JSON file or direct array)
  const filePath = path.join(__dirname, 'tokenURIs_10k_to_20k.json'); // change file name here 
  const tokenURIs = JSON.parse(fs.readFileSync(filePath, 'utf8')); // 10000 tokens uri

  //console.log('Loaded', tokenURIs.length, 'token URIs');


  const batchSize = 5; // divided all tokens into 1000 part with 100 token uri batch
  
  for (let i = 0; i < tokenURIs.length; i += batchSize) {
    const batch = tokenURIs.slice(i, i + batchSize);

     /*, {
        gasLimit,
        gasPrice: customGasPrice
    }*/
    const tx = await contract.bulkMint(batch);
    const receipt = await tx.wait(); // after 100 tokens mint success, after it will start next 100 tokens - till 10000 tokens*/
    console.log("✅ Gas used:", receipt.gasUsed.toString());

    console.log(`✅ Minted batch ${i / batchSize + 1}:`, batch.length);
  }
  
}

main().catch(console.error);
