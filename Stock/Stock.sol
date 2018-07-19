pragma solidity ^0.4.24;
pragma experimental "v0.5.0";

import "./StockInterface.sol";

contract Stock is StockInterface {

    string public name;
    string public symbol;
    address public founder;

    constructor(uint256 _initialAmount, string _name, string _symbol) public payable {
        totalSupply = _initialAmount;
        name = _name;
        symbol = _symbol;
        founder = msg.sender;
        holders[msg.sender] = Holder({
            amount : _initialAmount,
            frees : _initialAmount,
            shares : new Share[](0)});
        licensees[msg.sender][0] = true;
        licensees[msg.sender][1] = true;
    }

    function shareOf(address _owner, uint8 _type) external view returns (uint256 share) {
        Holder memory h = holders[_owner];
        if (_type == 1) {
            return h.amount;
        } else if (_type == 2) {
            return h.frees;
        } else {
            return h.amount - h.frees;
        }
    }

    function allowanceOf(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function licenseOf(address _licensee, uint8 _code) external view returns (bool licensed) {
        return licensees[_licensee][_code];
    }

    function approve(address _spender, uint256 _value) public {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function licensing(address _licensee, uint8 _code, bool _value) public {
        if (_value) {
            require(msg.sender == founder);
        } else {
            require(msg.sender == _licensee);
        }
        licensees[_licensee][_code] = _value;
        emit Licensing(_licensee, _code, _value);
    }

    function transfer(address _to, uint256 _value, uint256 lockPeriod) public {
        _transfer(msg.sender, _to, _value, lockPeriod);
    }

    function transferFrom(address _from, address _to, uint256 _value, uint256 lockPeriod) public;

    function mulTransfer(address[] _tos, uint256[] _values, uint256[] lockPeriod) public;

    function withdraw(address _to, uint256 _value, bool _type) public payable;

    function payDividend(uint8 _code) public payable;

    //    function _payCash() payable {
    //
    //    }

    //    function _payShare() payable {
    //
    //    }

    //    function _payToken() payable {
    //
    //    }


    function _transfer(address _from, address _to, uint256 _value, uint256 _lockPeriod) private {
        require(_value > 0);
        Holder storage h = holders[_from];
        require(h.amount >= _value);
        if (h.frees < _value) {
            _upgradeHolder(h);
        }
        require(h.frees >= _value);
        //        uint256 oldTo = balances[_to];
        //        balances[_from] -= _value;
        //        balances[_to] += _value;
        emit Transfer(_from, _to, _value, _lockPeriod);
        //        assert(oldTo < balances[_to]);
    }

    function _upgradeHolder(Holder storage _h) private {
        uint256 unlocks = 0;
        uint256 present = block.timestamp;
        Share[] memory shares = _h.shares;
        delete _h.shares;
        for (uint8 i = 0; i < _h.shares.length; i++) {
            Share memory share = shares[i];
            if (present >= share.liftedPeriod) {
                unlocks += share.locks;
            } else {
                _h.shares.push(share);
            }
        }
        _h.amount += unlocks;
        _h.frees += unlocks;
    }
}
