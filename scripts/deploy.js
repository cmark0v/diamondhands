const fs = require("fs");
const hre = require("hardhat");

async function main() {
  const Token = await hre.ethers.getContractFactory("MockToken");
  const token = await Token.deploy("DAI token", "DAI");
  await token.deployed();

  console.log("token mock deployed to:", token.address);
  publish(token, "MockToken", 'mocks');

  const Diamondhands = await hre.ethers.getContractFactory("Diamondhands");
  const diamondhands = await Diamondhands.deploy(token.address, 3600);
  await diamondhands.deployed();

  console.log("Diamondhands deployed to:", diamondhands.address);
  publish(diamondhands, "Diamondhands",'');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

function publish(contractOb, contractName,path) {
  const address = JSON.stringify(contractOb.address, null, 2);

  const contractArtifactFile = `../artifacts/contracts/${path}/${contractName}.sol/${contractName}.json`;
  const contractArtifacts = require(contractArtifactFile);
  const abi = JSON.stringify(contractArtifacts.abi, null, 2);

  const folder = "artifacts/published/";
  if (!fs.existsSync(folder)) {
    fs.mkdir(folder, console.log);
  }
  const abiFileName = `${folder}${contractName}.abi.js`;
  //fs.writeFile(abiFileName, "", console.log);
  fs.writeFileSync(abiFileName, `module.exports = ${abi};`, console.log);
  const addressFileName = `${folder}${contractName}.address.js`;
  fs.writeFileSync(
    addressFileName,
    `module.exports = ${address};`,
    console.log
  );
}
