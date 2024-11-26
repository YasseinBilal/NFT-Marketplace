// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/NFT.sol";

contract DeployNFT is Script {
    function run() external {
        // Load the deployer's private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer's address
        vm.startBroadcast(deployerPrivateKey);

        // Constructor arguments
        string memory name = "MyNFT";
        string memory symbol = "MNFT";
        string memory baseTokenURI = "https://example.com/api/token/";

        // Deploy the contract
        NFT nft = new NFT(name, symbol, baseTokenURI);

        // Log the contract address
        console.log("NFT contract deployed at:", address(nft));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
