// Abstract contract for the full ERC 20 Token standard
pragma solidity ^0.4.21;


contract IrIP20Interface {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => bool) public owners;

    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowanceOf(address _owner, address _spender) public view returns (uint256 remaining);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice send `_values[i]` token to `_tos[i]` from `msg.sender`
    /// @param _tos The addresses of the recipient array
    /// @param _values The amounts of token to be transferred array
    /// @return Whether the transfer was successful or not
    function mulTransfer(address[] _tos, uint256[] _values) public returns (bool success);

    /// @notice withdraw `_value` Wei to `_to` from this contract`
    /// @param _to The address of the recipient
    /// @param _value The amount of Wei to be transferred
    /// @return Whether the transfer was successful or not
    function withdraw(address _to, uint256 _value) public returns (bool success);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract IrIP20 is IrIP20Interface {

    string public name;
    string public symbol;
    uint8 public costpc;
    uint8 public decimals = 18;

    constructor(uint256 _initialAmount, string _name, string _symbol, uint8 _costpc) public payable {
        totalSupply = _initialAmount * 10 ** uint256(decimals);
        balances[msg.sender] = _initialAmount;
        name = _name;
        symbol = _symbol;
        costpc = _costpc;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[_owner];
    }

    function allowanceOf(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_value > 0);
        require(balances[_from] >= _value);
        _deduction(_to, _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function _deduction(address _to, uint256 _value) internal {
        require(costpc <= 100);
        uint256 cost = _value * costpc / 100;
        require(_value > cost);
        balances[_to] -= cost;
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

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
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

    function withdraw(address _to, uint256 _value) public returns (bool success) {
        require(owners[_to]);
        return _to.send(_value);
    }

}
