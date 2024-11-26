const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

const addresses = [
  "0xd6dA2E5D49B02d7e41def7A9c9FE451E3984E4A8",
  "0x54864E485A2b1d7CD6548e1bFFaAE483d826Ed33",
  "0x8B36C15167A3C2512BA07d194b32A0D74FB9609D",
  "0xFCAd0B19bB29D4674531d6f115237E16AfCE377c",
];

// Function to generate Merkle Tree and proofs
function generateMerkleTree(addresses) {
  const tree = StandardMerkleTree.of(
    addresses.map((addr) => [addr]),
    ["address"]
  );

  console.log("Merkle Root:", tree.root);

  const proofs = {};
  addresses.forEach((address) => {
    const proof = tree.getProof([address]);
    proofs[address] = proof;
    console.log(`Proof for ${address}:`, proof);
  });

  // Save Merkle Tree and proofs to a JSON file
  const output = {
    root: tree.root,
    proofs,
  };

  fs.writeFileSync("merkle-tree-output.json", JSON.stringify(output, null, 2));
  console.log("Merkle Tree and proofs saved to merkle-tree-output.json");
}

// Generate the Merkle Tree
generateMerkleTree(addresses);
