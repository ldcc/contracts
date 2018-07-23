// Abstract contract for the full IrIP 20 Token standard
pragma solidity ^0.4.24;
pragma experimental "v0.5.0";

contract IrIP20Interface {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Licensing(address indexed _licensor, address indexed _licensee, address indexed _currency, bool _value);
    event Withdraw(address indexed _executor, address indexed _to, address indexed _currency, uint256 _value);

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => mapping(address => bool)) internal licensees;

    address public founder;
    uint256 public totalSupply;

    function balanceOf(address _owner) external view returns (uint256 balance);

    function allowanceOf(address _owner, address _spender) external view returns (uint256 remaining);

    function licenseOf(address _licensee, address _currency) external view returns (bool licensed);

    function approve(address _spender, uint256 _value) public;

    function licensing(address _licensee, address _currency, bool _value) public;

    function transfer(address _to, uint256 _value) public;

    function transferFrom(address _from, address _to, uint256 _value) public;

    function mulTransfer(address[] _tos, uint256[] _values) public;

    function withdraw(address _to, address _currency, uint256 _value) public payable;
}

