const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const hre = require("hardhat");

const ERC20 = require("../artifacts/contracts/Fake1ERC20.sol/Fake1ERC20.json")
const ESCROW_CLONE = "0x6dFf2a32DD09Cf51847f172ca15e3781E9C991DE";
const USDC_RINKEBY = "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b";
//const USDT_RINKEBY = "0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02";
const ESCROW_CLONE_ABI = require("../artifacts/contracts/EscrowClone.sol/EscrowClone.json");

async function main() {
  const network = 'rinkeby' // use rinkeby testnet
  const provider = ethers.getDefaultProvider(network)

  const [client, dev]  = await ethers.getSigners();

  const escrowContract = new ethers.Contract(ESCROW_CLONE, ESCROW_CLONE_ABI.abi, client);

  usdcContract = new ethers.Contract(USDC_RINKEBY, ERC20, client);

  // Approve depositing the USDC into the contract
  const clientApprove = await usdcContract.connect(client).approve(ESCROW_CLONE, 10);
  clientApprove.wait();
  console.log("Client approved Fake ERC20");
  
  // Get initial client balance
  const clientBalance = await usdcContract.balanceOf(client.address).toString();
  await clientBalance.wait();
  console.log("Client balance before deposit:", clientBalance);
  
  // Deposit client funds
  const tx = await escrowContract.connect(client).depositToken(10, USDC_RINKEBY);
  await tx.wait();
  // Get total amount in escrow
  const contractBalance = await escrowContract.totalAmount();
  console.log("Contract balance after deposit:", contractBalance);
  // Get balance of client after deposit
  const clientBalanceAfterDeposit = await usdcContract.balanceOf(client.address).toString();
  console.log("Client balance after deposit:", clientBalanceAfterDeposit);

  // Get balance of dev before
  const devBalance = await usdcContract.balanceOf(dev.address).toString();
  console.log("Dev balance before withdraw:", devBalance);
  // Withdraw from escrow called by client
  const withdraw = await escrowContract.connect(client).withdrawERC20(10);
  await withdraw.wait();
  // Get balance of dev after withdraw
  const devBalanceAfterWithdraw = await usdcContract.balanceOf(dev.address).toString();
  console.log("Dev balance after withdraw:", devBalanceAfterWithdraw);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });