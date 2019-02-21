// Abstract contract for the full Bio Information authorize standard
pragma solidity >=0.4.22 <0.6.0;

contract BioInterface {

    struct Privacy {
        bool exists;
        bytes32 bioInfo;
        bytes32 privKey;
        bytes32[] fMacs;
    }

    struct Facility {
        uint8 fType;
        uint256 fId;
        bytes32 fMac;
        bytes32 pubKey;
        bytes32 cipher;
    }

    event Bind(bytes32 indexed _owner, uint indexed _timestamp);
    event Verify(bytes32 indexed _authorized, uint indexed _timestamp);

    mapping(bytes32 => Privacy) internal privacies;
    mapping(bytes32 => mapping(bytes32 => Facility)) internal facilitiesOwns;

    function facilitiesOf(bytes32 _owner) external view returns (bytes32[] memory fMacs);

    function encrypt(Privacy memory _privacy, Facility memory _facility) internal pure returns (bytes32 cipher);

    function bind(bytes32 _bioInfo, uint8 _fType, uint256 _fId, bytes32 _fMac, bytes32 _pubKey) public;

    function verify(bytes32 _bioInfo, uint8 _fType, uint256 _fId, bytes32 _fMac, bytes32 _pubKey) external returns (bool success);
}