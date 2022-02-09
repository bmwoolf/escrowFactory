# Freeflow Escrow Contract
To deploy our Escrow contracts, first we deploy the factory contract and the clone contract. This can be done by running `npx hardhat run scripts/deployNewEscrowEthAndERC20.js --network rinkeby` (will replace with mainnet when going live). In the same script you will call functions that actually generate the clone contracts, this is based on `createNewEscrow()` in our factory contract. Pass the parameters in order as client, dev, freeFlow, and true or false if the escrow contract deals in ether. (There is an example of ether and ERC20 in this deploy file currently.) You could also simply cut this part our of the deploy script and call `createNewEscrow()` on Etherscan.

Once your contracts have verified and the clones are made (check logs on Etherscan for the tx for `createNewEscrow()` from the factory contract) we will have the new contract addresses for our escrow agreements! Moving forward you can simply use all the functionality of etherscan for calling the functions.

If you want to use some of the scripts that are setup to test on rinkeby (or transform them for real deployment / interaction), first replace `ESCROW_CLONE` address in the javascript files with your new respective escrow contract address.

* `interactETH.js` will have the client deposit .01 ether into the contract, log out balances, and then call the withdraw functionality releasing the funds.
* `interactUSDT.js` will do the same with 1 Tether coin.
* `interactUSDC.js` will do the same with 1 USD coin.


## Summary:
1. git clone 
2. npm i
3. set up environment variables (must be wrapped in qutation marks)
  `RINKEBY_INFURA_ENDPOINT=""`  
  `RINKEBY_PRIVATE_KEY=""`  
  `ETHERSCAN_KEY=""`  
  `PRIVATE_KEY1=""`  
  `PRIVATE_KEY2=""`  
4. modify `createNewEscrow()` and pass in `client`, `dev`, `freeFlow`, and `true` or `false` if the escrow contract deals in ether or not
5. `npx hardhat run scripts/deployNewEscrowEthAndERC20.js --network rinkeby`
6. `npx hardhat verify [contract_address] --network rinkeby` (run this for both contracts)

## Other Notes
* **The current contract is setup pointing to Rinkeby addresses for USDC and USDT, replace them with mainnet addresses before deploying to mainnet!!!!**
* Be congnicent that you will need to account for the correct decimals, e.g. Ethereum is 1^18 while USDT/USDC are 1^6 (for some reason testnet USDT is 1^18). There are tools in `ethers.js` to help you with this or you can do the math if interacting with the variable inputs for the functions on Etherscan.
* Sometimes testnets can be finicky. If the testing scripts fail, try running them again if they got hung or give an error about gas. Another thing to check is Rinkeby has also been stalling out on blocks, not indexing TX's quickly and going down for a few hours every now and then. For this reason, I also recommend using small amounts of ether or USDC/USDT in these tests.
* Only USDC and USDT are accepted for the ERC20 functions.
* `refundClientAll()` in the smart contract will return all of the assets in escrow back to the client (only callable by freeFlow address).
* `refundClientMilestone(_amount)` in the smart contract will return amount of ether or USDC/USDT back to the client (only callable by freeFlow address).
* `killContract(_receiver)` in the smart contract will destroy the contract and return all funds back to the reveiver param (only callable by freeFlow address).


## .env setup

`RINKEBY_INFURA_ENDPOINT=`  
`RINKEBY_PRIVATE_KEY=`  
`ETHERSCAN_KEY=`  
`PRIVATE_KEY1=`  
`PRIVATE_KEY2=`
