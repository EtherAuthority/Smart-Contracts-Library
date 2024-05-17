'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const remixdClient_1 = require("./services/remixdClient");
const gitClient_1 = require("./services/gitClient");
const hardhatClient_1 = require("./services/hardhatClient");
const truffleClient_1 = require("./services/truffleClient");
const slitherClient_1 = require("./services/slitherClient");
const websocket_1 = tslib_1.__importDefault(require("./websocket"));
const utils = tslib_1.__importStar(require("./utils"));
module.exports = {
    Websocket: websocket_1.default,
    utils,
    services: {
        sharedFolder: remixdClient_1.RemixdClient,
        GitClient: gitClient_1.GitClient,
        HardhatClient: hardhatClient_1.HardhatClient,
        TruffleClient: truffleClient_1.TruffleClient,
        SlitherClient: slitherClient_1.SlitherClient
    }
};
//# sourceMappingURL=index.js.map