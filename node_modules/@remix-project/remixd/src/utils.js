"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizePath = exports.getDomain = exports.resolveDirectory = exports.walkSync = exports.relativePath = exports.absolutePath = void 0;
const tslib_1 = require("tslib");
const fs = tslib_1.__importStar(require("fs-extra"));
const isbinaryfile = tslib_1.__importStar(require("isbinaryfile"));
const pathModule = tslib_1.__importStar(require("path"));
/**
 * returns the absolute path of the given @arg path
 *
 * @param {String} path - relative path (Unix style which is the one used by Remix IDE)
 * @param {String} sharedFolder - absolute shared path. platform dependent representation.
 * @return {String} platform dependent absolute path (/home/user1/.../... for unix, c:\user\...\... for windows)
 */
function absolutePath(path, sharedFolder) {
    path = normalizePath(path);
    path = pathModule.resolve(sharedFolder, path);
    if (!isSubDirectory(pathModule.resolve(process.cwd(), sharedFolder), path))
        throw new Error('Cannot read/write to path outside shared folder.');
    return path;
}
exports.absolutePath = absolutePath;
/**
 * returns a true if child is sub-directory of parent.
 *
 * @param {String} parent - path to parent directory
 * @param {String} child - child path
 * @return {Boolean}
 */
function isSubDirectory(parent, child) {
    if (!parent)
        return false;
    if (parent === child)
        return true;
    const relative = pathModule.relative(parent, child);
    return !!relative && relative.split(pathModule.sep)[0] !== '..';
}
/**
 * return the relative path of the given @arg path
 *
 * @param {String} path - absolute platform dependent path
 * @param {String} sharedFolder - absolute shared path. platform dependent representation
 * @return {String} relative path (Unix style which is the one used by Remix IDE)
 */
function relativePath(path, sharedFolder) {
    const relative = pathModule.relative(sharedFolder, path);
    return convertPathToPosix(normalizePath(relative));
}
exports.relativePath = relativePath;
const convertPathToPosix = (pathName) => {
    return pathName.split(pathModule.sep).join(pathModule.posix.sep);
};
function normalizePath(path) {
    if (path === '/')
        path = './';
    if (process.platform === 'win32') {
        return path.replace(/\//g, '\\');
    }
    return path;
}
exports.normalizePath = normalizePath;
function walkSync(dir, filelist, sharedFolder) {
    const files = fs.readdirSync(dir);
    filelist = filelist || {};
    files.forEach(function (file) {
        const subElement = pathModule.join(dir, file);
        let isSymbolicLink;
        try {
            isSymbolicLink = !fs.lstatSync(subElement).isSymbolicLink();
        }
        catch (error) {
            isSymbolicLink = false;
        }
        if (isSymbolicLink) {
            if (fs.statSync(subElement).isDirectory()) {
                filelist = walkSync(subElement, filelist, sharedFolder);
            }
            else {
                const relative = relativePath(subElement, sharedFolder);
                filelist[relative] = isbinaryfile.sync(subElement);
            }
        }
    });
    return filelist;
}
exports.walkSync = walkSync;
function resolveDirectory(dir, sharedFolder) {
    const ret = {};
    const files = fs.readdirSync(dir);
    files.forEach(function (file) {
        const subElement = pathModule.join(dir, file);
        let isSymbolicLink;
        try {
            isSymbolicLink = !fs.lstatSync(subElement).isSymbolicLink();
        }
        catch (error) {
            isSymbolicLink = false;
        }
        if (isSymbolicLink) {
            const relative = relativePath(subElement, sharedFolder);
            ret[relative] = { isDirectory: fs.statSync(subElement).isDirectory() };
        }
    });
    return ret;
}
exports.resolveDirectory = resolveDirectory;
/**
 * returns the absolute path of the given @arg url
 *
 * @param {String} url - Remix-IDE URL instance
 * @return {String} extracted domain name from url
 */
function getDomain(url) {
    // eslint-disable-next-line
    const domainMatch = url.match(/^(?:https?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n?]+)/img);
    return domainMatch ? domainMatch[0] : null;
}
exports.getDomain = getDomain;
//# sourceMappingURL=utils.js.map