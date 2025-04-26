"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.patchEnableCustomRPC = void 0;
var tslib_1 = require("tslib");
var web3_core_method_1 = tslib_1.__importDefault(require("web3-core-method"));
var MethodFn = web3_core_method_1.default;
/**
 * Private method to enable adding custom RPC calls to the web3 object. This
 * allows the addition of custom endpoints to the web3 object.
 */
function patchEnableCustomRPC(web3) {
    web3.eth.customRPC = function (opts) {
        var newMethod = new MethodFn({
            name: opts.name,
            call: opts.call,
            params: opts.params || 0,
            inputFormatter: opts.inputFormatter || null,
            outputFormatter: opts.outputFormatter || null,
        });
        newMethod.attachToObject(this);
        newMethod.setRequestManager(this._requestManager, this.accounts);
    };
}
exports.patchEnableCustomRPC = patchEnableCustomRPC;
