// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import "forge-std/Test.sol";
import "../src/NFT.sol";

contract NFTTest is Test {
    NFT private nft;

    bytes32 private constant MERKLE_ROOT =
        0x6519e1d668a89155abbac8ea19ab984de78ca03bae00d291281143c183c7f8a3;

    address ALICE = 0xd6dA2E5D49B02d7e41def7A9c9FE451E3984E4A8;
    address BOB = 0x54864E485A2b1d7CD6548e1bFFaAE483d826Ed33;
    address CHARLIE = 0x8B36C15167A3C2512BA07d194b32A0D74FB9609D;
    address DAN = 0xFCAd0B19bB29D4674531d6f115237E16AfCE377c;

    bytes32[] private proofAlice = [
        bytes32(
            0x24265cfd8ac7334b9d5c79face6cddbd5567b85be29a5fd8d8a1a0a8e4339bac
        ),
        bytes32(
            0x8b6852f4ff0b789f4c93b788df074b71f17b909a2e2baefaf8850db266f45ce3
        )
    ];

    bytes32[] private proofBob = [
        bytes32(
            0xb063a321d08b8b8eae1700a19e3046e726d51e9305ef6d2d3af259a7b6390014
        ),
        bytes32(
            0x993649de367a95186efe229f781bcecb288f022b7e258df0a81cb498a7d3a1d0
        )
    ];

    bytes32[] private proofCharlie = [
        bytes32(
            0x34925dd122eeff44e540443745e5c2f8e9b068e020cf176322b2c8e80873ac7a
        ),
        bytes32(
            0x993649de367a95186efe229f781bcecb288f022b7e258df0a81cb498a7d3a1d0
        )
    ];

    bytes32[] private invalidProof = [
        bytes32(
            0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
        )
    ];

    function setUp() public {
        nft = new NFT("Test NFT", "TNFT", "https://example.com/");
        nft.setMerkleRoot(MERKLE_ROOT);
    }

    function testClaimNFTSuccessful() public {
        vm.prank(ALICE);
        nft.claimNFT(proofAlice);

        // Assert the token was minted to ALICE
        assertEq(nft.balanceOf(ALICE), 1);
        assertEq(nft.ownerOf(1), ALICE);

        // Assert ALICE has claimed
        assertTrue(nft.claimed(ALICE));
    }

    function testCannotClaimTwice() public {
        vm.prank(ALICE);
        nft.claimNFT(proofAlice);

        // Attempt to claim again
        vm.expectRevert(NFT.AlreadyClaimed.selector);
        vm.prank(ALICE);
        nft.claimNFT(proofAlice);
    }

    function testInvalidProofFails() public {
        vm.prank(ALICE);

        // Attempt to claim with an invalid proof
        vm.expectRevert(NFT.InvalidMerkleProof.selector);
        nft.claimNFT(invalidProof);
    }

    function testCannotClaimWithoutProof() public {
        vm.prank(BOB);

        // Attempt to claim with an empty proof
        vm.expectRevert(NFT.InvalidMerkleProof.selector);
        nft.claimNFT(new bytes32[](0));
    }

    function testClaimMultipleAddresses() public {
        // ALICE claims
        vm.prank(ALICE);
        nft.claimNFT(proofAlice);
        assertEq(nft.ownerOf(1), ALICE);

        // BOB claims
        vm.prank(BOB);
        nft.claimNFT(proofBob);
        assertEq(nft.ownerOf(2), BOB);

        // CHARLIE claims
        vm.prank(CHARLIE);
        nft.claimNFT(proofCharlie);
        assertEq(nft.ownerOf(3), CHARLIE);
    }

    function testNonOwnerCannotSetBaseURI() public {
        vm.prank(ALICE);
        vm.expectRevert();
        nft.setBaseURI("https://maliciousbaseuri.com/");
    }
}
