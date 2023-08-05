require("@nomiclabs/hardhat-ethers")
require("@nomiclabs/hardhat-etherscan")
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */


module.exports = {
  solidity: "0.8.19",
  networks:{
    sepolia:{
      url: process.env.SEPOLIA_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
