const { expect } = require("chai");

DAIAddress = require("../artifacts/published/DAI.address.js");
DAIAbi = require("../artifacts/published/DAI.abi.js");

dhAddress = require("../artifacts/published/Diamondhands.address.js");
dhAbi = require("../artifacts/published/Diamondhands.abi.js");

describe("test Diamondhands", function () {
  let DAI;
  let accounts;
  let dh;
  before(async () => {
    DAI = new ethers.Contract(
      DAIAddress,
      DAIAbi,
      ethers.provider.getSigner(0)
    );
    accounts = await ethers.provider.listAccounts();
    dh = new ethers.Contract(dhAddress, dhAbi, ethers.provider.getSigner(0));
  });
  it("test mock DAI", async function () {
    bal1 = await DAI.balanceOf(accounts[1]);
    await DAI.transfer(accounts[1], 1000);
    bal = await DAI.balanceOf(accounts[1]);
    expect(bal.sub(bal1)).to.equal(1000);
  });
  it("deposit to Diamondhands", async function () {
    bal1 = await DAI.balanceOf(dh.address);
    await DAI.approve(dh.address, 1000);
    await dh.deposit(1000);
    bal = await DAI.balanceOf(dh.address);
    expect(bal.sub(bal1)).to.equal(1000);
  });
});
