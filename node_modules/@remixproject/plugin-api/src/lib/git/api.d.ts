import { StatusEvents } from '@remixproject/plugin-utils';
export interface IGitSystem {
    events: {} & StatusEvents;
    methods: {
        clone(url: string): string;
        checkout(cmd: string): string;
        init(): string;
        add(cmd: string): string;
        commit(cmd: string): string;
        fetch(cmd: string): string;
        pull(cmd: string): string;
        push(cmd: string): string;
        reset(cmd: string): string;
        status(cmd: string): string;
        remote(cmd: string): string;
        log(): string;
    };
}
