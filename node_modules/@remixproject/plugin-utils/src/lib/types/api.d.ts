import { StatusEvents } from './status';
export interface Api {
    events: {
        [key: string]: (...args: any[]) => void;
    } & StatusEvents;
    methods: {
        [key: string]: (...args: any[]) => void;
    };
}
export declare type EventKey<T extends Api> = Extract<keyof T['events'], string>;
export declare type EventParams<T extends Api, K extends EventKey<T>> = T extends Api ? Parameters<T['events'][K]> : any[];
export declare type EventCallback<T extends Api, K extends EventKey<T>> = T extends Api ? T['events'][K] : (...payload: any[]) => void;
export declare type MethodKey<T extends Api> = Extract<keyof T['methods'], string>;
export declare type MethodParams<T extends Api, K extends MethodKey<T>> = T extends Api ? Parameters<T['methods'][K]> : any[];
export interface EventApi<T extends Api> {
    on: <event extends EventKey<T>>(name: event, cb: T['events'][event]) => void;
}
export declare type MethodApi<T extends Api> = {
    [m in Extract<keyof T['methods'], string>]: (...args: Parameters<T['methods'][m]>) => Promise<ReturnType<T['methods'][m]>>;
};
export declare type CustomApi<T extends Api> = EventApi<T> & MethodApi<T>;
/** A map of Api used to describe all the plugin's api in the project */
export declare type ApiMap = Readonly<Record<string, Api>>;
/** A map of plugin based on the ApiMap. It enforces the PluginEngine */
export declare type PluginApi<T extends ApiMap> = {
    [name in keyof T]: CustomApi<T[name]>;
};
export declare type API<T extends Api> = {
    [M in keyof T['methods']]: T['methods'][M] | Promise<T['methods'][M]>;
};
