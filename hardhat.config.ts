import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const isBinanceNetwork = process.argv.includes("binance");

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  networks: {
    hardhat: {},
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL!!,
      accounts: [process.env.PRIVATE_KEY!!],
    },
    binance: {
      url: process.env.BINANNCE_RPC_URL!!,
      accounts: [process.env.PRIVATE_KEY!!],
    },
  },
  etherscan: {
    apiKey: isBinanceNetwork
      ? process.env.BINANCESCAN_API_KEY!!
      : process.env.ETHERSCAN_API_KEY!!,
  },
  sourcify: {
    enabled: true
  }
};

export default config;
