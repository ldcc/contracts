// Abstract contract for the full Stock standard
pragma solidity >=0.4.22 <0.6.0;

import "./IrIP20Interface.sol";

contract StockInterface is IrIP20Interface {

    event PayDividend(address indexed _executor, address indexed _currency);

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

    mapping(address => Holder) internal holderMap;

    address[] internal holderList;

    // @param _type 1 rep all the holding amounts, 2 rep free holdings, 3 rep the number of in locking period
    function shareOf(address _owner, uint8 _type) external view returns (uint256 share);

    function transfer(address _to, uint256 _value, uint256 _lockPeriod) public;

    function transferFrom(address _from, address _to, uint256 _value, uint256 _lockPeriod) public;

    function mulTransfer(address[] memory _tos, uint256[] memory _values, uint256[] memory _lockPeriods) public;

    function payDividend(address _currency) public;
}
