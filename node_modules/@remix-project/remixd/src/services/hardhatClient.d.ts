/// <reference types="node" />
import * as WS from 'ws';
import { PluginClient } from '@remixproject/plugin';
import * as chokidar from 'chokidar';
export declare class HardhatClient extends PluginClient {
    private readOnly;
    methods: Array<string>;
    websocket: WS;
    currentSharedFolder: string;
    watcher: chokidar.FSWatcher;
    warnLog: boolean;
    buildPath: string;
    logTimeout: NodeJS.Timeout;
    processingTimeout: NodeJS.Timeout;
    constructor(readOnly?: boolean);
    setWebSocket(websocket: WS): void;
    sharedFolder(currentSharedFolder: string): void;
    startListening(): void;
    compile(configPath: string): Promise<unknown>;
    checkPath(): boolean;
    private processArtifact;
    listenOnHardHatFolder(): void;
    triggerProcessArtifact(): Promise<void>;
    listenOnHardhatCompilation(): void;
    sync(): Promise<void>;
    feedContractArtifactFile(artifactContent: any, compilationResultPart: any): Promise<void>;
}
