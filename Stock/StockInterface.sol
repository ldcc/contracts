// Abstract contract for the full IrIP 20 Token standard
pragma solidity ^0.4.24;
pragma experimental "v0.5.0";

contract StockInterface {

    struct Holder {
        uint256 amount;
        uint256 frees;
        Share[] shares;
    }

    struct Share {
        uint256 locks;
        uint256 liftedPeriod;
    }

    mapping(address => Holder) internal holders;
    mapping(address => mapping(address => uint256)) internal allowed;
    // uint8 stored the currency type contract may have, 0 rep IRC, 1 rep self stock
    mapping(address => mapping(uint8 => bool)) internal licensees;

    uint256 public totalSupply;

    // @_type 1 rep all the holding amount, 2 rep frees holding, 3 rep all the shares in locking period
    function shareOf(address _owner, uint8 _type) external view returns (uint256 share);

    function allowanceOf(address _owner, address _spender) external view returns (uint256 remaining);

    function licenseOf(address _licensee, bool _type) external view returns (bool licensed);

    function approve(address _spender, uint256 _value) public;

    function licensing(address _licensee, bool _type, bool _value) public;

    function transfer(address _to, uint256 _value, uint256 lockPeriod) public;

    function transferFrom(address _from, address _to, uint256 _value, uint256 lockPeriod) public;

    function mulTransfer(address[] _tos, uint256[] _values, uint256[] lockPeriod) public;

    function withdraw(address _to, uint256 _value, bool _type) public payable;

    function payDividend(uint8 currencyCode) public payable;

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 lockPeriod);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Licensing(address _licensee, uint8 _code, bool _value);
    event PayDividend(uint256 timestamp);
}
