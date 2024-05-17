import * as WS from 'ws';
import { PluginClient } from '@remixproject/plugin';
export declare class GitClient extends PluginClient {
    private readOnly;
    methods: Array<string>;
    websocket: WS;
    currentSharedFolder: string;
    constructor(readOnly?: boolean);
    setWebSocket(websocket: WS): void;
    sharedFolder(currentSharedFolder: string): void;
    execute(cmd: string): Promise<unknown>;
}
