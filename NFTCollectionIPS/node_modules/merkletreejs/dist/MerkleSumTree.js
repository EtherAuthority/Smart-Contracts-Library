"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MerkleSumTree = exports.ProofStep = exports.Leaf = exports.Bucket = void 0;
const Base_1 = require("./Base");
class Bucket {
    constructor(size, hashed) {
        this.size = BigInt(size);
        this.hashed = hashed;
        // each node in the tree can have a parent, and a left or right sibling
        this.parent = null;
        this.left = null;
        this.right = null;
    }
}
exports.Bucket = Bucket;
class Leaf {
    constructor(hashFn, rng, data) {
        this.hashFn = hashFn;
        this.rng = rng.map(x => BigInt(x));
        this.data = data;
    }
    getBucket() {
        let hashed;
        if (this.data) {
            hashed = this.hashFn(this.data);
        }
        else {
            hashed = Buffer.alloc(32);
        }
        return new Bucket(BigInt(this.rng[1]) - BigInt(this.rng[0]), hashed);
    }
}
exports.Leaf = Leaf;
class ProofStep {
    constructor(bucket, right) {
        this.bucket = bucket;
        this.right = right; // whether the bucket hash should be appeded on the right side in this step (default is left
    }
}
exports.ProofStep = ProofStep;
class MerkleSumTree extends Base_1.Base {
    constructor(leaves, hashFn) {
        super();
        this.leaves = leaves;
        this.hashFn = hashFn;
        MerkleSumTree.checkConsecutive(leaves);
        this.buckets = [];
        for (const l of leaves) {
            this.buckets.push(l.getBucket());
        }
        let buckets = [];
        for (const bucket of this.buckets) {
            buckets.push(bucket);
        }
        while (buckets.length !== 1) {
            const newBuckets = [];
            while (buckets.length) {
                if (buckets.length >= 2) {
                    const b1 = buckets.shift();
                    const b2 = buckets.shift();
                    const size = b1.size + b2.size;
                    const hashed = this.hashFn(Buffer.concat([this.sizeToBuffer(b1.size), this.bufferify(b1.hashed), this.sizeToBuffer(b2.size), this.bufferify(b2.hashed)]));
                    const b = new Bucket(size, hashed);
                    b2.parent = b;
                    b1.parent = b2.parent;
                    b1.right = b2;
                    b2.left = b1;
                    newBuckets.push(b);
                }
                else {
                    newBuckets.push(buckets.shift());
                }
            }
            buckets = newBuckets;
        }
        this.root = buckets[0];
    }
    sizeToBuffer(size) {
        const buf = Buffer.alloc(8);
        const view = new DataView(buf.buffer);
        view.setBigInt64(0, BigInt(size), false); // true when little endian
        return buf;
    }
    static checkConsecutive(leaves) {
        let curr = BigInt(0);
        for (const leaf of leaves) {
            if (leaf.rng[0] !== curr) {
                throw new Error('leaf ranges are invalid');
            }
            curr = BigInt(leaf.rng[1]);
        }
    }
    // gets inclusion/exclusion proof of a bucket in the specified index
    getProof(index) {
        let curr = this.buckets[Number(index)];
        const proof = [];
        while (curr && curr.parent) {
            const right = !!curr.right;
            const bucket = curr.right ? curr.right : curr.left;
            curr = curr.parent;
            proof.push(new ProofStep(bucket, right));
        }
        return proof;
    }
    sum(arr) {
        let total = BigInt(0);
        for (const value of arr) {
            total += BigInt(value);
        }
        return total;
    }
    // validates the suppplied proof for a specified leaf according to the root bucket
    verifyProof(root, leaf, proof) {
        const rng = [this.sum(proof.filter(x => !x.right).map(x => x.bucket.size)), BigInt(root.size) - this.sum(proof.filter(x => x.right).map(x => x.bucket.size))];
        if (!(rng[0] === leaf.rng[0] && rng[1] === leaf.rng[1])) {
            // supplied steps are not routing to the range specified
            return false;
        }
        let curr = leaf.getBucket();
        let hashed;
        for (const step of proof) {
            if (step.right) {
                hashed = this.hashFn(Buffer.concat([this.sizeToBuffer(curr.size), this.bufferify(curr.hashed), this.sizeToBuffer(step.bucket.size), this.bufferify(step.bucket.hashed)]));
            }
            else {
                hashed = this.hashFn(Buffer.concat([this.sizeToBuffer(step.bucket.size), this.bufferify(step.bucket.hashed), this.sizeToBuffer(curr.size), this.bufferify(curr.hashed)]));
            }
            curr = new Bucket(BigInt(curr.size) + BigInt(step.bucket.size), hashed);
        }
        return curr.size === root.size && curr.hashed.toString('hex') === root.hashed.toString('hex');
    }
}
exports.MerkleSumTree = MerkleSumTree;
if (typeof window !== 'undefined') {
    ;
    window.MerkleSumTree = MerkleSumTree;
}
exports.default = MerkleSumTree;
