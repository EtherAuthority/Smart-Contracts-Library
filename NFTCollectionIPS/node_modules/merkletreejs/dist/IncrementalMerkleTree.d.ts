import Base from './Base';
export interface Options {
    depth?: number;
    arity?: number;
    zeroValue?: any;
}
export declare class IncrementalMerkleTree extends Base {
    private depth?;
    private arity?;
    private zeroes?;
    private root?;
    private nodes?;
    private hashFn;
    private zeroValue;
    constructor(hashFn: any, options: Options);
    getRoot(): any;
    getHexRoot(): string;
    insert(leaf: any): void;
    delete(index: number): void;
    update(index: number, newLeaf: any): void;
    getDepth(): number;
    getArity(): number;
    getMaxLeaves(): number;
    indexOf(leaf: any): number;
    getLeaves(): bigint[];
    copyList(list: any[]): bigint[];
    getLayers(): any[];
    getHexLayers(): string[];
    getLayersAsObject(): any;
    computeRoot(): any;
    getProof(index: number): any;
    verify(proof: any): boolean;
    toString(): string;
    protected toTreeString(): string;
}
export default IncrementalMerkleTree;
