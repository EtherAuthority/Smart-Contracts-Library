import * as ServiceList from '../serviceList';
import * as Websocket from 'ws';
export interface OutputStandard {
    description: string;
    title: string;
    confidence: string;
    severity: string;
    sourceMap: any;
    category?: string;
    reference?: string;
    example?: any;
    [key: string]: any;
}
declare type ServiceListKeys = keyof typeof ServiceList;
export declare type Service = typeof ServiceList[ServiceListKeys];
export declare type ServiceClient = InstanceType<typeof ServiceList[ServiceListKeys]>;
export declare type WebsocketOpt = {
    remixIdeUrl: string;
};
export declare type FolderArgs = {
    path: string;
};
export declare type KeyPairString = {
    [key: string]: string;
};
export declare type ResolveDirectory = {
    [key: string]: {
        isDirectory: boolean;
    };
};
export declare type FileContent = {
    content: string;
    readonly: boolean;
};
export declare type SharedFolderArgs = FolderArgs & KeyPairString;
export declare type WS = typeof Websocket;
export declare type Filelist = KeyPairString;
export {};
