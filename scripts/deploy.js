const hre = require("hardhat");
const main = async()=>{
  const BullBear = await hre.ethers.deployContract("BullBear",[10,"0xFdF93be100462Ba0b3537B0b4865ef4b64DC0A51"]);
  const bullBear = await BullBear.waitForDeployment();
  console.log("BullnBear deployed on :",bullBear.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });