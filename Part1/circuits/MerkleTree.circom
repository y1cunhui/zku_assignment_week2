pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/gates.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    signal temp[2**n];
    component hash[2**n];
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    for (var i=0;i<2**n;i++) {
        temp[i] <== leaves[i];
    }

    var cnt = 0;
    for (var i = n;i > 0; i--) {
        for (var j = 0;j<=2**i-1;j = j+2) {
            hash[cnt] = Poseidon(2);
            hash[cnt].inputs[0] <== temp[i];
            hash[cnt].inputs[1] <== temp[i+1];
            temp[i] <== hash[cnt].out;
        }
    }
    root <== temp[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component switcher[n];
    component hasher[n];
    for (var i=0;i<n;i++) {
        switcher[i] = Switcher();
        switcher[i].L <== i==0 ? leaf : hasher[i-1].out;
        switcher[i].R <== path_elements[i];
        switcher[i].sel <== path_index[i];

        hasher[i] = Poseidon(2);
        hasher[i].inputs[0] <== switcher[i].outL;
        hasher[i].inputs[1] <== switcher[i].outR;
    }
    root <== hasher[n-1].out;
}