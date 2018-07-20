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
        holders[msg.sender].amount = _initialAmount;
        holders[msg.sender].frees = _initialAmount;
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

    function transfer(address _to, uint256 _value, uint256 _lockPeriod) public {
        _transfer(msg.sender, _to, _value, _lockPeriod);
    }

    function transferFrom(address _from, address _to, uint256 _value, uint256 _lockPeriod) public {
        _from;
        _to;
        _value;
        _lockPeriod;
    }

    function mulTransfer(address[] _tos, uint256[] _values, uint256[] _lockPeriods) public {
        _tos;
        _values;
        _lockPeriods;
    }

    function withdraw(address _to, uint256 _value, bool _type) public payable {
        _to;
        _value;
        _type;
    }

    function payDividend(uint8 _code) public payable {
        _code;
    }

    function _transfer(address _from, address _to, uint256 _value, uint256 _lockPeriod) private {
        require(_value > 0);
        Holder storage hf = holders[_from];
        require(hf.amount >= _value);
        if (hf.frees < _value) {
            _upgradeHolder(hf);
        }
        require(hf.frees >= _value);
        Holder storage ht = holders[_to];
        uint256 oldHtAmount = ht.amount;

        hf.amount -= _value;
        hf.frees -= _value;
        ht.amount += _value;
        if (_lockPeriod > 0) {
            uint256 liftedPeriod = _lockPeriod + block.timestamp;
            Share memory share = Share({
                locks : _value,
                liftedPeriod : liftedPeriod});
            ht.shares.push(share);
        } else {
            ht.frees += _value;
        }
        emit Transfer(_from, _to, _value, _lockPeriod);
        assert(oldHtAmount < ht.amount);
    }

    function _upgradeHolder(Holder storage _h) private {
        uint256 unlocks = 0;
        uint256 present = block.timestamp;
        for (uint8 i = 0; i < _h.shares.length; i++) {
            if (_h.shares[i].locks == 0) {
                continue;
            }
            if (present >= _h.shares[i].liftedPeriod) {
                unlocks += _h.shares[i].locks;
                delete _h.shares[i];
            }
        }
        if (unlocks > 0) {
            _h.frees += unlocks;
        }
    }

}
