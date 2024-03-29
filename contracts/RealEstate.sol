// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RealEstate is ERC721, Ownable {
    struct Property {
        uint256 price;
        bool forSale;
        uint256 rentPrice;
        uint256 rentDuration;
    }

    mapping(uint256 => Property) public properties;

    event PropertyListed(uint256 indexed tokenId, uint256 price, bool forSale, uint256 rentPrice, uint256 rentDuration);
    event PropertySold(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event PropertyRented(uint256 indexed tokenId, address indexed renter, uint256 rentPrice, uint256 rentDuration);

    IERC20 public tokenContract;

    constructor(address _tokenContractAddress) ERC721("RealEstate", "RE") {
        tokenContract = IERC20(_tokenContractAddress);
    }

    function listPropertyForSale(uint256 _tokenId, uint256 _price) external onlyOwner {
        properties[_tokenId] = Property({
            price: _price,
            forSale: true,
            rentPrice: 0,
            rentDuration: 0
        });
        emit PropertyListed(_tokenId, _price, true, 0, 0);
    }

    function buyProperty(uint256 _tokenId) external {
        require(properties[_tokenId].forSale, "Property is not listed for sale");
        uint256 price = properties[_tokenId].price;
        address owner = ownerOf(_tokenId);
        tokenContract.transferFrom(msg.sender, owner, price);
        _transfer(owner, msg.sender, _tokenId);
        emit PropertySold(_tokenId, msg.sender, price);
    }

    function listPropertyForRent(uint256 _tokenId, uint256 _rentPrice, uint256 _rentDuration) external onlyOwner {
        properties[_tokenId] = Property({
            price: 0,
            forSale: false,
            rentPrice: _rentPrice,
            rentDuration: _rentDuration
        });
        emit PropertyListed(_tokenId, 0, false, _rentPrice, _rentDuration);
    }

    function rentProperty(uint256 _tokenId) external {
        require(!properties[_tokenId].forSale, "Property is listed for sale, not for rent");
        uint256 rentPrice = properties[_tokenId].rentPrice;
        address owner = ownerOf(_tokenId);
        tokenContract.transferFrom(msg.sender, owner, rentPrice);
        _transfer(owner, msg.sender, _tokenId);
        emit PropertyRented(_tokenId, msg.sender, rentPrice, properties[_tokenId].rentDuration);
    }
}
