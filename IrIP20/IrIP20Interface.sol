// Abstract contract for the full IrIP 20 Token standard
pragma solidity ^0.4.24;
pragma experimental "v0.5.0";

contract IrIP20Interface {

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => mapping(bool => bool)) internal licensees;

    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowanceOf(address _owner, address _spender) external view returns (uint256 remaining);

    /// @param _licensee The address of` the account is it licensed withdraw
    /// @param _type The address of the account able to transfer the tokens
    /// @return Authorization of licensed currency is it allowed to withdraw
    function licenseOf(address _licensee, bool _type) external view returns (bool licensed);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` licensing `_licensee` to withdraw some `_type` of currency
    /// @param _licensee The address of the account able to withdraw the tokens
    /// @param _type The currency type to be licensing for transfer
    /// @return Whether the licensing was successful or not
    function licensing(address _licensee, bool _type) public returns (bool success);

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
    /// @return Whether the transfers was successful or not
    function mulTransfer(address[] _tos, uint256[] _values) public returns (bool success);

    /// @notice withdraw `_value` Wei to `_to` from this contract`
    /// @param _to The address of the recipient
    /// @param _value The amount of Wei to be transferred
    /// @param _value The currency type of _to to be withdraw, true rep IRC, false rep the token of this contract
    /// @return Whether the withdraw was successful or not
    function withdraw(address _to, uint256 _value, bool _type) public payable returns (bool success);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
