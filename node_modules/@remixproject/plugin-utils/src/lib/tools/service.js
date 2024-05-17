"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PluginService = exports.activateService = exports.createService = exports.getMethods = exports.isPluginService = void 0;
const tslib_1 = require("tslib");
const method_path_1 = require("./method-path");
/** Check if the plugin is an instance of PluginService */
exports.isPluginService = (service) => {
    return service instanceof PluginService;
};
/**
 * Return the methods of a service, except "constructor" and methods starting with "_"
 * @param instance The instance of a class to get the method from
 */
function getMethods(service) {
    // If service exposes methods, use them
    if (service.methods) {
        for (const method of service.methods) {
            if (!(method in service)) {
                throw new Error(`Method ${method} is not part of serivce`);
            }
        }
        return service.methods;
    }
    // Else get the public methods (without "_")
    if (exports.isPluginService(service)) {
        const methods = Object.getPrototypeOf(service);
        return Object.getOwnPropertyNames(methods).filter(m => {
            return m !== 'constructor' && !m.startsWith('_');
        });
    }
    else {
        return Object.getOwnPropertyNames(service).filter(key => {
            return typeof service[key] === 'function' && !key.startsWith('_');
        });
    }
}
exports.getMethods = getMethods;
/**
 * Create a plugin service
 * @param path The path of the service separated by '.' (ex: 'box.profile')
 * @param service The service template
 * @note If the service doesn't provide a property "methods" then all methods are going to be exposed by default
 */
function createService(path, service) {
    if (service.path && method_path_1.getRootPath(service.path) !== path) {
        throw new Error(`Service path ${service.path} is different from the one provided: ${path}`);
    }
    const methods = getMethods(service);
    for (const method of methods) {
        if (!(method in service)) {
            throw new Error(`Method ${method} is not part of service ${path}`);
        }
    }
    if (exports.isPluginService(service)) {
        if (!service.methods) {
            service.methods = methods;
        }
        return service;
    }
    else {
        return Object.assign(Object.assign({}, service), { methods, path });
    }
}
exports.createService = createService;
/**
 * Connect the service to the plugin client
 * @param client The main client of the plugin
 * @param service A service to activate
 */
function activateService(client, service) {
    client.methods = [
        ...(client.methods || []),
        ...service.methods
    ];
    const methods = getMethods(service);
    for (const method of methods) {
        client[`${service.path}.${method}`] = service[method].bind(service);
    }
    return client.call('manager', 'updateProfile', { methods: client.methods });
}
exports.activateService = activateService;
/**
 * A node that forward the call to the right path
 */
class PluginService {
    emit(key, ...payload) {
        this.plugin.emit(key, ...payload);
    }
    /**
     * Create a subservice under this service
     * @param name The name of the subservice inside this service
     * @param service The subservice to add
     */
    createService(name, service) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            if (this.methods.includes(name)) {
                throw new Error('A service cannot have the same name as an exposed method');
            }
            const path = `${this.path}.${name}`;
            const _service = createService(path, service);
            yield activateService(this.plugin, _service);
            return _service;
        });
    }
    /**
     * Prepare a service to be lazy loaded.
     * Service can be activated by doing `client.activateService(path)`
     * @param name The name of the subservice inside this service
     * @param factory A function to create the service on demand
     */
    prepareService(name, factory) {
        if (this.methods.includes(name)) {
            throw new Error('A service cannot have the same name as an exposed method');
        }
        const path = `${this.path}.${name}`;
        this.plugin.activateService[path] = () => tslib_1.__awaiter(this, void 0, void 0, function* () {
            const service = factory();
            const _service = createService(path, service);
            yield activateService(this.plugin, _service);
            delete this.plugin.activateService[path];
            return _service;
        });
    }
}
exports.PluginService = PluginService;
//# sourceMappingURL=service.js.map