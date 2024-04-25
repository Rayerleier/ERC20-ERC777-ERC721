// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


interface ITokenReceiver {
    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        uint256 tokenId
    ) external;
    function queryPrice(uint256 tokenId) external view returns (uint256);
}


//Write a simple NFT market contract, using your own issued Token to buy and sell NFTs. The functions include:

// list(): Implement the listing function, where the NFT holder can set a price 
// (how many tokens are needed to purchase the NFT) and list the NFT on the NFT market.
// buyNFT(): Implement the purchase function for NFTs,
// where users transfer the specified token quantity and receive the corresponding NFT.
contract NFTmartket is ERC721, ITokenReceiver{

    struct listOfNFTs{
        uint256 price;
        address seller;
    }
    IERC20 tokenContract;
    IERC721 nftContract;

    // tokenId => ListOfNFTS
    mapping (uint256 => listOfNFTs) listings;

    event Listed(uint256 indexed tokenId, address seller, uint256 price);
    event Bought(uint256 indexed tokenId, address buyer, address seller, uint256 price);

    address owner;
    constructor(address _tokenAdress, address _nftAdress)ERC721("rayer","rain"){
        owner = msg.sender;
        tokenContract = IERC20(_tokenAdress);
        nftContract = IERC721(_nftAdress);
    }
    
    function queryPrice(uint256 tokenId)public view returns (uint256){
        return listings[tokenId].price;
    }

    function list(uint256 tokenId, uint256 price)public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You must own NFT");
        require(price>0, "price must be greater than 0");   
        listings[tokenId] = listOfNFTs(price, msg.sender);
        emit Listed(tokenId, msg.sender, price);
    }



    function tokensReceived(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _tokenId)
        external  override {
        tokenContract.transferFrom(_from, _to, _amount);
        nftContract.transferFrom(_to, _from, _tokenId);
    }

    function buy(uint256 tokenId)public {
        listOfNFTs memory listing = listings[tokenId];
        require(listing.price>0, "this is not for sale");
        require(nftContract.ownerOf(tokenId) == address(this), "aleady selled");
        tokenContract.transferFrom(msg.sender, listing.seller, listing.price);
        nftContract.transferFrom(listing.seller, msg.sender, tokenId);
        delete listings[tokenId];
        emit Bought(tokenId, msg.sender, listing.seller, listing.price);
    }

}