/// <reference types="node" />
import * as WS from 'ws';
import { PluginClient } from '@remixproject/plugin';
import * as chokidar from 'chokidar';
export declare class FoundryClient extends PluginClient {
    private readOnly;
    methods: Array<string>;
    websocket: WS;
    currentSharedFolder: string;
    watcher: chokidar.FSWatcher;
    warnlog: boolean;
    buildPath: string;
    cachePath: string;
    logTimeout: NodeJS.Timeout;
    processingTimeout: NodeJS.Timeout;
    constructor(readOnly?: boolean);
    setWebSocket(websocket: WS): void;
    sharedFolder(currentSharedFolder: string): void;
    startListening(): void;
    listenOnFoundryFolder(): void;
    compile(): Promise<unknown>;
    checkPath(): boolean;
    private processArtifact;
    triggerProcessArtifact(): Promise<void>;
    listenOnFoundryCompilation(): void;
    readContract(contractFolder: any, compilationResultPart: any, cache: any): Promise<void>;
    feedContractArtifactFile(path: any, content: any, compilationResultPart: any, cache: any): Promise<void>;
    sync(): Promise<void>;
}
