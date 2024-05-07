// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Write a simple NFT market contract, using your own issued Token to buy and sell NFTs. The functions include:

// list(): Implement the listing function, where the NFT holder can set a price
// (how many tokens are needed to purchase the NFT) and list the NFT on the NFT market.
// buyNFT(): Implement the purchase function for NFTs,
// where users transfer the specified token quantity and receive the corresponding NFT.
contract NFTmarket {
    struct listOfNFTs {
        uint256 price;
        address seller;
    }
    BaseERC20 tokenContract;
    BaseERC721 nftContract;

    // tokenId => ListOfNFTS
    mapping(address => mapping(uint256 => listOfNFTs)) public listings;

    event Listed(address indexed nftca, uint256 indexed tokenId, address seller, uint256 price);
    event Bought(
        uint256 indexed tokenId,
        address buyer,
        address seller,
        uint256 price
    );
    
    constructor() {}

     function list(address nftAddress, uint256 tokenId, uint256 price) public {
        nftContract = BaseERC721(nftAddress);
        require(
            nftContract.ownerOf(tokenId) == msg.sender,
            "You are not the owner"
        );
        require(price > 0, "price must be greater than 0");
        listings[nftAddress][tokenId].seller = msg.sender;
        listings[nftAddress][tokenId].price = price;
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
        emit Listed(nftAddress,tokenId, msg.sender, price);
    }

    function buy(
        uint256 tokenId,
        address _tokenAdress,
        address _nftAdress
    ) public {
        tokenContract = BaseERC20(_tokenAdress);
        nftContract = BaseERC721(_nftAdress);
        listOfNFTs memory listing = listings[_nftAdress][tokenId];
        require(listing.price > 0, "this is not for sale");
        require(
            nftContract.ownerOf(tokenId) == address(this),
            "already selled"
        );
        tokenContract.transferFrom(msg.sender, listing.seller, listing.price);
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        delete listings[_nftAdress][tokenId];
        emit Bought(tokenId, msg.sender, listing.seller, listing.price);
    }
}