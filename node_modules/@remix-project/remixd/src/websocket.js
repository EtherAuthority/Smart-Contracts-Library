"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const WS = tslib_1.__importStar(require("ws"));
const http = tslib_1.__importStar(require("http"));
const utils_1 = require("./utils");
const plugin_ws_1 = require("@remixproject/plugin-ws");
class WebSocket {
    constructor(port, opt, getclient) {
        this.port = port;
        this.opt = opt;
        this.getclient = getclient;
    } //eslint-disable-line
    start(callback) {
        this.server = http.createServer((request, response) => {
            console.log((new Date()) + ' Received request for ' + request.url);
            response.writeHead(404);
            response.end();
        });
        const loopback = '127.0.0.1';
        const listeners = {
            65520: 'remixd',
            65521: 'git',
            65522: 'hardhat',
            65523: 'slither',
            65524: 'truffle',
            65525: 'foundry'
        };
        this.server.on('error', (error) => {
            if (callback)
                callback(null, null, error);
        });
        this.server.listen(this.port, loopback, () => {
            console.log('\x1b[32m%s\x1b[0m', `[INFO] ${new Date()} ${listeners[this.port]} is listening on ${loopback}:${this.port}`);
        });
        this.wsServer = new WS.Server({
            server: this.server,
            verifyClient: (info, done) => {
                if (!originIsAllowed(info.origin, this)) {
                    done(false);
                    console.log(`${new Date()} connection from origin  ${info.origin}`);
                    return;
                }
                done(true);
            }
        });
        this.wsServer.on('connection', (ws, socket) => {
            const client = this.getclient();
            (0, plugin_ws_1.createClient)(ws, client);
            if (callback)
                callback(ws, client);
        });
    }
    close() {
        if (this.wsServer) {
            this.wsServer.close(() => {
                this.server.close();
            });
        }
    }
}
exports.default = WebSocket;
function originIsAllowed(origin, self) {
    if (self.opt.remixIdeUrl) {
        if (self.opt.remixIdeUrl.endsWith('/'))
            self.opt.remixIdeUrl = self.opt.remixIdeUrl.slice(0, -1);
        return origin === self.opt.remixIdeUrl || origin === (0, utils_1.getDomain)(self.opt.remixIdeUrl);
    }
    else {
        try {
            // eslint-disable-next-line
            const origins = require('../origins.json');
            const domain = (0, utils_1.getDomain)(origin);
            const { data } = origins;
            if (data.includes(origin) || data.includes(domain)) {
                self.opt.remixIdeUrl = origin;
                console.log('\x1b[33m%s\x1b[0m', '[WARN] You may now only use IDE at ' + self.opt.remixIdeUrl + ' to connect to that instance');
                return true;
            }
            else {
                return false;
            }
        }
        catch (e) {
            return false;
        }
    }
}
//# sourceMappingURL=websocket.js.map