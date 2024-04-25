const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("--QURAC contract--", function () {
    let mytoken;
    let owner;
    let address1;
    let address2;
    let address3;
    let addresses;
    const zeroAddress = "0x0000000000000000000000000000000000000000";
    let Contract;
    let spender;

    beforeEach(async function () {
        Contract = await ethers.getContractFactory("QURAC");
        [owner, address1, address2,address3,spender, ...addresses] = await ethers.getSigners();
        mytoken = await Contract.deploy();
        await mytoken.waitForDeployment();
    });

    it("Should deploy myToken the contract correctly", async function () {
        expect(await mytoken.name()).to.equal("QURAC");
        expect(await mytoken.symbol()).to.equal("QURAC");
        expect(await mytoken.totalSupply()).to.equal("1000000000000000000000000000");
      });
      it("Should transfer tokens successfully", async function () {
        const initialBalance = await mytoken.balanceOf(owner.address);
        const transferAmount = BigInt(100);
        
        await mytoken.transfer(address1.address, transferAmount);
        await mytoken.connect(address1).transfer(address2.address, "50");
        
        const finalBalanceOwner = await mytoken.balanceOf(owner.address);
        const finalBalanceReceiver = await mytoken.balanceOf(address1.address);
        const finalBalanceReceiver2 = await mytoken.balanceOf(address2.address);
        
        
        expect(finalBalanceOwner).to.equal(initialBalance - (transferAmount));
        expect(finalBalanceReceiver).to.equal(transferAmount - BigInt(50));
        expect(finalBalanceReceiver2).to.equal("50");
    });

    it("Should emit Transfer and Approval events", async function () {
        const transferTx = await mytoken.transfer(address1.address, 1000);
        await expect(transferTx).to.emit(mytoken, "Transfer").withArgs(owner.address, address1.address, 1000);
    
        const approveTx = await mytoken.approve(address2.address, 1000);
        await expect(approveTx).to.emit(mytoken, "Approval").withArgs(owner.address, address2.address, 1000);
        
        
      });
      it("Should allow self-transfer without changing balance", async function () {
        const initialBalance = await mytoken.balanceOf(owner.address);
        
        await mytoken.transfer(owner.address, 100);
        
        const finalBalance = await mytoken.balanceOf(owner.address);
        
        expect(finalBalance).to.equal(initialBalance);
    });


      
          it("transfer tokens from one account  to another account", async function () {
            const ownerBalanceBefore = await mytoken.balanceOf(owner.address);
            const address2BalanceBefore = await mytoken.balanceOf(address2.address);
        
            const amount = BigInt(100, 18); // Transfer 100 tokens with 18 decimals
            await mytoken.connect(owner).transfer(address2.address, amount);
        
            const ownerBalanceAfter = await mytoken.balanceOf(owner.address);
            const address2BalanceAfter = await mytoken.balanceOf(address2.address);
        
            expect(ownerBalanceAfter).to.equal(ownerBalanceBefore - (amount));
            expect(address2BalanceAfter).to.equal(address2BalanceBefore + (amount));
        });
        
        it("transfer zero tokens without any change in balance", async function () {
            const ownerBalanceBefore = await mytoken.balanceOf(owner.address);
            const address2BalanceBefore = await mytoken.balanceOf(address2.address);
        
            expect( await mytoken.connect(owner).transfer(address2.address, 0));
        
            const ownerBalanceAfter = await mytoken.balanceOf(owner.address);
            const address2BalanceAfter = await mytoken.balanceOf(address2.address);
        
        
            expect(ownerBalanceAfter).to.equal(ownerBalanceBefore);
            expect(address2BalanceAfter).to.equal(address2BalanceBefore);
        });
        it("Not allow transfer more tokens than balance", async function () {
            const ownerBalanceBefore = await mytoken.balanceOf(owner.address);
            const address2BalanceBefore = await mytoken.balanceOf(address2.address);
        
            const amount = ownerBalanceBefore + (BigInt(1,18)); // Transfer amount greater than owner's balance
            await expect(mytoken.connect(owner).transfer(address2.address, amount)).to.be.reverted;
        
            const ownerBalanceAfter = await mytoken.balanceOf(owner.address);
            const address2BalanceAfter = await mytoken.balanceOf(address2.address);
        
            expect(ownerBalanceAfter).to.equal(ownerBalanceBefore);
            expect(address2BalanceAfter).to.equal(address2BalanceBefore);
        });
        
        it("Not allow transfer tokens to zero address", async function () {
            const ownerBalanceBefore = await mytoken.balanceOf(owner.address);
            const address2BalanceBefore = await mytoken.balanceOf(zeroAddress);
        
            const amount = BigInt(100, 18); // Transfer 100 tokens with 18 decimals
            await expect(mytoken.connect(owner).transfer(zeroAddress, amount)).to.be.reverted;
        
            const ownerBalanceAfter = await mytoken.balanceOf(owner.address);
            const address2BalanceAfter = await mytoken.balanceOf(zeroAddress);
        
            expect(ownerBalanceAfter).to.equal(ownerBalanceBefore);
            expect(address2BalanceAfter).to.equal(address2BalanceBefore);
        });

        it("allow approval of tokens", async function () {
            const initialAllowance = await mytoken.allowance(owner.address, spender.address);
            const amount = BigInt(100);
        
            await mytoken.connect(owner).approve(spender.address, amount);
        
            const updatedAllowance = await mytoken.allowance(owner.address, spender.address);
            expect(updatedAllowance).to.equal(amount);
        });
        it(" transfer allowed tokens from approved account", async function () {
            const amountToApprove = BigInt(100);
            const amountToTransfer = BigInt(50);
        
            await mytoken.connect(owner).approve(spender.address, amountToApprove);
            const allowanceBefore = await mytoken.allowance(owner.address, spender.address);
            const balanceFromBefore = await mytoken.balanceOf(owner.address);
            const balanceToBefore = await mytoken.balanceOf(address1.address);
        
            await (mytoken.connect(spender).transferFrom(owner.address, address1.address, amountToTransfer))
               
        
            const allowanceAfter = await mytoken.allowance(owner.address, spender.address);
            const balanceFromAfter = await mytoken.balanceOf(owner.address);
            const balanceToAfter = await mytoken.balanceOf(address1.address);
        
            expect(allowanceBefore).to.equal(amountToApprove);
            expect(allowanceAfter).to.equal(amountToApprove - amountToTransfer);
            expect(balanceFromAfter).to.equal(balanceFromBefore - amountToTransfer);
            expect(balanceToAfter).to.equal(balanceToBefore + amountToTransfer);
        });
        it(" not allow transfer more tokens than allowed", async function () {
            const amountToApprove = BigInt(100);
            const amountToTransfer = BigInt(150);
        
            await mytoken.connect(owner).approve(spender.address, amountToApprove);
            const allowanceBefore = await mytoken.allowance(owner.address, spender.address);
            const balanceFromBefore = await mytoken.balanceOf(owner.address);
            const balanceToBefore = await mytoken.balanceOf(address1.address);
        
            await expect(mytoken.connect(spender).transferFrom(owner.address, address1.address, amountToTransfer))
                .to.be.reverted;
        
            const allowanceAfter = await mytoken.allowance(owner.address, spender.address);
            const balanceFromAfter = await mytoken.balanceOf(owner.address);
            const balanceToAfter = await mytoken.balanceOf(address1.address);
        
            expect(allowanceBefore).to.equal(amountToApprove);
            expect(allowanceAfter).to.equal(allowanceBefore);
            expect(balanceFromAfter).to.equal(balanceFromBefore);
            expect(balanceToAfter).to.equal(balanceToBefore);
        });
        
});
