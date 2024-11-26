// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/Marketplace.sol";

contract DeployMarketplace is Script {
    function run() external {
        // Load the deployer's private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer's address
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the Marketplace contract
        Marketplace marketplace = new Marketplace();

        // Initialize the contract
        marketplace.initialize();

        // Log the contract address
        console.log("Marketplace contract deployed at:", address(marketplace));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
