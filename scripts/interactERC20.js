const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const hre = require("hardhat");

const ERC20 = require("../artifacts/contracts/Fake1ERC20.sol/Fake1ERC20.json")
const ESCROW_CLONE = "0xF2db45F9778fd8922b9CE9e5BFf398b5aEaBb4eB";
const ESCROW_CLONE_ABI = require("../artifacts/contracts/EscrowClone.sol/EscrowClone.json");

async function main() {
  const network = 'rinkeby' // use rinkeby testnet
  const provider = ethers.getDefaultProvider(network)

  const [client, dev]  = await ethers.getSigners();

  const escrowContract = new ethers.Contract(ESCROW_CLONE, ESCROW_CLONE_ABI.abi, client);

  console.log(client.address)

  // Make fake ERC20 to pass into escrow (minted by client in constructor)
  const ERC20 = await ethers.getContractFactory("Fake1ERC20");
  const erc20 = await ERC20.deploy(1000);
  console.log("Fake ERC20 deployed to:", erc20.address)

  // Approve depositing the ERC20 into the contract
  const clientApprove = await erc20.connect(client).approve(ESCROW_CLONE, 500);
  clientApprove.wait();
  console.log("Approved Fake ERC20");

  // Get initial client balance
//   const clientBalance = await erc20.balanceOf(client.address).toString();
//   await clientBalance.wait();
//   console.log("Client balance before deposit:", clientBalance);
  // Deposit client funds
  const tx = await escrowContract.connect(client).depositToken("500", erc20.address);
  await tx.wait();
  // Get total amount in escrow
  const contractBalance = await escrowContract.totalAmount();
  console.log("Contract balance after deposit:", contractBalance);
  // Get balance of client after deposit
//   const clientBalanceAfterDeposit = await erc20.balanceOf(client.address).toString();
//   console.log("Client balance after deposit:", clientBalanceAfterDeposit);

  // Get balance of dev before
//   const devBalance = await erc20.balanceOf(dev.address).toString();
//   console.log("Dev balance before withdraw:", devBalance);
  // Withdraw from escrow called by client
  const withdraw = await escrowContract.connect(client).withdrawERC20(500);
  await withdraw.wait();
  // Get balance of dev after withdraw
//   const devBalanceAfterWithdraw = await erc20.balanceOf(dev.address).toString();
//   console.log("Dev balance after withdraw:", devBalanceAfterWithdraw);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });