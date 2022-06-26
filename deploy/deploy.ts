import { deployments, getNamedAccounts } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

// Process Env Variables
import * as dotenv from "dotenv";
dotenv.config({ path: __dirname + "/../.env" });

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy('GroupManager', {
    from: deployer,
    args: [],
  })

  await deploy('WorldIDRegistry', {
    from: deployer,
    // worldId, from `https://developer.worldcoin.org/api/v1/contracts` (staging)
    args: ['0xABB70f7F39035586Da57B3c8136035f87AC0d2Aa'],
  })

  await deploy('ProofToken', {
    from: deployer,
    args: [''],
  })

  await deploy('Verification', {
    from: deployer,
    args: [
      // verifier pub keys
      [
        process.env.VERIFIER_ONE_PUBLIC,
        process.env.VERIFIER_TWO_PUBLIC,
        process.env.VERIFIER_THREE_PUBLIC,
      ],
      // admin pub key
      process.env.VERIFIER_ONE_PUBLIC,
      // token URI
      '',
    ],
  })
}

func.tags = ['WorldIDRegistry', 'ProofToken', 'Verification'];

export default func;