const hre = require("hardhat");

async function main() {
  const Escrow = await ethers.getContractFactory("Escrow");
  const escrow = await Escrow.deploy();
  await escrow.deployed();

  const EscrowProxyFactory = await ethers.getContractFactory(
    "EscrowProxyFactory"
  );
  const epf = await EscrowProxyFactory.deploy(escrow.address);
  await epf.deployed();

  console.log(escrow.address, "Escrow base contract address");
  console.log(epf.address, "Minimal Proxy Escrow Factory contract address");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
