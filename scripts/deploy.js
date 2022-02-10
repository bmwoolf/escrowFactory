const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  const EscrowClone = await ethers.getContractFactory("EscrowClone");
  const escrowClone = await EscrowClone.deploy();
  await escrowClone.deployed();

  const EscrowCloneFactory = await ethers.getContractFactory("EscrowCloneFactory");
  const ecf = await EscrowCloneFactory.deploy(escrowClone.address);
  await ecf.deployed();

  console.log(escrowClone.address, "Escrow clone base contract address");
  console.log(ecf.address, "Minimal Clone Escrow Factory contract address");

  await new Promise((resolve) => setTimeout(resolve, 60000));
  try {
    await hre.run("verify:verify", {
      address: escrowClone.address,
    });
  } catch (e) {
    console.log(e);
  }

  await new Promise((resolve) => setTimeout(resolve, 60000));
  try {
    await hre.run("verify:verify", {
      address: ecf.address,
      constructorArguments: [escrowClone.address],
    });
  } catch (e) {
    console.log(e);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
