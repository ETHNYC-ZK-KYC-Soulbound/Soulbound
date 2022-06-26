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
const PK_GNOSIS = process.env.PK_GNOSIS;

const config: HardhatUserConfig = {
  defaultNetwork: "sokol",

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
      url: 'https://rpc.ankr.com/polygon_mumbai', // https://rpc-mumbai.matic.today
    },
    sokol: {
      accounts: PK_GNOSIS ? [PK_GNOSIS] : [],
      chainId: 77,
      url: 'https://sokol.poa.network/',
    },
    gnosis: {
      accounts: PK_GNOSIS ? [PK_GNOSIS] : [],
      chainId: 100,
      url: ' https://rpc.gnosischain.com/',
    },
  },

  etherscan: {
    // apiKey: ETHERSCAN_API_KEY ? ETHERSCAN_API_KEY : "",
  },

  solidity: {
    compilers: [
      {
        version: "0.8.10",
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
