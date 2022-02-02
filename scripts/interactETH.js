const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const hre = require("hardhat");

const ERC20 = require("../artifacts/contracts/Fake1ERC20.sol/Fake1ERC20.json")
const ESCROW_CLONE = "0xA60bc3799a4B7e0b6Ce4D4B8e769Ec5c9Fbb0943";
const ESCROW_CLONE_ABI = require("../artifacts/contracts/EscrowClone.sol/EscrowClone.json");

async function main() {
  const network = 'rinkeby' // use rinkeby testnet
  const provider = ethers.getDefaultProvider(network)
  //const provider = ethers.getDefaultProvider()

  const [client, dev]  = await ethers.getSigners();

  const escrowContract = new ethers.Contract(ESCROW_CLONE, ESCROW_CLONE_ABI.abi, client);

  console.log(client.address)

  // Get initial client balance
  const clientBalance = await provider.getBalance(client.address);
  console.log(utils.formatEther(clientBalance));
  // Deposit client funds
  const tx = await escrowContract.connect(client).depositETH({ value: utils.parseEther('0.01') });
  await tx.wait();
  // Get total amount in escrow
  const contractBalance = await escrowContract.totalAmount();
  console.log(utils.formatEther(contractBalance));
  // Get balance of client after deposit
  const clientBalanceAfterDeposit = await provider.getBalance(client.address);
  console.log(utils.formatEther(clientBalanceAfterDeposit));

  // Get balance of dev before
  const devBalance = await provider.getBalance(dev.address);
  console.log(utils.formatEther(devBalance));
  // Withdraw from escrow called by client
  const withdraw = await escrowContract.connect(client).withdrawETH({ value: utils.parseEther('0.01') });
  await withdraw.wait();
  // Get balance of dev after withdraw
  const devBalanceAfterWithdraw = await provider.getBalance(dev.address);
  console.log(utils.formatEther(devBalanceAfterWithdraw));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });