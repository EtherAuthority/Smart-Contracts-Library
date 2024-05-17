import { ResolveDirectory, Filelist } from './types';
/**
 * returns the absolute path of the given @arg path
 *
 * @param {String} path - relative path (Unix style which is the one used by Remix IDE)
 * @param {String} sharedFolder - absolute shared path. platform dependent representation.
 * @return {String} platform dependent absolute path (/home/user1/.../... for unix, c:\user\...\... for windows)
 */
declare function absolutePath(path: string, sharedFolder: string): string;
/**
 * return the relative path of the given @arg path
 *
 * @param {String} path - absolute platform dependent path
 * @param {String} sharedFolder - absolute shared path. platform dependent representation
 * @return {String} relative path (Unix style which is the one used by Remix IDE)
 */
declare function relativePath(path: string, sharedFolder: string): string;
declare function normalizePath(path: any): any;
declare function walkSync(dir: string, filelist: Filelist, sharedFolder: string): Filelist;
declare function resolveDirectory(dir: string, sharedFolder: string): ResolveDirectory;
/**
 * returns the absolute path of the given @arg url
 *
 * @param {String} url - Remix-IDE URL instance
 * @return {String} extracted domain name from url
 */
declare function getDomain(url: string): string;
export { absolutePath, relativePath, walkSync, resolveDirectory, getDomain, normalizePath };
