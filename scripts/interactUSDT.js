const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const hre = require("hardhat");

const ERC20 = require("../artifacts/contracts/Fake1ERC20.sol/Fake1ERC20.json")
const ESCROW_CLONE = "0xd965A6517Ecd6763e9f0b974722487509b094607";
const USDT_RINKEBY = "0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02";
const ESCROW_CLONE_ABI = require("../artifacts/contracts/EscrowClone.sol/EscrowClone.json");

async function main() {
  const network = 'rinkeby' // use rinkeby testnet
  const provider = ethers.getDefaultProvider(network)

  const [client, dev]  = await ethers.getSigners();

  const escrowContract = new ethers.Contract(ESCROW_CLONE, ESCROW_CLONE_ABI.abi, client);

  usdtContract = new ethers.Contract(USDT_RINKEBY, ERC20.abi, client);

  // Approve depositing the USDT into the contract
  const clientApprove = await usdtContract.connect(client).approve(ESCROW_CLONE, 10000000000000000000000000000000);
  clientApprove.wait();
  console.log("Client approved Rinkeby USDT...");
  
  // Get initial client balance
  const clientBalance = await usdtContract.balanceOf(client.address);
  console.log("Client balance before deposit:", utils.formatEther(clientBalance));
  
  // Deposit client funds
  const tx = await escrowContract.connect(client).depositERC20(10000000000000000000000000000000, USDT_RINKEBY);
  await tx.wait();
  // Get total amount in escrow
  const contractBalance = await escrowContract.totalAmount();
  console.log("Contract balance after deposit:", utils.formatEther(contractBalance));
  // Get balance of client after deposit
  const clientBalanceAfterDeposit = await usdtContract.balanceOf(client.address);
  console.log("Client balance after deposit:", utils.formatEther(clientBalanceAfterDeposit));

  // Get balance of dev before
  const devBalance = await usdtContract.balanceOf(dev.address);
  console.log("Dev balance before withdraw:", utils.formatEther(devBalance));
  // Withdraw from escrow called by client
  const withdraw = await escrowContract.connect(client).withdrawERC20(10000000000000000000000000000000);
  await withdraw.wait();
  // Get balance of dev after withdraw
  const devBalanceAfterWithdraw = await usdtContract.balanceOf(dev.address);
  console.log("Dev balance after withdraw:", utils.formatEther(devBalanceAfterWithdraw));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });