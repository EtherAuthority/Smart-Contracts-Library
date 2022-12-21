Follow these steps for deploying and setting up post deployment
1. Give in required constructor paramenters i.e, routerAddress, designatedWalletA & designatedWalletB addresses..etc
2. Max supply is minted to the owner while deploying
3. Add liquidity with 100% of totalSupply 
4. After adding liquidity, call "setTradeTaxStatus" to enable tradetax(very important)

Now we can safely test swapping and normal transfers.

Using these router and dexs for testing:
DEX- https://bsc.pancake.kiemtienonline360.com/#/swap
Router - https://testnet.bscscan.com/address/0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
Network - BSC TESTNET
