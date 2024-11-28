// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Marketplace is Initializable {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;
    uint256 private nextListingId;

    event NFTListed(
        uint256 listingId,
        address indexed seller,
        address nftContract,
        uint256 tokenId,
        uint256 price
    );

    event NFTListUpdated(
        uint256 listingId,
        address indexed seller,
        address nftContract,
        uint256 tokenId,
        uint256 price
    );
    event NFTPurchased(uint256 listingId, address indexed buyer);

    error PriceMustBeGreaterThanZero();
    error IncorrectPrice();
    error NotTheSeller();

    error InvalidAddress();

    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        if (price == 0) {
            revert PriceMustBeGreaterThanZero();
        }

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        listings[nextListingId] = Listing(
            msg.sender,
            nftContract,
            tokenId,
            price
        );
        emit NFTListed(nextListingId, msg.sender, nftContract, tokenId, price);
        nextListingId++;
    }

    function buyNFT(uint256 listingId) external payable {
        Listing storage listing = listings[listingId];
        if (msg.value != listing.price) {
            revert IncorrectPrice();
        }

        IERC721(listing.nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );
        (bool sent, ) = payable(listing.seller).call{value: listing.price}("");

        require(sent, "Failed to send Ether");

        emit NFTPurchased(listingId, msg.sender);
        delete listings[listingId];
    }

    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        if (listing.seller != msg.sender) {
            revert NotTheSeller();
        }

        IERC721(listing.nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );

        delete listings[listingId];
    }

    function updateListing(
        uint256 listingId,
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        Listing storage listing = listings[listingId];

        if (price < 0) {
            revert PriceMustBeGreaterThanZero();
        }

        if (listing.seller != msg.sender) {
            revert NotTheSeller();
        }

        if (nftContract == address(0)) {
            revert InvalidAddress();
        }

        listing.nftContract = nftContract;
        listing.tokenId = tokenId;
        listing.price = price;

        emit NFTListUpdated(
            nextListingId,
            msg.sender,
            nftContract,
            tokenId,
            price
        );
    }

    function initialize() external initializer {}
}
