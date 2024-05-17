"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRootPath = exports.getMethodPath = void 0;
/** Create a method path based on the method name and the path */
function getMethodPath(method, path) {
    if (!path) {
        return method;
    }
    const part = path.split('.');
    part.shift();
    part.push(method);
    return part.join('.');
}
exports.getMethodPath = getMethodPath;
/** Get the root name of a path */
function getRootPath(path) {
    return path.split('.').shift();
}
exports.getRootPath = getRootPath;
//# sourceMappingURL=method-path.js.map