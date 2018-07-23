// Abstract contract for the full IrIP 20 Token standard
pragma solidity ^0.4.24;
pragma experimental "v0.5.0";

contract StockInterface {

    struct Holder {
        bool active;
        uint256 amount;
        uint256 frees;
        Share[] shares;
    }

    struct Share {
        uint256 locks;
        uint256 liftedPeriod;
    }

    mapping(address => mapping(address => uint256)) internal allowed;
    // address stores the currency contract may have, "0x" rep IRC, `this` rep self stock
    mapping(address => mapping(address => bool)) internal licensees;
    mapping(address => Holder) internal holderMap;

    uint256 public totalSupply;
    address[] public holderList;

    // @_type 1 rep all the holding amount, 2 rep frees holding, 3 rep all the shares in locking period
    function shareOf(address _owner, uint8 _type) external view returns (uint256 share);

    function allowanceOf(address _owner, address _spender) external view returns (uint256 remaining);

    function licenseOf(address _licensee, address _currency) external view returns (bool licensed);

    function approve(address _spender, uint256 _value) public;

    function licensing(address _licensee, address _currency, bool _value) public;

    function transfer(address _to, uint256 _value, uint256 _lockPeriod) public;

    function transferFrom(address _from, address _to, uint256 _value, uint256 _lockPeriod) public;

    function mulTransfer(address[] _tos, uint256[] _values, uint256[] _lockPeriod) public;

    function withdraw(address _to, address _currency, uint256 _value) public payable;

    function payDividend(address _currency) public payable;

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 _lockPeriod);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Licensing(address indexed _licensor, address indexed _licensee, address indexed _currency, bool _value);
    event Withdraw(address indexed _executor, address indexed _to, address indexed _currency, uint256 _value);
    event PayDividend(address indexed _executor, address indexed _currency);
}
