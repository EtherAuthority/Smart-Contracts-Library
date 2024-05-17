"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GitClient = void 0;
const plugin_1 = require("@remixproject/plugin");
const { spawn } = require('child_process'); // eslint-disable-line
class GitClient extends plugin_1.PluginClient {
    constructor(readOnly = false) {
        super();
        this.readOnly = readOnly;
        this.methods = ['execute'];
    }
    setWebSocket(websocket) {
        this.websocket = websocket;
    }
    sharedFolder(currentSharedFolder) {
        this.currentSharedFolder = currentSharedFolder;
    }
    execute(cmd) {
        assertCommand(cmd);
        const options = { cwd: this.currentSharedFolder, shell: true };
        const child = spawn(cmd, options);
        let result = '';
        let error = '';
        return new Promise((resolve, reject) => {
            child.stdout.on('data', (data) => {
                result += data.toString();
            });
            child.stderr.on('data', (err) => {
                error += err.toString();
            });
            child.on('close', () => {
                if (error)
                    reject(error);
                else
                    resolve(result);
            });
        });
    }
}
exports.GitClient = GitClient;
/**
 * Validate that command can be run by service
 * @param cmd
 */
function assertCommand(cmd) {
    const regex = '^git\\s[^&|;]*$';
    if (!RegExp(regex).test(cmd)) { // git then space and then everything else
        throw new Error('Invalid command for service!');
    }
}
//# sourceMappingURL=gitClient.js.map