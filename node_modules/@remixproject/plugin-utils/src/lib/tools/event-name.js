"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listenEvent = exports.callEvent = void 0;
/** Create the name of the event for a call */
function callEvent(name, key, id) {
    return `[${name}] ${key}-${id}`;
}
exports.callEvent = callEvent;
/** Create the name of the event for a listen */
function listenEvent(name, key) {
    return `[${name}] ${key}`;
}
exports.listenEvent = listenEvent;
//# sourceMappingURL=event-name.js.map