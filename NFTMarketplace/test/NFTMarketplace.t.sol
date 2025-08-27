//SPDX-License-Identifier:MIT

pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../src/NFTMarketplace.sol";

contract MockNFT is ERC721{
    constructor() ERC721("Mock NFT","MNFT"){}

    function mint_(address to_, uint256 tokenId_) external{
        _mint(to_, tokenId_);
    }
}
contract NFTMarketplaceTest is Test {
     NFTMarketplace marketplace;
     MockNFT nft;
     address deployer = vm.addr(1);
     address user = vm.addr(2);
     address user2 = vm.addr(3);
     uint256 tokenId = 0;
     struct Listing{
        address seller;
        address addressNFT;
        uint256 tokenId;
        uint256 price;
    }
    function setUp() public{
        vm.startPrank(deployer);

        marketplace = new NFTMarketplace();
        nft = new MockNFT(); // Here I deploy the nft as

        vm.stopPrank();

        vm.startPrank(user);
        nft.mint_(user,tokenId);
        vm.stopPrank();
    }
    function testMintNFT() public view{
        address owner = nft.ownerOf(tokenId);
        assert(owner==user);
    }
    function testShouldRevertPriceLessThanZero() public{
        uint256 price_ = 0;
        vm.startPrank(user);
        vm.expectRevert("Price cannot be zero");
        marketplace.listNFT(address(nft), tokenId, price_);
        vm.stopPrank();
    }
    function testShouldRevertNotOwnerList() public{
        uint256 price_=2;
        uint256 tokenId_ = 1;
        nft.mint_(user2,tokenId_);

        vm.startPrank(user);

        vm.expectRevert("You are not the owner");
        marketplace.listNFT(address(nft), tokenId_, price_);

        vm.stopPrank();
    }
    function testListNFT() public{
        uint256 price_ = 2;
        vm.startPrank(user);
        (address sellerBefore,,,) = marketplace.listing(address(nft),tokenId);
        marketplace.listNFT(address(nft), tokenId, price_);
        (address sellerAfter,,,) = marketplace.listing(address(nft),tokenId);
        assert(sellerBefore==address(0) && sellerAfter==user);

        vm.stopPrank();
    }
    function testCancelListShouldRevertIfNotOwner() public{
        uint256 price_ = 2;
        vm.startPrank(user);
        (address sellerBefore,,,) = marketplace.listing(address(nft),tokenId);
        marketplace.listNFT(address(nft), tokenId, price_);
        (address sellerAfter,,,) = marketplace.listing(address(nft),tokenId);
        assert(sellerBefore==address(0) && sellerAfter==user);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("You are not the owner");
        marketplace.cancelList(address(nft), tokenId);
        vm.stopPrank(); 
    }
    function testCancelList() public{
        uint256 price_ = 2;
        vm.startPrank(user);
        (address sellerBefore,,,) = marketplace.listing(address(nft),tokenId);
        marketplace.listNFT(address(nft), tokenId, price_);
        (address sellerAfter,,,) = marketplace.listing(address(nft),tokenId);
        assert(sellerBefore==address(0) && sellerAfter==user);
        vm.stopPrank();

        vm.startPrank(user);
        marketplace.cancelList(address(nft), tokenId);
        (sellerAfter,,,) = marketplace.listing(address(nft),tokenId);
        assert(sellerAfter == address(0));
        vm.stopPrank(); 
    }
    function testCanNotBuyUnlistedNFT() public{
        uint256 tokenId_ = 3;
        vm.startPrank(user);
        
        vm.expectRevert("NFT does not exist");
        marketplace.buyNFT(address(nft),tokenId_);

        vm.stopPrank();
    }
    function testShouldRevertNotCorrectPrice() public{
        uint256 price_ = 2;

        vm.startPrank(user);
        (address sellerBefore,,,) = marketplace.listing(address(nft),tokenId);
        marketplace.listNFT(address(nft), tokenId, price_);
        (address sellerAfter,,,) = marketplace.listing(address(nft),tokenId);
        assert(sellerBefore==address(0) && sellerAfter==user);

        vm.stopPrank();
        
        vm.startPrank(user2);
        vm.deal(user2,5);

        vm.expectRevert("The amount you are sending is not the price");
        marketplace.buyNFT{value:price_-1}(address(nft),tokenId);

        vm.stopPrank();
    }
    
    function testBuyNFT() public{
        uint256 price_ = 2;

        vm.startPrank(user);
        (address sellerBefore,,,) = marketplace.listing(address(nft),tokenId);
        marketplace.listNFT(address(nft), tokenId, price_);
        (address sellerAfter,,,) = marketplace.listing(address(nft),tokenId);
        assert(sellerBefore==address(0) && sellerAfter==user);
        nft.approve(address(marketplace), tokenId);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.deal(user2,5);

        uint256 balanceBefore = user.balance;
        address ownerBefore = nft.ownerOf(tokenId);
        (address sellerBefore2,,,) = marketplace.listing(address(nft),tokenId);

        marketplace.buyNFT{value:price_}(address(nft),tokenId);

        (address sellerAfter2,,,) = marketplace.listing(address(nft),tokenId);
        address ownerAfter = nft.ownerOf(tokenId);
        uint256 balanceAfter = user.balance;
        assert(sellerBefore2 == user && sellerAfter2 == address(0));
        assert(ownerBefore==user&&ownerAfter==user2);
        assert(balanceBefore+price_==balanceAfter);

        vm.stopPrank();
    }

}