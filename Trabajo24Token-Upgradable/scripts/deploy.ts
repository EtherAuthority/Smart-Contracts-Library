import { ethers, defender } from "hardhat";

enum Network {
  MATIC = "matic",
  // Add other networks if needed
}
async function main() {
  const  multisigWallet ="your multisigwallet";
  // const adminClient = new AdminClient({ apiKey:  process.env.DEFENDER_KEY as string, apiSecret:process.env.DEFENDER_SECRET as string });
  const Token = await ethers.getContractFactory("Trabajo24Token");

//   const deployment = await defender.trabajo24TokenProxy(Token);
  const trabajo24TokenProxy = await defender.deployProxy(Token,[multisigWallet], {
    initializer: 'initialize',  // Make sure 'initialize' is the correct initializer function
    kind: 'uups',
    
  });
  
  await trabajo24TokenProxy.waitForDeployment();
  console.log(`Contract deployed to: ${await trabajo24TokenProxy.getAddress()}`)
  const defenderContract = {
    name: "NEwTestTokenProxy",
    address: trabajo24TokenProxy.target,  // Registering the proxy address
    network: Network.MATIC,
  };
 
  console.log("Defender Contract Object:", defenderContract); 
} 


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});