/// <reference types="node" />
import { Base } from './Base';
declare type TValue = Buffer | BigInt | string | number | null | undefined;
declare type THashFn = (value: TValue) => Buffer;
export declare class Bucket {
    size: BigInt;
    hashed: Buffer;
    parent: Bucket | null;
    left: Bucket | null;
    right: Bucket | null;
    constructor(size: BigInt | number, hashed: Buffer);
}
export declare class Leaf {
    hashFn: THashFn;
    rng: BigInt[];
    data: Buffer | null;
    constructor(hashFn: THashFn, rng: (number | BigInt)[], data: Buffer | null);
    getBucket(): Bucket;
}
export declare class ProofStep {
    bucket: Bucket;
    right: boolean;
    constructor(bucket: Bucket, right: boolean);
}
export declare class MerkleSumTree extends Base {
    hashFn: THashFn;
    leaves: Leaf[];
    buckets: Bucket[];
    root: Bucket;
    constructor(leaves: Leaf[], hashFn: THashFn);
    sizeToBuffer(size: BigInt): Buffer;
    static checkConsecutive(leaves: Leaf[]): void;
    getProof(index: number | BigInt): any[];
    sum(arr: BigInt[]): bigint;
    verifyProof(root: Bucket, leaf: Leaf, proof: ProofStep[]): boolean;
}
export default MerkleSumTree;
