//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](15);
        hashes[8] = PoseidonT3.poseidon([uint256(0), 0]);
        hashes[11] = hashes[10] = hashes[9] = hashes[8];
        hashes[12] = PoseidonT3.poseidon([hashes[8], hashes[9]]);
        hashes[13] = hashes[12];
        hashes[14] = PoseidonT3.poseidon([hashes[12], hashes[13]]);
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        uint index1 = 8+index/2;
        if (index % 2 == 0) {
            hashes[index1] = PoseidonT3.poseidon([hashes[index], hashes[index+1]]);
        } else {
            hashes[index1] = PoseidonT3.poseidon([hashes[index-1], hashes[index]]);
        }
        uint index2 = 12+(index1-8)/2;
        if (index1 % 2 == 0) {
            hashes[index2] = PoseidonT3.poseidon([hashes[index1], hashes[index1+1]]);
        } else {
            hashes[index2] = PoseidonT3.poseidon([hashes[index1-1], hashes[index1]]);
        }
        hashes[14] = PoseidonT3.poseidon([hashes[12], hashes[13]]);
        index++;
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

            return verifyProof(a, b, c, input);
        // [assignment] verify an inclusion proof and check that the proof root matches current root
    }
}
