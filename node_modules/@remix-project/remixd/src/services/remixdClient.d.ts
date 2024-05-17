import { PluginClient } from '@remixproject/plugin';
import { SharedFolderArgs, Filelist, ResolveDirectory, FileContent } from '../types';
import * as WS from 'ws';
import * as chokidar from 'chokidar';
export declare class RemixdClient extends PluginClient {
    private readOnly;
    methods: Array<string>;
    websocket: WS;
    currentSharedFolder: string;
    watcher: chokidar.FSWatcher;
    trackDownStreamUpdate: Record<string, string>;
    constructor(readOnly?: boolean);
    setWebSocket(websocket: WS): void;
    sharedFolder(currentSharedFolder: string): void;
    list(): Filelist;
    resolveDirectory(args: SharedFolderArgs): ResolveDirectory;
    folderIsReadOnly(): boolean;
    get(args: SharedFolderArgs): Promise<FileContent>;
    exists(args: SharedFolderArgs): boolean;
    set(args: SharedFolderArgs): Promise<unknown>;
    createDir(args: SharedFolderArgs): Promise<unknown>;
    rename(args: SharedFolderArgs): Promise<boolean>;
    remove(args: SharedFolderArgs): Promise<boolean>;
    _isFile(path: string): boolean;
    isDirectory(args: SharedFolderArgs): boolean;
    isFile(args: SharedFolderArgs): boolean;
    setupNotifications(path: string): void;
}
