"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RemixdClient = void 0;
const tslib_1 = require("tslib");
const plugin_1 = require("@remixproject/plugin");
const utils = tslib_1.__importStar(require("../utils"));
const chokidar = tslib_1.__importStar(require("chokidar"));
const fs = tslib_1.__importStar(require("fs-extra"));
const isbinaryfile = tslib_1.__importStar(require("isbinaryfile"));
const pathModule = tslib_1.__importStar(require("path"));
class RemixdClient extends plugin_1.PluginClient {
    constructor(readOnly = false) {
        super();
        this.readOnly = readOnly;
        this.trackDownStreamUpdate = {};
        this.methods = ['folderIsReadOnly', 'resolveDirectory', 'get', 'exists', 'isFile', 'set', 'rename', 'remove', 'isDirectory', 'list', 'createDir', 'canDeactivate'];
    }
    setWebSocket(websocket) {
        this.websocket = websocket;
        this.websocket.addEventListener('close', () => {
            if (this.watcher)
                this.watcher.close();
        });
    }
    sharedFolder(currentSharedFolder) {
        this.currentSharedFolder = currentSharedFolder;
        if (this.isLoaded)
            this.emit('rootFolderChanged', this.currentSharedFolder);
    }
    list() {
        try {
            return utils.walkSync(this.currentSharedFolder, {}, this.currentSharedFolder);
        }
        catch (e) {
            throw new Error(e);
        }
    }
    resolveDirectory(args) {
        try {
            const path = utils.absolutePath(args.path, this.currentSharedFolder);
            const result = utils.resolveDirectory(path, this.currentSharedFolder);
            return result;
        }
        catch (e) {
            throw new Error(e);
        }
    }
    folderIsReadOnly() {
        return this.readOnly;
    }
    get(args) {
        try {
            return new Promise((resolve, reject) => {
                const path = utils.absolutePath(args.path, this.currentSharedFolder);
                if (!fs.existsSync(path)) {
                    return reject(new Error('File not found ' + path));
                }
                if (!isRealPath(path))
                    return;
                isbinaryfile.default(path, (error, isBinary) => {
                    if (error)
                        console.log(error);
                    if (isBinary) {
                        resolve({ content: '<binary content not displayed>', readonly: true });
                    }
                    else {
                        fs.readFile(path, 'utf8', (error, data) => {
                            if (error)
                                console.log(error);
                            resolve({ content: data, readonly: false });
                        });
                    }
                });
            });
        }
        catch (error) {
            throw new Error(error);
        }
    }
    exists(args) {
        try {
            const path = utils.absolutePath(args.path, this.currentSharedFolder);
            return fs.existsSync(path);
        }
        catch (error) {
            throw new Error(error);
        }
    }
    set(args) {
        try {
            return new Promise((resolve, reject) => {
                if (this.readOnly)
                    return reject(new Error('Cannot write file: read-only mode selected'));
                const path = utils.absolutePath(args.path, this.currentSharedFolder);
                const exists = fs.existsSync(path);
                if (exists && !isRealPath(path))
                    return reject(new Error(''));
                if (args.content === 'undefined') { // no !!!!!
                    console.log('trying to write "undefined" ! stopping.');
                    return reject(new Error('trying to write "undefined" ! stopping.'));
                }
                if (!exists && args.path.indexOf('/') !== -1) {
                    // the last element is the filename and we should remove it
                    this.createDir({ path: args.path.substr(0, args.path.lastIndexOf('/')) });
                }
                try {
                    this.trackDownStreamUpdate[path] = args.content;
                    fs.writeFile(path, args.content, 'utf8', (error) => {
                        if (error) {
                            console.log(error);
                            return reject(error);
                        }
                        resolve(true);
                    });
                }
                catch (e) {
                    return reject(e);
                }
                if (!exists) {
                    this.emit('fileAdded', args.path);
                }
                else {
                    this.emit('fileChanged', args.path);
                }
            });
        }
        catch (error) {
            throw new Error(error);
        }
    }
    createDir(args) {
        try {
            return new Promise((resolve, reject) => {
                if (this.readOnly)
                    return reject(new Error('Cannot create folder: read-only mode selected'));
                const paths = args.path.split('/').filter(value => value);
                if (paths.length && paths[0] === '')
                    paths.shift();
                let currentCheck = '';
                paths.forEach((value) => {
                    currentCheck = currentCheck ? currentCheck + '/' + value : value;
                    const path = utils.absolutePath(currentCheck, this.currentSharedFolder);
                    if (!fs.existsSync(path)) {
                        fs.mkdirp(path);
                        this.emit('folderAdded', currentCheck);
                    }
                });
                resolve(true);
            });
        }
        catch (error) {
            throw new Error(error);
        }
    }
    rename(args) {
        try {
            return new Promise((resolve, reject) => {
                if (this.readOnly)
                    return reject(new Error('Cannot rename file: read-only mode selected'));
                const oldpath = utils.absolutePath(args.oldPath, this.currentSharedFolder);
                if (!fs.existsSync(oldpath)) {
                    return reject(new Error('File not found ' + oldpath));
                }
                const newpath = utils.absolutePath(args.newPath, this.currentSharedFolder);
                if (!isRealPath(oldpath))
                    return;
                fs.move(oldpath, newpath, (error) => {
                    if (error) {
                        console.log(error);
                        return reject(error.message);
                    }
                    this.emit('fileRenamed', args.oldPath, args.newPath);
                    resolve(true);
                });
            });
        }
        catch (error) {
            throw new Error(error);
        }
    }
    remove(args) {
        try {
            return new Promise((resolve, reject) => {
                if (this.readOnly)
                    return reject(new Error('Cannot remove file: read-only mode selected'));
                const path = utils.absolutePath(args.path, this.currentSharedFolder);
                if (!fs.existsSync(path))
                    return reject(new Error('File not found ' + path));
                if (!isRealPath(path))
                    return;
                // Saving the content of the item{folder} before removing it
                const ls = [];
                try {
                    const resolveList = (path) => {
                        if (!this._isFile(path)) {
                            const list = utils.resolveDirectory(path, this.currentSharedFolder);
                            Object.keys(list).forEach(itemPath => {
                                if (list[itemPath].isDirectory) {
                                    resolveList(`${this.currentSharedFolder}/${itemPath}`);
                                }
                                ls.push(itemPath);
                            });
                        }
                    };
                    resolveList(path);
                    ls.push(args.path);
                }
                catch (e) {
                    throw new Error(e);
                }
                return fs.remove(path, (error) => {
                    if (error) {
                        console.log(error);
                        return reject(new Error('Failed to remove file/directory: ' + error));
                    }
                    for (const file in ls) {
                        this.emit('fileRemoved', ls[file]);
                    }
                    resolve(true);
                });
            });
        }
        catch (error) {
            throw new Error(error);
        }
    }
    _isFile(path) {
        try {
            return fs.statSync(path).isFile();
        }
        catch (error) {
            throw new Error(error);
        }
    }
    isDirectory(args) {
        try {
            const path = utils.absolutePath(args.path, this.currentSharedFolder);
            return fs.statSync(path).isDirectory();
        }
        catch (error) {
            throw new Error(error);
        }
    }
    isFile(args) {
        try {
            const path = utils.absolutePath(args.path, this.currentSharedFolder);
            return fs.statSync(path).isFile();
        }
        catch (error) {
            throw new Error(error);
        }
    }
    setupNotifications(path) {
        const absPath = utils.absolutePath('./', path);
        if (!isRealPath(absPath))
            return;
        this.watcher = chokidar.watch(path, { depth: 2, ignorePermissionErrors: true });
        console.log('setup notifications for ' + path);
        /* we can't listen on created file / folder
        watcher.on('add', (f, stat) => {
          isbinaryfile(f, (error, isBinary) => {
            if (error) console.log(error)
            console.log('add', f)
            this.emit('created', { path: utils.relativePath(f, this.currentSharedFolder), isReadOnly: isBinary, isFolder: false })
          })
        })
        watcher.on('addDir', (f, stat) => {
          this.emit('created', { path: utils.relativePath(f, this.currentSharedFolder), isReadOnly: false, isFolder: true })
        })
        */
        this.watcher.on('change', (f) => tslib_1.__awaiter(this, void 0, void 0, function* () {
            const path = pathModule.resolve(f);
            const currentContent = this.trackDownStreamUpdate[path];
            const newContent = fs.readFileSync(f, 'utf-8');
            if (currentContent !== newContent && this.isLoaded) {
                this.emit('changed', utils.relativePath(f, this.currentSharedFolder));
            }
        }));
        this.watcher.on('unlink', (f) => tslib_1.__awaiter(this, void 0, void 0, function* () {
            if (this.isLoaded) {
                this.emit('removed', utils.relativePath(f, this.currentSharedFolder), false);
            }
        }));
        this.watcher.on('unlinkDir', (f) => tslib_1.__awaiter(this, void 0, void 0, function* () {
            if (this.isLoaded) {
                this.emit('removed', utils.relativePath(f, this.currentSharedFolder), true);
            }
        }));
    }
}
exports.RemixdClient = RemixdClient;
function isRealPath(path) {
    const realPath = fs.realpathSync(path);
    const isRealPath = path === realPath;
    const mes = '[WARN] Symbolic link modification not allowed : ' + path + ' | ' + realPath;
    if (!isRealPath) {
        console.log('\x1b[33m%s\x1b[0m', mes);
        // throw new Error(mes)
    }
    return isRealPath;
}
//# sourceMappingURL=remixdClient.js.map