# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

## .env setup

`RINKEBY_URL=`  
`RINKEBY_PRIVATE_KEY=`  
`ETHERSCAN_KEY=`  
`PRIVATE_KEY1=`  
`PRIVATE_KEY2=`

## verification

`npx hardhat verify EscrowProxyFactory_rinkeby_address --network rinkeby Escrow_contract_address`  
`npx hardhat verify Escrow_rinkeby_address --network rinkeby`
