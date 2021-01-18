pragma solidity ^0.6.7;

import "lib/ds-test/contracts/test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "./TestEnv.sol";

import "./Diamondhands.sol";


contract Owner {
    Diamondhands diamondhands;

    constructor(Diamondhands _diamondhands) public {
        diamondhands = _diamondhands;
    }

    function deposit(uint256 _amt) public {
        diamondhands.deposit(_amt);
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
}

contract DiamondhandsTest is TestEnv {
    Diamondhands diamondhands;
    Owner owner;

    function setUp() public {
        diamondhands = new Diamondhands(address(DAI), 30 days);
        owner = new Owner(diamondhands);
        diamondhands.setOwner(address(owner));
        mint(DAI, address(owner), 5000 * WAD);
    }

    function test_viewbal() public {
        assertEq(diamondhands.getWithdrawableBalance(), 0);
    }

    function test_deposit() public {
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(100 * WAD);
        assertEq(IERC20(DAI).balanceOf(address(diamondhands)), 100 * WAD);
    }

    function test_withdraw() public {
        owner.approve(DAI, address(diamondhands), uint256(-1));
        owner.deposit(1000 * WAD);
        hevm.warp(block.timestamp + 15 days);
        approxEq(owner.getWithdrawableBalance(), 500 * WAD, 6);
    }

    function test_sets() public {
        assertEq(uint256(DAI), uint256(diamondhands.holdToken()));
        assertEq(diamondhands.timeLock(), 30 days);
    }

    
}
