pragma solidity ^0.6.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory ticker) public ERC20(name, ticker) {
        _mint(msg.sender, 1000000 * (10**uint256(decimals())));
    }
}
