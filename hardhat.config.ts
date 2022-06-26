import { HardhatUserConfig } from "hardhat/config";

// PLUGINS
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-deploy";

// Process Env Variables
import * as dotenv from "dotenv";
dotenv.config({ path: __dirname + "/.env" });

const PK_MUMBAI = process.env.PK_MUMBAI;

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",

  // hardhat-deploy
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },

  networks: {
    mumbai: {
      accounts: PK_MUMBAI ? [PK_MUMBAI] : [],
      chainId: 80001,
      url: 'wss://rpc-mumbai.matic.today', // https://rpc-mumbai.matic.today
    },
  },

  etherscan: {
    // apiKey: ETHERSCAN_API_KEY ? ETHERSCAN_API_KEY : "",
  },

  solidity: {
    compilers: [
      {
        version: "0.8.15",
        settings: {
          optimizer: { enabled: true, runs: 200 },
        },
      },
    ],
  },

  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
};

export default config;
