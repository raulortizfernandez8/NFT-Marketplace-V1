# 🖼️ NFT Marketplace

A simple NFT Marketplace built in Solidity, where users can:

List their ERC721 NFTs for sale

Cancel listings if they are the owner

Buy NFTs from other users securely

Includes a full test suite written with Foundry.

# 📌 Features

List NFTs: Only the owner can list an NFT, and the price must be greater than zero.

Cancel listing: Only the seller can cancel their own listing.

Buy NFTs: Anyone can buy a listed NFT by paying the exact price.

Security:

Uses ReentrancyGuard to prevent reentrancy attacks.

Implements the Checks-Effects-Interactions (CEI) pattern.

# 🛠️ Tech Stack

Solidity 0.8.24

OpenZeppelin Contracts (ERC721, ReentrancyGuard)

Foundry for testing (forge-std)

# ⚙️ Smart Contract: NFTMarketplace

# Functions

**1. listNFT(address nft, uint256 tokenId, uint256 price) - List an NFT for sale.**
   
   *Requirements*:
   
    Caller must be the owner. Price > 0.

**2. buyNFT(address nft, uint256 tokenId) - Buy a listed NFT.**
   
   *Requirements*: 
   
    Listing must exist. 
    
    Buyer must pay the exact price.

    Seller must still be the owner of the NFT.

    Funds are transferred to the seller.

**3. cancelList(address nft, uint256 tokenId) - Cancel an active listing.**

   *Requirements*:

    Caller must be the seller.

# 🧪 Testing

The test suite is written with Foundry.

Run tests
forge test

Coverage

The tests cover:

✅ Minting mock NFTs

✅ Reverts if price is 0

✅ Reverts if non-owner tries to list or cancel

✅ Successful listing

✅ Cancel listing by owner

✅ Buying NFTs with exact payment

✅ Reverts if NFT is not listed or wrong price is sent

<img width="698" height="157" alt="image" src="https://github.com/user-attachments/assets/236c4e9c-b69d-4173-93b7-50d08517a5de" />

