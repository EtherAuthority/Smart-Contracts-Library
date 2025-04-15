const { ethers } = require("hardhat");

async function main() {
  
  const { CONTRACT_ADDRESS } = process.env;
  const contract = await ethers.getContractAt("NFTCollection", CONTRACT_ADDRESS);

  const tokenURIs = [
    "ipfs://CID/new.json"
  ];
  const quantity = tokenURIs.length;

  const [user] = await ethers.getSigners();

  const mintPrice = await contract.mintPrice();
  const tx = await contract.whitelistMint(quantity, tokenURIs, {
    value: mintPrice.mul(quantity),
  });
  await tx.wait();

  console.log(`Whitelist minted ${quantity} tokens`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
