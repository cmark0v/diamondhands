const fs = require("fs");
const hre = require("hardhat");

async function main() {
  const Dai = await hre.ethers.getContractFactory("MockToken");
  const dai = await Dai.deploy("DAI token", "DAI");
  await dai.deployed();

  console.log("DAI token mock deployed to:", dai.address);
  publish(dai, "MockToken", "mocks", "DAI");

  const Weth = await hre.ethers.getContractFactory("MockToken");
  const weth = await Weth.deploy("WETH token", "WETH");
  await weth.deployed();

  console.log("WETH token mock deployed to:", weth.address);
  publish(weth, "MockToken", "mocks", "WETH");

  const Diamondhands = await hre.ethers.getContractFactory("Diamondhands");
  const diamondhands = await Diamondhands.deploy(dai.address, 3600);
  await diamondhands.deployed();

  console.log("Diamondhands deployed to:", diamondhands.address);
  publish(diamondhands, "Diamondhands");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

function publish(contractOb, contractName, path, publishName) {
  const address = JSON.stringify(contractOb.address, null, 2);
  if (publishName == undefined || publishName == "") {
    publishName = contractName;
  }
  if (path == undefined) {
    path = "";
  }
  const contractArtifactFile = `../artifacts/contracts/${path}/${contractName}.sol/${contractName}.json`;
  const contractArtifacts = require(contractArtifactFile);
  const abi = JSON.stringify(contractArtifacts.abi, null, 2);

  const folder = "artifacts/published/";
  if (!fs.existsSync(folder)) {
    fs.mkdir(folder, console.log);
  }
  const abiFileName = `${folder}${publishName}.abi.js`;
  //fs.writeFile(abiFileName, "", console.log);
  fs.writeFileSync(abiFileName, `module.exports = ${abi};`, console.log);
  const addressFileName = `${folder}${publishName}.address.js`;
  fs.writeFileSync(
    addressFileName,
    `module.exports = ${address};`,
    console.log
  );
}
