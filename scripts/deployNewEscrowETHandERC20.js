const { ethers } = require("hardhat");
const hre = require("hardhat");

const ERC20 = require("../artifacts/contracts/Fake1ERC20.sol/Fake1ERC20.json")

async function main() {

  const EscrowClone = await ethers.getContractFactory("EscrowClone");
  const escrowClone = await EscrowClone.deploy();
  await escrowClone.deployed();

  const EscrowCloneFactory = await ethers.getContractFactory("EscrowCloneFactory");
  const ecf = await EscrowCloneFactory.deploy(escrowClone.address);
  await ecf.deployed();

  console.log(escrowClone.address, "Escrow clone base contract address");
  console.log(ecf.address, "Minimal Clone Escrow Factory contract address");

  await new Promise(resolve => setTimeout(resolve, 60000));
  try {await hre.run("verify:verify", {
    address: escrowClone.address,
  }); } catch (e) {
    console.log(e);
  }
  
  await new Promise(resolve => setTimeout(resolve, 60000));
  try {await hre.run("verify:verify", {
    address: ecf.address,
    constructorArguments: [
      escrowClone.address
    ],
  }); } catch (e) {
    console.log(e);
  }

  tx = await ecf.createNewEscrow("0x29c36265c63fE0C3d024b2E4d204b49deeFdD671", // Client (Eric #1 test address)
                                 "0x48Fa9E29c4eCC20170aA565fFA2d60AB09c8f440", // Dev (Eric #2 test address)
                                 "0x1666c8F5E44f3f19eb7E25BD2954D8cd35685350", // Freeflow (CrossChain Address)
                                 true) 
  await tx.wait();
  
  tx = await ecf.createNewEscrow("0x29c36265c63fE0C3d024b2E4d204b49deeFdD671", // Client (Eric #1 test address)
                                 "0x48Fa9E29c4eCC20170aA565fFA2d60AB09c8f440", // Dev (Eric #2 test address)
                                 "0x1666c8F5E44f3f19eb7E25BD2954D8cd35685350", // Freeflow (CrossChain Address)
                                 false) 
  await tx.wait();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });