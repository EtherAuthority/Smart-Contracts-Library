const { ethers, upgrades } = require("hardhat");
const { parseUnits } = require("ethers");


async function deployContract(name = "", args = []) {
    console.log(args);
    const objCnt = await ethers.getContractFactory(name);
    const dplobj = await objCnt.deploy(...args);
    //const waitDeployed = await dplobj.deployed();
    await dplobj.waitForDeployment();
    const contractAddress = await dplobj.getAddress();

    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with:", deployer.address);
    console.log("Account balance:", ethers.formatEther(await deployer.provider.getBalance(deployer.address)));

    console.log(`The contract ${name} address:`, contractAddress);
    return dplobj;

}

async function main() {
    
    let minPrice = parseUnits("0.001", 18);
    const NFTCollection = await deployContract("NFTCollection", ["NFT Collection", "LNFT", "https://ipfs.io/ipfs/", minPrice]);
    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
