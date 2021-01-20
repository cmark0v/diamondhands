pragma solidity ^0.6.7;

import "lib/ds-test/contracts/test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface Hevm {
    function warp(uint256) external;

    function store(
        address,
        bytes32,
        bytes32
    ) external;
}

contract TestEnv is DSTest {
    Hevm hevm;

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    bytes20 constant CHEAT_CODE = bytes20(uint160(uint256(keccak256("hevm cheat code"))));

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    mapping(address => uint256) balanceSlot;

    constructor() public {
        hevm = Hevm(address(CHEAT_CODE));
        balanceSlot[DAI] = 2; //balanceOf is second mapping in appearing in the source
        balanceSlot[WETH] = 3;
    }

    function mint(
        address addr,
        address who,
        uint256 amt
    ) public {
        uint256 slot = balanceSlot[addr];
        if (slot == 0) {
            emit log_named_address("set the slot for balance of token", addr);
        }
        uint256 bal = IERC20(addr).balanceOf(who);

        hevm.store(addr, keccak256(abi.encode(who, slot)), bytes32(bal + amt));

        assertEq(IERC20(addr).balanceOf(who), bal + amt);
    }

    function approxEq(
        uint256 val0,
        uint256 val1,
        uint256 accuracy
    ) public {
        uint256 diff = val0 > val1 ? val0 - val1 : val1 - val0;
        bool check = (diff * RAY)/(val0+val1) < (RAY / 10**accuracy);

        if (!check) {
            emit log_named_uint("Error: approx a == b not satisfied, accuracy digits ", accuracy);
            emit log_named_uint("  Expected", val1);
            emit log_named_uint("    Actual", val0);
            fail();
        }
    }
}
