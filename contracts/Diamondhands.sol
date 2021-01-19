pragma solidity ^0.6.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

//single owner can lock multiple tokens for diferent lengs for each token

contract Diamondhands {
    uint256 constant WAD = 10**18;
    string constant TXERR = "TX_ERR";
    string constant UNAVAILERR = "TOKENS LOCKED";
    string constant UNAUTH = "UNAUTH";
    address public owner;

    uint256 public depositDate;
    uint256 public timeLock; //in seconds
    address public holdToken;

    constructor(address _holdToken, uint256 _timeLock) public {
        timeLock = _timeLock;
        holdToken = _holdToken;
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, UNAUTH);
        _;
    }

    function deposit(uint256 _amt) external isOwner {
        _updateDepositAge(_amt);
        require(IERC20(holdToken).transferFrom(msg.sender, address(this), _amt), TXERR);
    }

    function withdraw(uint256 _amt) external isOwner {
        require(_amt <= getWithdrawableBalance(), UNAVAILERR);
        depositDate = block.timestamp;
        //reset deposit date, so now total bal is available timeLock seconds from now
        require(IERC20(holdToken).transferFrom(address(this), msg.sender, _amt), TXERR);
    }

    function getWithdrawableBalance() public view returns (uint256) {
        uint256 bal = IERC20(holdToken).balanceOf(address(this));
        uint256 time = (block.timestamp - depositDate) * WAD;
        uint256 out = ((time / (timeLock + 1)) * bal) / WAD;
        if (out > bal) {
            out = bal;
        }
        return out;
    }

    function _updateDepositAge(uint256 _amt) internal {
        if (depositDate == 0) {
            depositDate = block.timestamp;
        } else {
            uint256 bal = IERC20(holdToken).balanceOf(address(this));
            uint256 date = depositDate;
            uint256 coef = (WAD * _amt) / (bal + _amt);
            depositDate = (date * WAD + (block.timestamp - date) * coef) / WAD;
        }
    }
    function setOwner(address _owner) external isOwner {
        owner = _owner;
    }
    //drain random tokens if they end up here
    function withdrawLost(address _token) external isOwner {
        require(_token != holdToken, UNAVAILERR);
        IERC20(_token).transferFrom(address(this), owner, IERC20(_token).balanceOf(address(this)));
    }
}
