pragma solidity ^0.6.7;

import "lib/ds-test/contracts/test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "../util/TestEnv.sol";

import "../Diamondhands.sol";

contract Owner {
    Diamondhands diamondhands;

    constructor(Diamondhands _diamondhands) public {
        diamondhands = _diamondhands;
    }

    function deposit(uint256 _amt) public {
        diamondhands.deposit(_amt);
    }

    function withdraw(uint256 _amt) public {
        diamondhands.withdraw(_amt);
    }

    function approve(
        address _token,
        address _who,
        uint256 _amt
    ) public {
        IERC20(_token).approve(_who, _amt);
    }

    function getWithdrawableBalance() public view returns (uint256) {
        return diamondhands.getWithdrawableBalance();
    }

    function withdrawLost(address _token) public {
        diamondhands.withdrawLost(_token);
    }

    function transfer(
        address _token,
        address _to,
        uint256 _amt
    ) public {
        IERC20(_token).transfer(_to, _amt);
    }

    function try_withdrawLost(address _token) public returns (bool yesno) {
        string memory funsig = "withdrawLost(address)";
        (yesno, ) = address(diamondhands).call(abi.encodeWithSignature(funsig, _token));
    }
}

contract DiamondhandsTest is TestEnv {
    Diamondhands diamondhands;
    Owner owner;
    Owner apu;

    function setUp() public {
        diamondhands = new Diamondhands(address(DAI), 30 days);
        owner = new Owner(diamondhands);
        apu = new Owner(diamondhands);
        diamondhands.setOwner(address(owner));
        mint(DAI, address(owner), 5000 * WAD);
        mint(WETH, address(owner), 5000 * WAD);
        mint(WETH, address(apu), 5000 * WAD);
    }

    function test_viewbal() public {
        assertEq(diamondhands.getWithdrawableBalance(), 0);
    }

    function test_deposit() public {
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(100 * WAD);
        assertEq(IERC20(DAI).balanceOf(address(diamondhands)), 100 * WAD);
    }

    function test_withdraw_calc() public {
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(1000 * WAD);
        assertEq(owner.getWithdrawableBalance(), 0);
        uint256 start = block.timestamp;
        hevm.warp(start + 15 days);
        approxEq(owner.getWithdrawableBalance(), 500 * WAD, 6);
        hevm.warp(start + 30 days + 1);
        assertEq(owner.getWithdrawableBalance(), 1000 * WAD);
        hevm.warp(start + 5000 weeks);
        assertEq(owner.getWithdrawableBalance(), 1000 * WAD);
    }

    function test_double_withdraw() public {
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(1000 * WAD);
        uint256 bal = IERC20(DAI).balanceOf(address(owner));
        hevm.warp(block.timestamp + 15 days);
        owner.withdraw(owner.getWithdrawableBalance());
        approxEq(IERC20(DAI).balanceOf(address(owner)), bal + 500 * WAD, 6);
        assertEq(owner.getWithdrawableBalance(), 0);
    }

    function test_withdraw() public {
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(1000 * WAD);
        uint256 bal = IERC20(DAI).balanceOf(address(owner));
        hevm.warp(block.timestamp + 15 days);
        owner.withdraw(owner.getWithdrawableBalance());
        approxEq(IERC20(DAI).balanceOf(address(owner)), bal + 500 * WAD, 6);
        hevm.warp(block.timestamp + 30 days + 1);
        owner.withdraw(owner.getWithdrawableBalance());
        approxEq(IERC20(DAI).balanceOf(address(owner)), bal + 1000 * WAD, 6);
    }

    function test_sets() public {
        assertEq(uint256(DAI), uint256(diamondhands.holdToken()));
        assertEq(diamondhands.timeLock(), 30 days);
    }

    function test_gas_launch() public {
        new Diamondhands(DAI, 30 days);
    }

    function test_gas_deposit() public {
        owner.deposit(0);
    }

    function test_gas_withdraw() public {
        owner.deposit(0);
    }

    function test_withdrawLost() public {
        owner.transfer(WETH, address(diamondhands), 30 * WAD);
        owner.withdrawLost(WETH);
        assertEq(IERC20(WETH).balanceOf(address(owner)), 5000 * WAD);
        apu.transfer(WETH, address(diamondhands), 30 * WAD);
        owner.withdrawLost(WETH);
        assertEq(IERC20(WETH).balanceOf(address(owner)), 5030 * WAD);
    }

    function test_auth() public {
        apu.transfer(WETH, address(diamondhands), 30 * WAD);
        assertTrue(!apu.try_withdrawLost(WETH));
        assertTrue(owner.try_withdrawLost(WETH));
    }

    function test_partial_withdrawl() public {
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(1000 * WAD);
        uint256 bal = IERC20(DAI).balanceOf(address(owner));
        hevm.warp(block.timestamp + 15 days);
        uint256 avail = owner.getWithdrawableBalance();
        uint256 nwd = avail / 10;
        owner.withdraw(nwd);
        approxEq(IERC20(DAI).balanceOf(address(owner)), bal + nwd, 6);
        approxEq(owner.getWithdrawableBalance(), avail - nwd, 6);
    }

    function test_partial_withdrawl2() public {
        assertEq(owner.getWithdrawableBalance(), 0);
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(1000 * WAD);
        uint256 bal = IERC20(DAI).balanceOf(address(owner));
        hevm.warp(block.timestamp + 5 days);
        uint256 avail = owner.getWithdrawableBalance();
        uint256 nwd = avail / 3;
        owner.withdraw(nwd);
        approxEq(IERC20(DAI).balanceOf(address(owner)), bal + nwd, 6);
        approxEq(owner.getWithdrawableBalance(), avail - nwd, 4);
    }
}
