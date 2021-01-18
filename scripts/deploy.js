const hre = require("hardhat");

async function main() {

  const Token = await hre.ethers.getContractFactory("MockToken");
  const token = await Token.deploy("DAI token","DAI");
  await token.deployed();
  console.log("token mock deployed to:", token.address);

  const Diamondhands = await hre.ethers.getContractFactory("Diamondhands");
  const diamondhands = await Diamondhands.deploy(token.address,3600);

  await diamondhands.deployed();
  console.log("Diamondhands deployed to:", diamondhands.address);


}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

