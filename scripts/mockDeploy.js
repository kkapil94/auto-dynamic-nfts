const hre = require("hardhat");
const main = async()=>{
  const MockPrice = await hre.ethers.deployContract("MockV3Aggregator",[8,"3034715771688"]);
  const mockPrice = await MockPrice.waitForDeployment();
  console.log("mockprice deployed on :",mockPrice.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });