const { ethers } = require("hardhat");
const { constants, BigNumber, utils } = require("ethers");
const hre = require("hardhat");

const ERC20 = require("../artifacts/contracts/Fake1ERC20.sol/Fake1ERC20.json")
const ESCROW_CLONE = "0xE0C7a82dcDa2D9d14Bbfd3b54e8d2d25739d0aFe";
const ESCROW_CLONE_ABI = require("../artifacts/contracts/EscrowClone.sol/EscrowClone.json")

async function main() {
  const network = 'rinkeby' // use rinkeby testnet
  const provider = ethers.getDefaultProvider(network)
  //const provider = ethers.getDefaultProvider()

  const [owner, user1]  = await ethers.getSigners();

  const escrowContract = new ethers.Contract(ESCROW_CLONE, ESCROW_CLONE_ABI.abi, owner);

  let client = await escrowContract.client();
  console.log(client);
  console.log(owner.address)
  let dev = await escrowContract.dev();
  console.log(dev);

  const ownerBalance = await provider.getBalance(owner.address);
  console.log(utils.formatEther(ownerBalance));
  //const approve = await escrowContract.connect(owner).approve(ESCROW_CLONE, utils.parseEther('0.01'))
  //approve.wait();
  const tx = await escrowContract.connect(owner).depositETH({ value: utils.parseEther('0.01') });
  await tx.wait();
  console.log(await escrowContract.totalAmount());
  const ownerBalanceAfterDeposit = await provider.getBalance(owner.address);
  console.log(utils.formatEther(ownerBalanceAfterDeposit));


//   const user1Balance = await provider.getBalance(user1.address);
//   console.log(utils.formatEther(user1Balance));
//   const withdraw = await escrowContract.connect(user1).withdrawETH({ value: utils.parseEther('0.01') });
//   await withdraw.wait();
//   const user1BalanceAfterWithdraw = await provider.getBalance(user1.address);
//   console.log(utils.formatEther(user1BalanceAfterWithdraw));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });