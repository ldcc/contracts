pragma solidity ^0.4.24;

import "./IrIP20Interface.sol";

contract IrIP20 is IrIP20Interface {

    string public name;
    string public symbol;
    uint8 public costpc;
    uint8 public decimals = 18;

    constructor(uint256 _initialAmount, string _name, string _symbol, uint8 _costpc) public payable {
        totalSupply = _initialAmount * 10 ** uint256(decimals);
        name = _name;
        symbol = _symbol;
        costpc = _costpc;
        founder = msg.sender;
        balances[msg.sender] = _initialAmount;
        licensees[msg.sender][address(0)] = true;
        licensees[msg.sender][address(this)] = true;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowanceOf(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function licenseOf(address _licensee, address _currency) external view returns (bool licensed) {
        return licensees[_licensee][_currency];
    }

    function approve(address _spender, uint256 _value) public {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function licensing(address _licensee, address _currency, bool _value) public {
        if (_value) {
            require(msg.sender == founder);
        } else {
            require(msg.sender == _licensee);
            require(licensees[_licensee][_currency]);
        }
        licensees[_licensee][_currency] = _value;
        emit Licensing(msg.sender, _licensee, _currency, _value);
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        require(_value > 0);
        require(balances[_from] >= _value);
        uint256 oldTo = balances[_to];
        balances[_from] -= _value;
        balances[_to] += _value;
        _deduction(_to, _value);
        assert(oldTo < balances[_to]);
    }

    function _deduction(address _to, uint256 _value) private {
        require(costpc > 0 && costpc < 100);
        uint256 v = uint256(_value * costpc);
        require(v >= 100 && v >= _value);
        uint256 cost = uint256(v / 100);
        uint256 oldThis = balances[this];
        balances[_to] -= cost;
        balances[this] += cost;
        assert(oldThis <= balances[this]);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public {
        require(allowed[_from][msg.sender] > 0);
        require(allowed[_from][msg.sender] >= _value);
        _transfer(_from, _to, _value);
        emit Transfer(_from, _to, _value);
        allowed[_from][msg.sender] -= _value;
    }

    function mulTransfer(address[] _tos, uint256[] _values) public {
        require(_tos.length == _values.length);
        for (uint256 i = 0; i < _tos.length; i++) {
            transfer(_tos[i], _values[i]);
        }
    }

    function withdraw(address _to, address _currency, uint256 _value) public {
        require(msg.sender == founder || licensees[msg.sender][_currency]);
        if (_currency == address(0)) {
            require(_value > 0);
            assert(address(this).balance >= _value);
            _to.transfer(_value);
        } else if (_currency == address(this)) {
            _transfer(_currency, _to, _value);
        } else {
            assert(_currency.call(bytes4(keccak256("transfer")), _to, _value));
        }
        emit Withdraw(msg.sender, _to, _currency, _value);
    }
}
