"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.standardProfiles = void 0;
const compiler_1 = require("./compiler");
const file_manager_1 = require("./file-system/file-manager");
const editor_1 = require("./editor");
const network_1 = require("./network");
const udapp_1 = require("./udapp");
const plugin_manager_1 = require("./plugin-manager");
/** Profiles of all the standard's Native Plugins */
exports.standardProfiles = Object.freeze({
    manager: plugin_manager_1.pluginManagerProfile,
    solidity: Object.assign(Object.assign({}, compiler_1.compilerProfile), { name: 'solidity' }),
    fileManager: Object.assign(Object.assign({}, file_manager_1.filSystemProfile), { name: 'fileManager' }),
    editor: editor_1.editorProfile,
    network: network_1.networkProfile,
    udapp: udapp_1.udappProfile,
});
//# sourceMappingURL=standard-profile.js.map