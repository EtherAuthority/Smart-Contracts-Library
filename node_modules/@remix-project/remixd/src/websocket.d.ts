/// <reference types="node" />
import * as WS from 'ws';
import * as http from 'http';
import { WebsocketOpt, ServiceClient } from './types';
export default class WebSocket {
    server: http.Server;
    wsServer: WS.Server;
    port: number;
    opt: WebsocketOpt;
    getclient: () => ServiceClient;
    constructor(port: number, opt: WebsocketOpt, getclient: () => ServiceClient);
    start(callback?: (ws: WS, client: ServiceClient, error?: Error) => void): void;
    close(): void;
}
