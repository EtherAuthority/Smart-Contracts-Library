"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.throwUnsupportedNetwork = exports.HardhatEtherscanPluginError = void 0;
const chalk_1 = __importDefault(require("chalk"));
const plugins_1 = require("hardhat/plugins");
const constants_1 = require("./constants");
class HardhatEtherscanPluginError extends plugins_1.NomicLabsHardhatPluginError {
    constructor(name, message, parent, shouldBeReported = false) {
        super(name, message, parent, shouldBeReported);
        console.warn(chalk_1.default.yellow("DEPRECATION WARNING: 'hardhat-etherscan' has been deprecated in favor of 'hardhat-verify'. You can find more information about the migration in the readme."));
    }
}
exports.HardhatEtherscanPluginError = HardhatEtherscanPluginError;
function throwUnsupportedNetwork(networkName, chainID) {
    const message = `
Trying to verify a contract in a network with chain id ${chainID}, but the plugin doesn't recognize it as a supported chain.

You can manually add support for it by following these instructions: https://hardhat.org/verify-custom-networks

To see the list of supported networks, run this command:

  npx hardhat verify --list-networks`.trimStart();
    throw new HardhatEtherscanPluginError(constants_1.pluginName, message);
}
exports.throwUnsupportedNetwork = throwUnsupportedNetwork;
//# sourceMappingURL=errors.js.map