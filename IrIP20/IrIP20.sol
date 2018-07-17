// Abstract contract for the full IrIP 20 Token standard
pragma solidity ^0.4.21;

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
        balances[msg.sender] = _initialAmount;
        licensees[msg.sender][true] = true;
        licensees[msg.sender][false] = true;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowanceOf(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function licenseOf(address _licensee, bool _type) external view returns (bool licensed) {
        return licensees[_licensee][_type];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function licensing(address _licensee, bool _type) public returns (bool success) {
        require(licensees[msg.sender][_type]);
        licensees[_licensee][_type] = true;
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        require(_value > 0);
        require(balances[_from] >= _value);
        uint256 oldTo = balances[_to];
        balances[_from] -= _value;
        balances[_to] += _value;
        _deduction(_to, _value);
        emit Transfer(_from, _to, _value);
        assert(oldTo < balances[_to]);
    }

    function _deduction(address _to, uint256 _value) private {
        require(costpc > 0 && costpc < 100);
        uint256 v = _value * costpc;
        require(v >= 100 && v >= _value);
        uint256 cost = v / 100;
        uint256 oldThis = balances[this];
        balances[_to] -= cost;
        balances[this] += cost;
        assert(oldThis <= balances[this]);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(allowance > 0);
        require(allowance >= _value);
        _transfer(_from, _to, _value);
        allowed[_from][msg.sender] -= _value;
        return true;
    }

    function mulTransfer(address[] _tos, uint256[] _values) public returns (bool success) {
        require(_tos.length == _values.length);
        uint256 i = 0;
        while (i < _tos.length) {
            transfer(_tos[i], _values[i]);
            i += 1;
        }
        return true;
    }

    function withdraw(address _to, uint256 _value, bool _type) public payable returns (bool success) {
        require(licensees[msg.sender][_type]);
        if (_type) {
            require(_value > 0);
            assert(address(this).balance >= _value);
            _to.transfer(_value);
        } else {
            _transfer(this, _to, _value);
        }
        return true;
    }

}
