# Freeflow Escrow Contract

## Setup
1. `git clone https://github.com/bmwoolf/escrowFactory.git`
2. `npm i`
3. set up environment variables 
  `RINKEBY_INFURA_ENDPOINT=""`  
  `ETHERSCAN_KEY=""`  
  `PRIVATE_KEY1=""`  
5. `npx hardhat run scripts/deploy.js --network rinkeby`
(You will need an infura key for mainnet when deploying to mainnet)

If you want to use some of the scripts that are setup to test on rinkeby (or transform them for real deployment / interaction), first replace `ESCROW_CLONE` address in the javascript files with your new respective escrow contract address after generating a new escrow contract on etherscan (or hardhat if you want to use `createNewEscrow()` in the deploy script or new script etc.)

* `interactETH.js` will have the client deposit .01 ether into the contract, log out balances, and then call the withdraw functionality releasing the funds.
* `interactUSDT.js` will do the same with 1 Tether coin.
* `interactUSDC.js` will do the same with 1 USD coin.
(You'll need to add a second private key to your .env for these to work as intended as it checks balances of the dev (second wallet) after withdrawals etc.)

## Other Notes
* **The current contract is setup pointing to Rinkeby/Kovan addresses for USDC and USDT, replace them with mainnet addresses before deploying to mainnet!!!!**
* Be congnicent that you will need to account for the correct decimals, e.g. Ethereum is 1^18 while USDT/USDC are 1^6 (for some reason testnet USDT is 1^18 on rinkeby). There are tools in `ethers.js` to help you with this or you can do the math if interacting with the variable inputs for the functions on Etherscan.
* Sometimes testnets can be finicky. If the testing scripts fail, try running them again if they got hung or give an error about gas. Another thing to check is Rinkeby has also been stalling out on blocks, not indexing TX's quickly and going down for a few hours every now and then. For this reason, I also recommend using small amounts of precious test ether or USDC/USDT in these tests.
* Only USDC and USDT are accepted for the ERC20 functions.
