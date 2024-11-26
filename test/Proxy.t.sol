// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import "forge-std/Test.sol";
import "../src/Marketplace.sol";
import "../src/Proxy.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract MarketplaceV2 is Marketplace {
    // New function in upgraded version
    function version() external pure returns (string memory) {
        return "v2";
    }
}

contract MarketplaceTest is Test {
    Marketplace marketplace;
    MarketplaceV2 marketplaceV2;
    Marketplace proxyAsMarketplace;

    address proxyAdmin = 0xffD4505B3452Dc22f8473616d50503bA9E1710Ac;
    address seller = address(0x5678);
    address buyer = address(0x9ABC);

    MarketplaceProxy proxy;

    function setUp() public {
        // Deploy the initial implementation
        marketplace = new Marketplace();

        // Deploy the proxy pointing to the initial implementation
        proxy = new MarketplaceProxy(address(marketplace), proxyAdmin, "");

        // Cast the proxy address to the Marketplace interface for testing
        proxyAsMarketplace = Marketplace(address(proxy));

        // Label addresses for clarity in traces
        vm.label(address(proxy), "MarketplaceProxy");
        vm.label(proxyAdmin, "ProxyAdmin");
        vm.label(seller, "Seller");
        vm.label(buyer, "Buyer");
    }

    function testUpgradeMarketplace() public {
        // Deploy new implementation
        marketplaceV2 = new MarketplaceV2();

        // Verify initial implementation doesn't have the version() function
        vm.expectRevert();
        MarketplaceV2(address(proxy)).version();

        // Upgrade to the new implementation
        vm.prank(proxyAdmin);
        ITransparentUpgradeableProxy(address(proxy)).upgradeToAndCall(
            address(marketplaceV2),
            abi.encodeWithSelector(marketplaceV2.initialize.selector)
        );

        // Verify the new implementation is now in use
        assertEq(MarketplaceV2(address(proxy)).version(), "v2");
    }
}
