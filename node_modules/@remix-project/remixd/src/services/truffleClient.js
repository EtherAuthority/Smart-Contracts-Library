"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TruffleClient = void 0;
const tslib_1 = require("tslib");
const plugin_1 = require("@remixproject/plugin");
const chokidar = tslib_1.__importStar(require("chokidar"));
const utils = tslib_1.__importStar(require("../utils"));
const fs = tslib_1.__importStar(require("fs-extra"));
const path_1 = require("path");
const { spawn } = require('child_process'); // eslint-disable-line
class TruffleClient extends plugin_1.PluginClient {
    constructor(readOnly = false) {
        super();
        this.readOnly = readOnly;
        this.methods = ['compile', 'sync'];
        this.onActivation = () => {
            console.log('Truffle plugin activated');
            this.call('terminal', 'log', { type: 'log', value: 'Truffle plugin activated' });
            this.startListening();
        };
    }
    setWebSocket(websocket) {
        this.websocket = websocket;
        this.websocket.addEventListener('close', () => {
            this.warnLog = false;
            if (this.watcher)
                this.watcher.close();
        });
    }
    sharedFolder(currentSharedFolder) {
        this.currentSharedFolder = currentSharedFolder;
        this.buildPath = utils.absolutePath('build/contracts', this.currentSharedFolder);
    }
    startListening() {
        if (fs.existsSync(this.buildPath)) {
            this.listenOnTruffleCompilation();
        }
        else {
            this.listenOnTruffleFolder();
        }
    }
    listenOnTruffleFolder() {
        console.log('Truffle build folder doesn\'t exist... waiting for the compilation.');
        try {
            if (this.watcher)
                this.watcher.close();
            this.watcher = chokidar.watch(this.currentSharedFolder, { depth: 2, ignorePermissionErrors: true, ignoreInitial: true });
            // watch for new folders
            this.watcher.on('addDir', () => {
                if (fs.existsSync(this.buildPath)) {
                    this.listenOnTruffleCompilation();
                }
            });
        }
        catch (e) {
            console.log(e);
        }
    }
    compile(configPath) {
        return new Promise((resolve, reject) => {
            if (this.readOnly) {
                const errMsg = '[Truffle Compilation]: Cannot compile in read-only mode';
                return reject(new Error(errMsg));
            }
            const cmd = `truffle compile --config ${configPath}`;
            const options = { cwd: this.currentSharedFolder, shell: true };
            const child = spawn(cmd, options);
            let result = '';
            let error = '';
            child.stdout.on('data', (data) => {
                const msg = `[Truffle Compilation]: ${data.toString()}`;
                console.log('\x1b[32m%s\x1b[0m', msg);
                result += msg + '\n';
            });
            child.stderr.on('data', (err) => {
                error += `[Truffle Compilation]: ${err.toString()} \n`;
            });
            child.on('close', () => {
                if (error && result)
                    resolve(error + result);
                else if (error)
                    reject(error);
                else
                    resolve(result);
            });
        });
    }
    checkPath() {
        if (!fs.existsSync(this.buildPath)) {
            this.listenOnTruffleFolder();
            return false;
        }
        return true;
    }
    processArtifact() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            if (!this.checkPath())
                return;
            const folderFiles = yield fs.readdir(this.buildPath);
            const filesFound = folderFiles.filter(file => file.endsWith('.json'));
            // name of folders are file names
            for (const file of folderFiles) {
                if (file.endsWith('.json')) {
                    const compilationResult = {
                        input: {},
                        output: {
                            contracts: {},
                            sources: {}
                        },
                        solcVersion: null,
                        compilationTarget: null
                    };
                    const content = yield fs.readFile((0, path_1.join)(this.buildPath, file), { encoding: 'utf-8' });
                    yield this.feedContractArtifactFile(file, content, compilationResult);
                    this.emit('compilationFinished', compilationResult.compilationTarget, { sources: compilationResult.input }, 'soljson', compilationResult.output, compilationResult.solcVersion);
                }
            }
            clearTimeout(this.logTimeout);
            this.logTimeout = setTimeout(() => {
                if (filesFound.length === 0) {
                    // @ts-ignore
                    this.call('terminal', 'log', { value: 'No contract found in the Truffle build folder', type: 'log' });
                }
                else {
                    // @ts-ignore
                    this.call('terminal', 'log', { value: 'receiving compilation result from Truffle', type: 'log' });
                    console.log('Syncing compilation result from Truffle');
                }
            }, 1000);
        });
    }
    triggerProcessArtifact() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            // prevent multiple calls
            clearTimeout(this.processingTimeout);
            this.processingTimeout = setTimeout(() => tslib_1.__awaiter(this, void 0, void 0, function* () { return yield this.processArtifact(); }), 1000);
        });
    }
    listenOnTruffleCompilation() {
        try {
            if (this.watcher)
                this.watcher.close();
            this.watcher = chokidar.watch(this.buildPath, { depth: 3, ignorePermissionErrors: true, ignoreInitial: true });
            this.watcher.on('change', () => tslib_1.__awaiter(this, void 0, void 0, function* () { return yield this.triggerProcessArtifact(); }));
            this.watcher.on('add', () => tslib_1.__awaiter(this, void 0, void 0, function* () { return yield this.triggerProcessArtifact(); }));
            // process the artifact on activation
            this.triggerProcessArtifact();
        }
        catch (e) {
            console.log(e);
        }
    }
    feedContractArtifactFile(path, content, compilationResultPart) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const contentJSON = JSON.parse(content);
            const contractName = (0, path_1.basename)(path).replace('.json', '');
            compilationResultPart.solcVersion = contentJSON.compiler.version;
            // file name in artifacts starts with `project:/`
            const filepath = contentJSON.ast.absolutePath.startsWith('project:/') ? contentJSON.ast.absolutePath.replace('project:/', '') : contentJSON.ast.absolutePath;
            compilationResultPart.compilationTarget = filepath;
            compilationResultPart.input[path] = { content: contentJSON.source };
            // extract data
            const relPath = utils.relativePath(filepath, this.currentSharedFolder);
            if (!compilationResultPart.output['sources'][relPath])
                compilationResultPart.output['sources'][relPath] = {};
            const location = contentJSON.ast.src.split(':');
            const id = parseInt(location[location.length - 1]);
            compilationResultPart.output['sources'][relPath] = {
                ast: contentJSON.ast,
                id
            };
            if (!compilationResultPart.output['contracts'][relPath])
                compilationResultPart.output['contracts'][relPath] = {};
            // delete contentJSON['ast']
            compilationResultPart.output['contracts'][relPath][contractName] = {
                abi: contentJSON.abi,
                evm: {
                    bytecode: {
                        object: contentJSON.bytecode.replace('0x', ''),
                        sourceMap: contentJSON.sourceMap,
                        linkReferences: contentJSON.linkReferences
                    },
                    deployedBytecode: {
                        object: contentJSON.deployedBytecode.replace('0x', ''),
                        sourceMap: contentJSON.deployedSourceMap,
                        linkReferences: contentJSON.deployedLinkReferences
                    }
                }
            };
        });
    }
    sync() {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            this.processArtifact();
        });
    }
}
exports.TruffleClient = TruffleClient;
//# sourceMappingURL=truffleClient.js.map