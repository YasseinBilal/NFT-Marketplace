// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/Marketplace.sol";
import "../src/Proxy.sol";

contract DeployMarketplaceProxy is Script {
    function run() external {
        // Load the deployer's private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer's address
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the implementation contract (Marketplace)
        Marketplace marketplace = new Marketplace();

        // Initialize calldata for the proxy
        bytes memory initializeCalldata = abi.encodeWithSignature(
            "initialize()"
        );

        // Deploy the proxy contract with the implementation and admin addresses
        address admin = vm.envAddress("PROXY_ADMIN");
        MarketplaceProxy proxy = new MarketplaceProxy(
            address(marketplace), // Implementation address
            admin, // Proxy admin address
            initializeCalldata // Initialization calldata
        );

        // Log the contract addresses
        console.log(
            "Marketplace implementation deployed at:",
            address(marketplace)
        );
        console.log("Marketplace proxy deployed at:", address(proxy));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
