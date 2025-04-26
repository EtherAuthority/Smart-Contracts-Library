import { NomicLabsHardhatPluginError } from "hardhat/plugins";
export declare class HardhatEtherscanPluginError extends NomicLabsHardhatPluginError {
    constructor(name: string, message: string, parent?: Error, shouldBeReported?: boolean);
}
export declare function throwUnsupportedNetwork(networkName: string, chainID: number): never;
//# sourceMappingURL=errors.d.ts.map