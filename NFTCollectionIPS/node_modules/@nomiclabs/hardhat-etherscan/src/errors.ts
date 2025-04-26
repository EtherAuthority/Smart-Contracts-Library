import chalk from "chalk";
import { NomicLabsHardhatPluginError } from "hardhat/plugins";

import { pluginName } from "./constants";

export class HardhatEtherscanPluginError extends NomicLabsHardhatPluginError {
  constructor(
    name: string,
    message: string,
    parent?: Error,
    shouldBeReported = false
  ) {
    super(name, message, parent, shouldBeReported);

    console.warn(
      chalk.yellow(
        "DEPRECATION WARNING: 'hardhat-etherscan' has been deprecated in favor of 'hardhat-verify'. You can find more information about the migration in the readme."
      )
    );
  }
}

export function throwUnsupportedNetwork(
  networkName: string,
  chainID: number
): never {
  const message = `
Trying to verify a contract in a network with chain id ${chainID}, but the plugin doesn't recognize it as a supported chain.

You can manually add support for it by following these instructions: https://hardhat.org/verify-custom-networks

To see the list of supported networks, run this command:

  npx hardhat verify --list-networks`.trimStart();

  throw new HardhatEtherscanPluginError(pluginName, message);
}
