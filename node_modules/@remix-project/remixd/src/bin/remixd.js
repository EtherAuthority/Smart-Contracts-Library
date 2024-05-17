#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const latest_version_1 = tslib_1.__importDefault(require("latest-version"));
const semver = tslib_1.__importStar(require("semver"));
const websocket_1 = tslib_1.__importDefault(require("../websocket"));
const servicesList = tslib_1.__importStar(require("../serviceList"));
const utils_1 = require("../utils");
const axios_1 = tslib_1.__importDefault(require("axios"));
const fs_extra_1 = require("fs-extra");
const path = tslib_1.__importStar(require("path"));
const commander_1 = require("commander");
const program = new commander_1.Command();
function warnLatestVersion() {
    return tslib_1.__awaiter(this, void 0, void 0, function* () {
        const latest = yield (0, latest_version_1.default)('@remix-project/remixd');
        const pjson = require('../../package.json'); // eslint-disable-line
        if (semver.eq(latest, pjson.version)) {
            console.log('\x1b[32m%s\x1b[0m', `[INFO] you are using the latest version ${latest}`);
        }
        else if (semver.gt(latest, pjson.version)) {
            console.log('\x1b[33m%s\x1b[0m', `[WARN] latest version of remixd is ${latest}, you are using ${pjson.version}`);
            console.log('\x1b[33m%s\x1b[0m', '[WARN] please update using the following command:');
            console.log('\x1b[33m%s\x1b[0m', '[WARN] yarn global add @remix-project/remixd');
        }
    });
}
const services = {
    git: (readOnly) => new servicesList.GitClient(readOnly),
    hardhat: (readOnly) => new servicesList.HardhatClient(readOnly),
    truffle: (readOnly) => new servicesList.TruffleClient(readOnly),
    slither: (readOnly) => new servicesList.SlitherClient(readOnly),
    folder: (readOnly) => new servicesList.Sharedfolder(readOnly),
    foundry: (readOnly) => new servicesList.FoundryClient(readOnly)
};
// Similar object is also defined in websocket.ts
const ports = {
    git: 65521,
    hardhat: 65522,
    slither: 65523,
    truffle: 65524,
    foundry: 65525,
    folder: 65520
};
const killCallBack = []; // any is function
function startService(service, callback) {
    const options = program.opts();
    const socket = new websocket_1.default(ports[service], { remixIdeUrl: options.remixIde }, () => services[service](options.readOnly || false));
    socket.start(callback);
    killCallBack.push(socket.close.bind(socket));
}
function errorHandler(error, service) {
    const port = ports[service];
    if (error.code && error.code === 'EADDRINUSE') {
        console.log('\x1b[31m%s\x1b[0m', `[ERR] There is already a client running on port ${port}!`);
    }
    else {
        console.log('\x1b[31m%s\x1b[0m', '[ERR]', error);
    }
}
(() => tslib_1.__awaiter(void 0, void 0, void 0, function* () {
    const { version } = require('../../package.json'); // eslint-disable-line
    program.version(version, '-v, --version');
    program
        .description('Establish a two-way websocket connection between the local computer and Remix IDE for a folder')
        .option('-u, --remix-ide  <url>', 'URL of remix instance allowed to connect')
        .option('-s, --shared-folder <path>', 'Folder to share with Remix IDE (Default: CWD)')
        .option('-i, --install <name>', 'Module name to install locally (Supported: ["slither"])')
        .option('-r, --read-only', 'Treat shared folder as read-only (experimental)')
        .on('--help', function () {
        console.log('\nExample:\n\n    remixd -s ./shared_project -u http://localhost:8080');
    }).parse(process.argv);
    // eslint-disable-next-line
    const options = program.opts();
    yield warnLatestVersion();
    if (options.install && !options.readOnly) {
        if (options.install.toLowerCase() === 'slither')
            require('./../scripts/installSlither');
        process.exit(0);
    }
    if (!options.remixIde) {
        console.log('\x1b[33m%s\x1b[0m', '[WARN] You can only connect to remixd from one of the supported origins.');
    }
    else {
        const isValid = yield isValidOrigin(options.remixIde);
        /* Allow unsupported origins and display warning. */
        if (!isValid) {
            console.log('\x1b[33m%s\x1b[0m', '[WARN] You are using IDE from an unsupported origin.');
            console.log('\x1b[33m%s\x1b[0m', 'Check https://gist.github.com/EthereumRemix/091ccc57986452bbb33f57abfb13d173 for list of all supported origins.\n');
            // return
        }
        console.log('\x1b[33m%s\x1b[0m', '[WARN] You may now only use IDE at ' + options.remixIde + ' to connect to that instance');
    }
    if (!options.sharedFolder)
        options.sharedFolder = process.cwd(); // if no specified, use the current folder
    if (options.sharedFolder && (0, fs_extra_1.existsSync)((0, utils_1.absolutePath)('./', options.sharedFolder))) {
        console.log('\x1b[33m%s\x1b[0m', '[WARN] Any application that runs on your computer can potentially read from and write to all files in the directory.');
        console.log('\x1b[33m%s\x1b[0m', '[WARN] Symbolic links are not forwarded to Remix IDE\n');
        try {
            startService('folder', (ws, sharedFolderClient, error) => {
                if (error) {
                    errorHandler(error, 'folder');
                    return false;
                }
                sharedFolderClient.setWebSocket(ws);
                sharedFolderClient.setupNotifications(options.sharedFolder);
                sharedFolderClient.sharedFolder(options.sharedFolder);
            });
            startService('slither', (ws, sharedFolderClient) => {
                sharedFolderClient.setWebSocket(ws);
                sharedFolderClient.sharedFolder(options.sharedFolder);
            });
            // Run truffle service if a truffle project is shared as folder
            const truffleConfigFilePath = (0, utils_1.absolutePath)('./', options.sharedFolder) + '/truffle-config.js';
            if ((0, fs_extra_1.existsSync)(truffleConfigFilePath)) {
                startService('truffle', (ws, sharedFolderClient, error) => {
                    if (error) {
                        errorHandler(error, 'truffle');
                        return false;
                    }
                    sharedFolderClient.setWebSocket(ws);
                    sharedFolderClient.sharedFolder(options.sharedFolder);
                });
            }
            // Run hardhat service if a hardhat project is shared as folder
            const hardhatConfigFilePath = (0, utils_1.absolutePath)('./', options.sharedFolder);
            const isHardhatProject = (0, fs_extra_1.existsSync)(hardhatConfigFilePath + '/hardhat.config.js') || (0, fs_extra_1.existsSync)(hardhatConfigFilePath + '/hardhat.config.ts');
            if (isHardhatProject) {
                startService('hardhat', (ws, sharedFolderClient, error) => {
                    if (error) {
                        errorHandler(error, 'hardhat');
                        return false;
                    }
                    sharedFolderClient.setWebSocket(ws);
                    sharedFolderClient.sharedFolder(options.sharedFolder);
                });
            }
            // Run foundry service if a founndry project is shared as folder
            const foundryConfigFilePath = (0, utils_1.absolutePath)('./', options.sharedFolder);
            const isFoundryProject = (0, fs_extra_1.existsSync)(foundryConfigFilePath + '/foundry.toml');
            if (isFoundryProject) {
                startService('foundry', (ws, sharedFolderClient, error) => {
                    if (error) {
                        errorHandler(error, 'foundry');
                        return false;
                    }
                    sharedFolderClient.setWebSocket(ws);
                    sharedFolderClient.sharedFolder(options.sharedFolder);
                });
            }
            /*
            startService('git', (ws: WS, sharedFolderClient: servicesList.Sharedfolder) => {
              sharedFolderClient.setWebSocket(ws)
              sharedFolderClient.sharedFolder(options.sharedFolder)
            })
            */
        }
        catch (error) {
            throw new Error(error);
        }
    }
    else {
        console.log('\x1b[31m%s\x1b[0m', '[ERR] No valid shared folder provided.');
    }
    // kill
    function kill() {
        for (const k in killCallBack) {
            try {
                killCallBack[k]();
            }
            catch (e) {
                console.log(e);
            }
        }
        process.exit(0);
    }
    process.on('SIGINT', kill); // catch ctrl-c
    process.on('SIGTERM', kill); // catch kill
    process.on('exit', kill);
    function isValidOrigin(origin) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            if (!origin)
                return false;
            const domain = (0, utils_1.getDomain)(origin);
            const gistUrl = 'https://gist.githubusercontent.com/EthereumRemix/091ccc57986452bbb33f57abfb13d173/raw/59cedab38ae94cc72b68854b3706f11819e4a0af/origins.json';
            try {
                const { data } = (yield axios_1.default.get(gistUrl));
                try {
                    yield (0, fs_extra_1.writeJSON)(path.resolve(path.join(__dirname, '../..', 'origins.json')), { data });
                }
                catch (e) {
                    console.error(e);
                }
                const dataArray = data;
                return dataArray.includes(origin) ? dataArray.includes(origin) : dataArray.includes(domain);
            }
            catch (e) {
                try {
                    // eslint-disable-next-line
                    const origins = require('../../origins.json');
                    const { data } = origins;
                    return data.includes(origin) ? data.includes(origin) : data.includes(domain);
                }
                catch (e) {
                    return false;
                }
            }
        });
    }
}))();
//# sourceMappingURL=remixd.js.map