// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/Marketplace.sol";
import {NFT} from "../src/NFT.sol";

contract MarketplaceTest is Test {
    Marketplace marketplace;
    NFT nft;

    address seller = address(1);
    address buyer = address(2);

    function setUp() public {
        marketplace = new Marketplace();

        nft = new NFT("Test NFT", "TNFT", "https://example.com/");

        vm.deal(seller, 10 ether);
        vm.deal(buyer, 10 ether);
    }

    function testListNFT() public {
        nft.mint(seller, 1);

        vm.startPrank(seller);
        nft.approve(address(marketplace), 1);
        marketplace.listNFT(address(nft), 1, 1 ether);
        vm.stopPrank();

        (
            address _seller,
            address _nftContract,
            uint256 _tokenId,
            uint256 _price
        ) = marketplace.listings(0);
        assertEq(_seller, seller);
        assertEq(_nftContract, address(nft));
        assertEq(_tokenId, 1);
        assertEq(_price, 1 ether);
    }

    function testBuyNFT() public {
        testListNFT();

        vm.startPrank(buyer);
        marketplace.buyNFT{value: 1 ether}(0);
        vm.stopPrank();

        assertEq(nft.ownerOf(1), buyer);
    }

    function testCancelListing() public {
        testListNFT();

        vm.startPrank(seller);
        marketplace.cancelListing(0);
        vm.stopPrank();

        assertEq(nft.ownerOf(1), seller);
    }

    function testListNFTRevertZeroPrice() public {
        nft.mint(seller, 1);

        vm.startPrank(seller);
        nft.approve(address(marketplace), 1);
        vm.expectRevert(Marketplace.PriceMustBeGreaterThanZero.selector);
        marketplace.listNFT(address(nft), 1, 0);
        vm.stopPrank();
    }

    function testBuyNFTRevertIncorrectPrice() public {
        testListNFT();

        vm.startPrank(buyer);
        vm.expectRevert(Marketplace.IncorrectPrice.selector);
        marketplace.buyNFT{value: 0.5 ether}(0);
        vm.stopPrank();
    }

    function testCancelListingRevertNotTheSeller() public {
        testListNFT();

        vm.startPrank(buyer);
        vm.expectRevert(Marketplace.NotTheSeller.selector);
        marketplace.cancelListing(0);
        vm.stopPrank();
    }
}
