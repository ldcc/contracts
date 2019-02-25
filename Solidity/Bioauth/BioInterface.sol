// Abstract contract for the full Bio Information authorize standard
pragma solidity >=0.4.22 <0.6.0;

contract BioInterface {

    struct Privacy {
        bool registed;
        bytes32 bioInfo;
        bytes32 privKey;
    }

    struct Facility {
        bool occupy;
        bytes32 owner;
        bytes32 fMac;
        bytes32 pubKey;
        bytes32 cipher;
    }

    event Regist(bytes32 indexed _register, uint indexed _timestamp);
    event Bound(bytes32 indexed _owner, uint indexed _timestamp);
    event UnBound(bytes32 indexed _owner, uint indexed _timestamp);
    event Verify(bytes32 indexed _authorized, uint indexed _timestamp);

    mapping(bytes32 => Privacy) internal privacySaves;
    mapping(bytes32 => Facility) internal facilitiesOwns;

    // supply privKey??????????
    function regist(bytes32 _bioInfo, bytes32 _privKey) public;

    function bound(bytes32 _bioInfo, bytes32 _privKey, bytes32 _fMac, bytes32 _pubKey) public;

    function unBound(bytes32 _bioInfo, bytes32 _privKey, bytes32 _fMac, bytes32 _pubKey) public;

    function verify(bytes32 _bioInfo, bytes32 _privKey, bytes32 _fMac, bytes32 _pubKey) public returns (bool success);

    function encrypt(Privacy memory _privacy, Facility memory _facility) internal pure returns (bytes32 cipher);
}