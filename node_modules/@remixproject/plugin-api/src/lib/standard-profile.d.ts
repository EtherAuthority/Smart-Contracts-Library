import { ProfileMap } from '@remixproject/plugin-utils';
import { ICompiler } from './compiler';
import { IFileSystem } from './file-system/file-manager';
import { IEditor } from './editor';
import { INetwork } from './network';
import { IUdapp } from './udapp';
import { IPluginManager } from './plugin-manager';
export interface IStandardApi {
    manager: IPluginManager;
    solidity: ICompiler;
    fileManager: IFileSystem;
    editor: IEditor;
    network: INetwork;
    udapp: IUdapp;
}
export declare type StandardApi = Readonly<IStandardApi>;
/** Profiles of all the standard's Native Plugins */
export declare const standardProfiles: ProfileMap<StandardApi>;
