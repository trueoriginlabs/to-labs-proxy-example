import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-contract-sizer";
import "hardhat-gas-reporter";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.4.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  // Comment this out when doing mainnet/testnet deploys
  gasReporter: {
    enabled: true,
    currency: "USD", // currency to show,
    gasPriceApi: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice", //to fetch gas data
    coinmarketcap: "",
    token: "ETH", // for polygon blockchain(optional).
  },
  // paths:{
  //   sources: "src/contracts/contracts/",

  // }
  // etherscan: {
  //   apiKey: "",
  // },
  networks: {
    hardhat: {
      // allowUnlimitedContractSize: true,
      mining: {
        auto: false,
        interval: 2000
      }
    },
    // mainnet: {
    //   url: `https://mainnet.infura.io/v3/`,
    //   accounts: [
    //     // Enter Private Keys Here
    //     ``
    //   ],
    //   gas: 30000000,
    //   gasMultiplier: 1.05
    // },
  },
  
};

export default config;
