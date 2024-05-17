import type { IPluginService, GetPluginService } from '../types/service';
import type { Api, ApiMap } from '../types/api';
import type { PluginBase } from '../types/plugin';
/** Check if the plugin is an instance of PluginService */
export declare const isPluginService: (service: any) => service is PluginService;
/**
 * Return the methods of a service, except "constructor" and methods starting with "_"
 * @param instance The instance of a class to get the method from
 */
export declare function getMethods(service: IPluginService): any;
/**
 * Create a plugin service
 * @param path The path of the service separated by '.' (ex: 'box.profile')
 * @param service The service template
 * @note If the service doesn't provide a property "methods" then all methods are going to be exposed by default
 */
export declare function createService<T extends Record<string, any>>(path: string, service: T): GetPluginService<T>;
/**
 * Connect the service to the plugin client
 * @param client The main client of the plugin
 * @param service A service to activate
 */
export declare function activateService<T extends Api = any, App extends ApiMap = any>(client: PluginBase<T, App>, service: IPluginService): any;
/**
 * A node that forward the call to the right path
 */
export declare abstract class PluginService implements IPluginService {
    methods: string[];
    abstract readonly path: string;
    protected abstract plugin: PluginBase;
    emit(key: string, ...payload: any[]): void;
    /**
     * Create a subservice under this service
     * @param name The name of the subservice inside this service
     * @param service The subservice to add
     */
    createService<S extends Record<string, any>>(name: string, service: S): Promise<GetPluginService<S>>;
    /**
     * Prepare a service to be lazy loaded.
     * Service can be activated by doing `client.activateService(path)`
     * @param name The name of the subservice inside this service
     * @param factory A function to create the service on demand
     */
    prepareService<S extends Record<string, any>>(name: string, factory: () => S): void;
}
