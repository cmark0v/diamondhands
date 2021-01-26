const { expect } = require("chai");

tokenAddress = require("../artifacts/published/MockToken.address.js");
tokenAbi = require("../artifacts/published/MockToken.abi.js");

describe("test Diamondhands", function () {
  let token;
  let accounts;
  before(async () => {
    token = new ethers.Contract(
      tokenAddress,
      tokenAbi,
      ethers.provider.getSigner(0)
    );
    accounts = await ethers.provider.listAccounts();
  });
  it("test mock token", async function () {
    bal1 = await token.balanceOf(accounts[1]);
    await token.transfer(accounts[1], 1000);
    bal = await token.balanceOf(accounts[1]);
    expect(bal-bal1).to.equal(1000);
  });
});
