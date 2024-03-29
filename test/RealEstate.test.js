const { ethers } = require("hardhat");

const { expect } = require("chai");

describe("RealEstate", function() {
  let RealEstate;
  let realEstate;
  let owner;
  let recipient;

  beforeEach(async function () {
    [owner, recipient] = await ethers.getSigners();

    // Deploy RealEstate contract
    RealEstate = await ethers.getContractFactory("RealEstate");
    realEstate = await RealEstate.deploy(owner.address);

    // Mint a new property
    await realEstate.listPropertyForSale(1, ethers.utils.parseEther("100"));
  });

  it("should mint a new property", async function() {
    const tokenId = 1; // Assuming the first token has ID 1
    expect(await realEstate.ownerOf(tokenId)).to.equal(owner.address);
  });

  it("should set price for a property", async function() {
    const tokenId = 1; // Assuming the first token has ID 1
    const price = ethers.utils.parseEther("200");
    await realEstate.connect(owner).listPropertyForSale(tokenId, price);
    const property = await realEstate.properties(tokenId);
    expect(property.price).to.equal(price);
  });

  it("should set property for sale", async function() {
    const tokenId = 1; // Assuming the first token has ID 1
    await realEstate.connect(owner).listPropertyForSale(tokenId, ethers.utils.parseEther("200"));
    const property = await realEstate.properties(tokenId);
    expect(property.forSale).to.be.true;
  });

  it("should set property for rent", async function() {
    const tokenId = 1; // Assuming the first token has ID 1
    const rentPrice = ethers.utils.parseEther("10");
    const rentDuration = 30; // Assuming rent duration is 30 days
    await realEstate.connect(owner).listPropertyForRent(tokenId, rentPrice, rentDuration);
    const property = await realEstate.properties(tokenId);
    expect(property.rentPrice).to.equal(rentPrice);
    expect(property.rentDuration).to.equal(rentDuration);
  });

  it("should allow buying a property with Ether", async function() {
    const tokenId = 1; // Assuming the first token has ID 1
    const price = ethers.utils.parseEther("100");
    await realEstate.connect(owner).listPropertyForSale(tokenId, price);
    await realEstate.connect(recipient).buyProperty(tokenId, { value: price });
    expect(await realEstate.ownerOf(tokenId)).to.equal(recipient.address);
  });

  // Add more tests as needed
});
