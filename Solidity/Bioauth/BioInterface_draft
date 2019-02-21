// Abstract contract for the full IrIP 20 Token standard
pragma solidity >=0.4.22 <0.6.0;

contract BioInterface {

    struct Privacy {
        bytes32 bioInfo;
        bytes32 privKey;
        address addr;
        Facility[] facilities;
    }

    struct Facility {
        uint8 type;
        uint256 id;
        bytes32 pubKey;
    }

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Bind(address indexed _owner, bytes32 indexed _cipher);
    event Verify();

    mapping(bytes32 => Privacy) internal privacies;
    mapping(bytes32 => mapping(bytes32 => Facility)) internal approved;

    function facilitiesOf(bytes32 _owner) external view returns (Facility[] facilities);

    function approveOf(bytes32 _owner, bytes32 _authorized) external view returns (Facility[] facilities);

    function approve(bytes32 _authorized, Facility _facility) public;

    function transfer(address _to, uint256 _value) public;

    function mulTransfer(address[] memory _tos, uint256[] memory _values) public;

    function bind(bytes32 bioInfo, Facility facility) public;

    function verify(bytes32 bioInfo, Facility facility) public;

    function encryptor(address _addr, uint8 _faciType, uint256 _faciId) external pure returns (bytes32 cipher);
}