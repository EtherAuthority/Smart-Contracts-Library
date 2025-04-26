"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getVersions = exports.getLongVersion = void 0;
const constants_1 = require("../constants");
const errors_1 = require("../errors");
const undici_1 = require("../undici");
const COMPILERS_LIST_URL = "https://solc-bin.ethereum.org/bin/list.json";
// TODO: this could be retrieved from the hardhat config instead.
async function getLongVersion(shortVersion) {
    const versions = await getVersions();
    const fullVersion = versions.releases[shortVersion];
    if (fullVersion === undefined || fullVersion === "") {
        throw new errors_1.HardhatEtherscanPluginError(constants_1.pluginName, "Given solc version doesn't exist");
    }
    return fullVersion.replace(/(soljson-)(.*)(.js)/, "$2");
}
exports.getLongVersion = getLongVersion;
async function getVersions() {
    try {
        // It would be better to query an etherscan API to get this list but there's no such API yet.
        const response = await (0, undici_1.sendGetRequest)(new URL(COMPILERS_LIST_URL));
        if (!(response.statusCode >= 200 && response.statusCode <= 299)) {
            const responseText = await response.body.text();
            throw new errors_1.HardhatEtherscanPluginError(constants_1.pluginName, `HTTP response is not ok. Status code: ${response.statusCode} Response text: ${responseText}`);
        }
        return (await response.body.json());
    }
    catch (error) {
        throw new errors_1.HardhatEtherscanPluginError(constants_1.pluginName, `Failed to obtain list of solc versions. Reason: ${error.message}`, error);
    }
}
exports.getVersions = getVersions;
//# sourceMappingURL=version.js.map