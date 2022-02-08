const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const hre = require("hardhat");

const ESCROW_CLONE = "0xd965A6517Ecd6763e9f0b974722487509b094607";
const ESCROW_CLONE_ABI = require("../artifacts/contracts/EscrowClone.sol/EscrowClone.json");

// This won't work because these functions are to be called by freeflow and I don't have their keys!

async function main() {
  const network = 'rinkeby' // use rinkeby testnet
  const provider = ethers.getDefaultProvider(network)

  const [client, dev]  = await ethers.getSigners();

  const escrowContract = new ethers.Contract(ESCROW_CLONE, ESCROW_CLONE_ABI.abi, client);

  // Get initial client balance
  const clientBalance = await provider.getBalance(client.address);
  console.log("Client balance before deposit:", utils.formatEther(clientBalance));
  
  // Deposit client funds
  const tx = await escrowContract.connect(client).depositETH({ value: utils.parseEther('0.01') });
  await tx.wait();

  // Get total amount in escrow
  const contractBalance = await escrowContract.totalAmount();
  console.log("Contract balance after deposit:", utils.formatEther(contractBalance));
  
  // Get balance of client after deposit
  const clientBalanceAfterDeposit = await provider.getBalance(client.address);
  console.log("Client balance after deposit:", utils.formatEther(clientBalanceAfterDeposit));

  // Refund from escrow called by client
  const withdraw = await escrowContract.connect(client).refundClientAll();
  await withdraw.wait();
  
  // Get balance of client after refund
  const clientBalanceAfterRefund = await provider.getBalance(client.address);
  console.log("Client balance after refund:", utils.formatEther(clientBalanceAfterRefund));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });