const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("magacoin contract",function(){
  let MAGANFT;
  let MAGACOIN;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;
  let maganft;
  let magacoin;
  let magaNftAddress;

  beforeEach(async function(){
    MAGANFT = await ethers.getContractFactory("MagaNFT");
    [owner,addr1,addr2,addr3,...addrs] = await ethers.getSigners();
    maganft = await MAGANFT.deploy();
    await maganft.waitForDeployment();
    magaNftAddress =maganft.target;
  
    MAGACOIN = await ethers.getContractFactory("Magacoin");
    magacoin = await MAGACOIN.deploy(magaNftAddress);
    await magacoin.waitForDeployment();

  });
 
  describe("magacoin", async function () {
    it("total supply should be equal to", async function (){
    
    const totalSupply = await magacoin.totalSupply();
    expect(totalSupply.toString()).to.equal("5000000000000000000000000");
    
    const ownerbalance = await magacoin.balanceOf(await owner.address);
    expect(ownerbalance.toString()).to.equal(totalSupply);
    });
    it("transfer token to owner address and addr1 to addr2", async function (){
        
        await magacoin.transfer(addr1.address,100);
        expect (await magacoin.balanceOf(addr1.address)).to.equal(100);   
        await magacoin.connect(addr1).transfer(addr2.address,50);
        expect (await magacoin.balanceOf(addr2.address)).to.equal(50);
        });
        it("check approve owner address to addr1", async function (){
            await magacoin.approve(addr1.address,1000);
            expect (await magacoin.allowance(owner.address,addr1.address)).to.equal(1000);
           
          });    
            it("check transferFrom to addr1 address to addr3", async function (){
              await magacoin.approve(addr1.address,1000);
              await magacoin.connect(addr1).transferFrom(owner.address,addr3.address,1000);
              let balanceAdd3 =  await magacoin.balanceOf(addr3.address);
              expect (balanceAdd3.toString()).to.equal((1000).toString());
             
            });

            it("should only allow NFT contract to mint", async function () {
                await expect(magacoin.connect(owner).mint(addr1.address, 10)).to.be.revertedWith("Only magaNFT contract can mint");
            });
            
  });

  describe("--magaNFT--", async function () {
    it("Max_Supply should be equal to", async function (){
    const maxSupply = await maganft.MAX_SUPPLY();
    expect(maxSupply.toString()).to.equal("1000"); 
    });

    it("totalSupply should be equal to", async function (){
      const totalsupply = await maganft.totalSupply();
      expect(totalsupply.toString()).to.equal("0"); 
      });

        it("should revert if address is zero", async function () {
          await expect(maganft.connect(owner).setMagaCoinAddress("0x0000000000000000000000000000000000000000"))
            .to.be.revertedWith("Address can not be zero");
        });

        it("should mint a token when called with sufficient AVAX amount", async function () {
          let ownerBalance = await ethers.provider.getBalance(owner.address);
          const initialSupply = await maganft.totalSupply();
          const nftPrice = await maganft.nftPrice();
          // Send AVAX with the transaction
          const tx = await maganft.connect(addr1).safeMint({ value: nftPrice });
              
          //balance of addr1 after mint
          const balanceofAddr1 = await maganft.balanceOf(addr1.address);
          expect(balanceofAddr1.toString()).to.equal("1");

          // Check if a token is minted
          expect(await maganft.totalSupply()).to.equal(initialSupply + (1).toString());
    
          // Check if the owner received the AVAX
          const expectedOwnerBalance = await ethers.provider.getBalance(owner.address);
          ownerBalance += nftPrice; 
          expect(ownerBalance).to.equal(expectedOwnerBalance);
          
        });

        it("should revert if called with insufficient AVAX amount", async function () {
          let nftPrice = await maganft.nftPrice();
          nftPrice = BigInt(nftPrice);
          // Send less AVAX than required
          const insufficientAmount = nftPrice - BigInt(1);
          await expect(maganft.connect(addr1).safeMint({ value: insufficientAmount })).to.be.revertedWith("Not sufficient AVAX amount");
        });

        it("should revert if total supply exceeds max supply", async function () {
          const maxSupply = await maganft.MAX_SUPPLY();
          // Mint tokens to reach max supply
          for (let i = await maganft.totalSupply(); i <= maxSupply; i++) {
            await maganft.connect(addr2).safeMint({ value: await maganft.nftPrice() });
          }
          // Attempt to mint one more token, should revert
          await expect(maganft.connect(addr3).safeMint({ value: await maganft.nftPrice() })).to.be.revertedWith("You can not mint more than max supply");
        });

        it("should update NFT price when called by owner", async function () {
          const newPrice = 1; // New price in wei
          await maganft.connect(owner).updateNFTPrice(newPrice);
          
          // Check if the price is updated correctly
          expect(await maganft.nftPrice()).to.equal(newPrice);
        });

        it("should mint MagaCoin tokens based on NFT ID and ownership", async function () {
          // Mint an NFT and set claim time
          const nftPrice = await maganft.nftPrice();
          // Send AVAX with the transaction
          await maganft.connect(addr1).safeMint({ value: nftPrice });
          // Ensure MagaCoin balance of addr1 is initially zero
          expect(await maganft.balanceOf(addr1.address)).to.equal(1);
          // Call claimMagaCoin revert
          await expect ( maganft.connect(addr1).claimMagaCoin(1)).to.be.revertedWith("You can not claim now please wait more");
        });
  });
});