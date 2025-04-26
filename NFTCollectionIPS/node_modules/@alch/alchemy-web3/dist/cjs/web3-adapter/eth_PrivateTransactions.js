"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.patchEthPrivateTransactionMethods = void 0;
function patchEthPrivateTransactionMethods(web3) {
    web3.eth.customRPC({
        name: "sendPrivateTransaction",
        call: "eth_sendPrivateTransaction",
        params: 3,
    });
    web3.eth.customRPC({
        name: "cancelPrivateTransaction",
        call: "eth_cancelPrivateTransaction",
        params: 1,
    });
}
exports.patchEthPrivateTransactionMethods = patchEthPrivateTransactionMethods;
