const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("IndustrialGoldCoin", function () {
  let IGC, igc, SOLID, solid, owner, addr1, addr2, addr3, newholder;

  it("Deployment", async function () {
    // Get the ContractFactory and Signers here.
    [owner, addr1, addr2, addr3, newholder, ...addrs] = await ethers.getSigners();

    // Deploy the SOLID token contract
    SOLID = await ethers.getContractFactory("SOLID");
    solid = await SOLID.deploy();


    // Deploy the IndustrialGoldCoin contract
    IGC = await ethers.getContractFactory("IGCtoken");
    igc = await IGC.deploy(solid.target);
   
  });

  it("Should set the right owner", async function () {
    expect(await igc.owner()).to.equal(owner.address);
  });

  it("Should mint tokens", async function () {
    await igc.mint(addr1.address, 1000);
    await igc.mint(addr3.address, 1000);
    await solid.mintToken(owner.address, 1000);
    expect(await igc.balanceOf(addr1.address)).to.equal(1000);

    expect(await igc.isHolder(addr1.address)).to.be.true;
  });

  it("Should prevent the owner from being a holder", async function () {
    await expect(igc.mint(owner.address, 1000)).to.be.revertedWith("Owner cannot be a holder");
  });

  it("Should set DEX status", async function () {
    await igc.setDEX(addr2.address, true);
    expect(await igc.isDEX(addr2.address)).to.be.true;
  });

  it("Should not allow transfers to DEX", async function () {
    await igc.connect(addr3).approve(addr2.address, 10000000n);
    await expect(igc.connect(addr3).transfer(addr2.address, 500)
    ).to.be.revertedWith("Transfers to contracts are disabled");
  });

  it("Should burn tokens", async function () {
    // Call the totalSupply function
    var totalSupply = await igc.totalSupply();

    // Log the result

    await igc.ownerBurn(addr1.address, 100n);

    expect(await igc.totalSupply()).to.equal(1900n);
  });


  it("Should distribute dividends", async function () {
    // Mint SOLID tokens to the owner

    // Approve the transfer of SOLID tokens from owner to IGC contract
    let solidbalance = await solid.balanceOf(owner.address);

    await solid.approve(igc.target, solidbalance);
    // Distribute dividends
    await igc.distributeDividends();

    expect(await solid.balanceOf(igc.target)).to.equal(solidbalance);
  });


  it("Should calculate claimable dividends", async function () {
    const dividends = await igc.viewDividend(addr1.address);
    let igcbalance = await solid.balanceOf(igc.target);

    expect(dividends).to.equal(473684210526315789474157n); // addr1 holds all tokens, so gets all dividends
  });

  it("Should allow holders to claim dividends", async function () {
    const dividends = await igc.viewDividend(addr1.address);
    await igc.connect(addr1).claim();
    expect(await solid.balanceOf(addr1.address)).to.equal(dividends);
  });


  it("Should withdraw unclaimed dividends", async function () {
    igc.connect(owner).withdrawUnclaimedDividends();
    await solid.balanceOf(igc.target);
    expect(await solid.balanceOf(igc.target)).to.equal(0);
  });

  it("Only distribution time holders get dividend amount, new holders not counted at this distribution", async function () {
    // Step 1: Initial setup
    await igc.mint(addr1.address, 500); // Mint tokens to addr1
    await igc.mint(addr3.address, 500); // Mint tokens to addr3
    await solid.mintToken(owner.address, 1000); // Mint SOLID tokens to the owner for distribution   
    // Approve the SOLID tokens for the IGC contract to distribute
    await solid.approve(igc.target, 526315789473684210527843n);

    // Step 2: Distribute dividends based on the initial holders
    await igc.distributeDividends();

    // Step 3: Add a new holder after the distribution
    await igc.mint(newholder.address, 500); // Mint tokens to addr2 after the distribution

    // Step 4: Check that only the initial holders received dividends
    const dividendsAddr1 = await igc.viewDividend(addr1.address);
    const dividendsAddr3 = await igc.viewDividend(addr3.address);
    const dividendsAddr2 = await igc.viewDividend(newholder.address);

    // addr1 and addr3 should have received dividends
    expect(dividendsAddr1).to.be.above(0);
    expect(dividendsAddr3).to.be.above(0);

    // addr2 should not have received any dividends because they were added after distribution
    expect(dividendsAddr2).to.equal(0);
  });

  it("Should not mint or transfer with 0 amount", async function () {
    await expect(igc.mint(addr1.address, 0)).to.be.revertedWith("Amount must be greater than 0");
    await expect(igc.transfer(addr3.address, 0)).to.be.revertedWith("Amount must be greater than 0");
  });
});
