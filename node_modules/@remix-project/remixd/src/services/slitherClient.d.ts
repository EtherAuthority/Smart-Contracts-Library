import * as WS from 'ws';
import { PluginClient } from '@remixproject/plugin';
import { OutputStandard } from '../types';
export declare class SlitherClient extends PluginClient {
    private readOnly;
    methods: Array<string>;
    websocket: WS;
    currentSharedFolder: string;
    constructor(readOnly?: boolean);
    setWebSocket(websocket: WS): void;
    sharedFolder(currentSharedFolder: string): void;
    mapNpmDepsDir(list: any): {
        remapString: string;
        allowPathString: string;
    };
    transform(detectors: Record<string, any>[]): OutputStandard[];
    analyse(filePath: string, compilerConfig: Record<string, any>): Promise<unknown>;
}
