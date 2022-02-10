require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

// const KOVAN_INFURA_ENDPOINT = process.env.KOVAN_INFURA_ENDPOINT;
const RINKEBY_INFURA_ENDPOINT = process.env.RINKEBY_INFURA_ENDPOINT;
const KOVAN_INFURA_ENDPOINT = process.env.KOVAN_INFURA_ENDPOINT;
const ETHERSCAN_API = process.env.ETHERSCAN_API;
const CLIENT_PRIVATE_KEY = process.env.CLIENT_PRIVATE_KEY;
const DEV_PRIVATE_KEY = process.env.DEV_PRIVATE_KEY;

module.exports = {
  defaultNetwork: "rinkeby",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    rinkeby: {
      url: RINKEBY_INFURA_ENDPOINT,
      accounts: [CLIENT_PRIVATE_KEY, DEV_PRIVATE_KEY],
      gas: "auto",
    },
    kovan: {
      url: KOVAN_INFURA_ENDPOINT,
      accounts: [CLIENT_PRIVATE_KEY, DEV_PRIVATE_KEY],
      gas: "auto",
    },
  },
  solidity: {
    version: "0.8.11",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 2000000,
  },
};
