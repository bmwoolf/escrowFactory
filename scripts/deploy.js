const hre = require("hardhat");

async function main() {
  const [owner, user1] = await ethers.getSigners();
  provider = ethers.getDefaultProvider();

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

  const ERC1 = await ethers.getContractFactory("Fake1ERC20");
  e1 = await ERC1.connect(owner).deploy(deployAmount);
  await e1.deployed();
  console.log("Fake1ERC20 deployed to", e1.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
