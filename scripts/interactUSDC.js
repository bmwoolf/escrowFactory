const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const hre = require("hardhat");

const ERC20 = require("../artifacts/contracts/Fake1ERC20.sol/Fake1ERC20.json")
const ESCROW_CLONE = "0xB81efA890C666803554683EC2c9a2DE714b63345";
const USDC_RINKEBY = "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b";
const ESCROW_CLONE_ABI = require("../artifacts/contracts/EscrowClone.sol/EscrowClone.json");

async function main() {
  const network = 'rinkeby' // use rinkeby testnet
  const provider = ethers.getDefaultProvider(network)

  const [client, dev]  = await ethers.getSigners();

  const escrowContract = new ethers.Contract(ESCROW_CLONE, ESCROW_CLONE_ABI.abi, client);

  usdcContract = new ethers.Contract(USDC_RINKEBY, ERC20.abi, client);

  // Approve depositing the USDC into the contract
  const clientApprove = await usdcContract.connect(client).approve(ESCROW_CLONE, 10);
  clientApprove.wait();
  console.log("Client approved USDC Rinkeby");
  
  // Get initial client balance
  const clientBalance = await usdcContract.balanceOf(client.address);
  await clientBalance.wait();
  console.log("Client balance before deposit:", utils.formatEther(clientBalance));
  
  // Deposit client funds
  const tx = await escrowContract.connect(client).depositERC20(10, USDC_RINKEBY);
  await tx.wait();
  // Get total amount in escrow
  const contractBalance = await escrowContract.totalAmount();
  console.log("Contract balance after deposit:", utils.formatEther(contractBalance));
  // Get balance of client after deposit
  const clientBalanceAfterDeposit = await usdcContract.balanceOf(client.address);
  console.log("Client balance after deposit:", utils.formatEther(clientBalanceAfterDeposit));

  // Get balance of dev before
  const devBalance = await usdcContract.balanceOf(dev.address);
  console.log("Dev balance before withdraw:", utils.formatEther(devBalance));
  // Withdraw from escrow called by client
  const withdraw = await escrowContract.connect(client).withdrawERC20(10);
  await withdraw.wait();
  // Get balance of dev after withdraw
  const devBalanceAfterWithdraw = await usdcContract.balanceOf(dev.address);
  console.log("Dev balance after withdraw:", utils.formatEther(devBalanceAfterWithdraw));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });