//SPDX-License-Identifier:MIT

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
contract NFTMarketplace is ReentrancyGuard{

    struct Listing{
        address seller;
        address addressNFT;
        uint256 tokenId;
        uint256 price;
    }
    mapping(address=>mapping(uint256=>Listing)) public listing; // I need to do a nested mapping here as tere is no uniqueKey just by NFTadress where to store the struct.

    // Events
    event ListNFT(address indexed addressNFT, address indexed seller, uint256 tokenID, uint256 price);
    event BuyNFT(address indexed addressNFT, address indexed buyer, address indexed seller, uint256 tokenID, uint256 price);
    event CancelList(address indexed addressNFT_, address indexed seller, uint256 tokenID);
    
    constructor(){}

    // Functions
    //1. List NFT
    function listNFT(address addressNFT_, uint256 tokenID_, uint256 price_) external{
        require(price_!=0,"Price cannot be zero");
        address owner_ = IERC721(addressNFT_).ownerOf(tokenID_);
        require(owner_ == msg.sender,"You are not the owner");
        Listing memory listing_= Listing ({
            seller : msg.sender,
            addressNFT : addressNFT_,
            tokenId : tokenID_,
            price : price_
        });
        listing[addressNFT_][tokenID_] = listing_;
        emit ListNFT(addressNFT_, msg.sender, tokenID_, price_);
    }
    //2. Buy NFT
    function buyNFT(address addressNFT_, uint256 tokenID_) external payable nonReentrant{ 
        Listing memory listing_ = listing[addressNFT_][tokenID_];
        require(listing_.addressNFT!=address(0),"NFT does not exist");
        require(listing_.price==msg.value,"The amount you are sending is not the price");

        delete listing[addressNFT_][tokenID_]; // We implement here CEI pattern as well. In BlockChain security is the most important thing.

        IERC721(addressNFT_).safeTransferFrom(listing_.seller,msg.sender,tokenID_);
        (bool success,)= listing_.seller.call{value: msg.value}("");
        require(success,"Transfer to seller failed");
        emit BuyNFT(addressNFT_, msg.sender, listing_.seller, tokenID_, listing_.price);
    }
    //3. Cancel List
    function cancelList(address addressNFT_, uint256 tokenID_) external {
        Listing memory listing_ = listing[addressNFT_][tokenID_];
        require(listing_.seller==msg.sender,"You are not the owner");
        delete listing[addressNFT_][tokenID_];
        emit CancelList(addressNFT_, listing_.seller, tokenID_);
    }

}