// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract RealEstateMarketplace {
    struct Listing {
        address owner;
        uint256 tokenId;
        uint256 price;
        bool forSale;
        uint256 rentPrice;
        uint256 rentDuration;
    }

    mapping(uint256 => Listing) public listings;

    event PropertyListed(uint256 indexed tokenId, address indexed owner, uint256 price, bool forSale, uint256 rentPrice, uint256 rentDuration);
    event PropertySold(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event PropertyRented(uint256 indexed tokenId, address indexed renter, uint256 rentPrice, uint256 rentDuration);

    IERC20 public tokenContract;

    constructor(address _tokenContractAddress) {
        tokenContract = IERC20(_tokenContractAddress);
    }

    function listPropertyForSale(address _realEstateContract, uint256 _tokenId, uint256 _price) external {
        require(IERC721(_realEstateContract).ownerOf(_tokenId) == msg.sender, "You are not the owner of this property");
        require(!listings[_tokenId].forSale, "Property is already listed for sale");
        listings[_tokenId] = Listing({
            owner: msg.sender,
            tokenId: _tokenId,
            price: _price,
            forSale: true,
            rentPrice: 0,
            rentDuration: 0
        });
        emit PropertyListed(_tokenId, msg.sender, _price, true, 0, 0);
    }

    function buyProperty(address _realEstateContract, uint256 _tokenId) external {
        require(listings[_tokenId].forSale, "Property is not listed for sale");
        uint256 price = listings[_tokenId].price;
        address owner = listings[_tokenId].owner;
        tokenContract.transferFrom(msg.sender, owner, price);
        IERC721(_realEstateContract).transferFrom(owner, msg.sender, _tokenId);
        delete listings[_tokenId];
        emit PropertySold(_tokenId, msg.sender, price);
    }

    function listPropertyForRent(address _realEstateContract, uint256 _tokenId, uint256 _rentPrice, uint256 _rentDuration) external {
        require(IERC721(_realEstateContract).ownerOf(_tokenId) == msg.sender, "You are not the owner of this property");
        require(!listings[_tokenId].forSale, "Property is already listed for sale");
        listings[_tokenId] = Listing({
            owner: msg.sender,
            tokenId: _tokenId,
            price: 0,
            forSale: false,
            rentPrice: _rentPrice,
            rentDuration: _rentDuration
        });
        emit PropertyListed(_tokenId, msg.sender, 0, false, _rentPrice, _rentDuration);
    }

    function rentProperty(address _realEstateContract, uint256 _tokenId) external {
        require(!listings[_tokenId].forSale, "Property is listed for sale, not for rent");
        uint256 rentPrice = listings[_tokenId].rentPrice;
        address owner = listings[_tokenId].owner;
        tokenContract.transferFrom(msg.sender, owner, rentPrice);
        IERC721(_realEstateContract).transferFrom(owner, msg.sender, _tokenId);
        delete listings[_tokenId];
        emit PropertyRented(_tokenId, msg.sender, rentPrice, listings[_tokenId].rentDuration);
    }
}