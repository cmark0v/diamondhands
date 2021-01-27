pragma solidity ^0.6.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

//single owner can lock multiple tokens for diferent lengs for each token

contract Diamondhands {
    uint256 private constant WAD = 10**18;
    string private constant TXERR = "TX_ERR";
    string private constant UNAVAILERR = "LOCKED";
    string private constant UNAUTH = "UNAUTH";
    address private owner;

    uint256 private depositDate;
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

    function deposit(uint256 _amt) external {
        _updateDepositAge(_amt);
        require(IERC20(holdToken).transferFrom(msg.sender, address(this), _amt), TXERR);
    }

    function withdraw(uint256 _amt) external isOwner {
        require(_amt <= getWithdrawableBalance(), UNAVAILERR);
        _updateWithdrawAge(_amt);
        require(IERC20(holdToken).transferFrom(address(this), msg.sender, _amt), TXERR);
    }

    function getWithdrawableBalance() public view returns (uint256) {
        uint256 bal = IERC20(holdToken).balanceOf(address(this));
        uint256 out = ((((block.timestamp - depositDate) * WAD) / (timeLock)) * bal) / WAD;
        if (out > bal) {
            out = bal;
        }
        return out;
    }

    function _updateWithdrawAge(uint256 _amt) internal {
        uint256 bal = IERC20(holdToken).balanceOf(address(this));
        if (_amt == bal) {
            depositDate = block.timestamp;
        } else {
            uint256 corr =
                (_amt * WAD * (timeLock - (block.timestamp - depositDate))) / (bal - _amt);
            depositDate = (depositDate * WAD + corr) / WAD;
        }
    }

    function _updateDepositAge(uint256 _amt) internal {
        if (depositDate == 0) {
            depositDate = block.timestamp;
        } else {
            uint256 coef = (WAD * _amt) / (IERC20(holdToken).balanceOf(address(this)) + _amt);
            depositDate = (depositDate * WAD + (block.timestamp - depositDate) * coef) / WAD;
        }
    }

    function setOwner(address _owner) external isOwner {
        owner = _owner;
    }

    //drain random tokens if they end up here
    function withdrawLost(address _token) external isOwner {
        require(_token != holdToken, UNAVAILERR);
        IERC20(_token).transfer(owner, IERC20(_token).balanceOf(address(this)));
    }
}
