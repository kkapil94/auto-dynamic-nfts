const hre = require("hardhat");
const main = async()=>{
  const BullBear = await hre.ethers.deployContract("BullBear");
  const bullBear = await BullBear.deployed();
  console.log("BullnBear deployed on :",bullBear.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });