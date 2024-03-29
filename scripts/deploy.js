// scripts/deploy.js
async function main() {
    // We get the contract to deploy
    const RealDigital = await ethers.getContractFactory("RealDigital");
    const realDigital = await RealDigital.deploy();
  
    const RealEstate = await ethers.getContractFactory("RealEstate");
    const realEstate = await RealEstate.deploy(realDigital.address);
  
    const RealEstateMarketplace = await ethers.getContractFactory("RealEstateMarketplace");
    const realEstateMarketplace = await RealEstateMarketplace.deploy(realEstate.address);
  
    console.log("RealDigital deployed to:", realDigital.address);
    console.log("RealEstate deployed to:", realEstate.address);
    console.log("RealEstateMarketplace deployed to:", realEstateMarketplace.address);
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  