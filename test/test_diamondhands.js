const { expect } = require("chai");

DAIAddress = require("../artifacts/published/DAI.address.js");
DAIAbi = require("../artifacts/published/DAI.abi.js");

MCKAddress = require("../artifacts/published/MCK.address.js");
MCKAbi = require("../artifacts/published/MCK.abi.js");

dhAddress = require("../artifacts/published/Diamondhands.address.js");
dhAbi = require("../artifacts/published/Diamondhands.abi.js");

describe("test Diamondhands", function () {
  let DAI;
  let accounts;
  let dh;
  let MCK;
  before(async () => {
    DAI = new ethers.Contract(DAIAddress, DAIAbi, ethers.provider.getSigner(0));
    MCK = new ethers.Contract(MCKAddress, MCKAbi, ethers.provider.getSigner(0));
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
  it("test withdrawLost", async function () {
    await MCK.transfer(dh.address, 1000);
    bal1 = await MCK.balanceOf(accounts[0]);
    await dh.withdrawLost(MCK.address);
    bal = await MCK.balanceOf(accounts[0]);
    expect(bal.sub(bal1)).to.equal(1000);
  });
});
