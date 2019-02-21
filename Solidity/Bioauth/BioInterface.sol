// Abstract contract for the full Bio Information authorize standard
pragma solidity >=0.4.22 <0.6.0;

contract BioInterface {

    struct Privacy {
        bool exists;
        bytes32 bioInfo;
        bytes32 privKey;
        uint256[] facilityMacs;
    }

    struct Facility {
        uint8 facilityType;
        uint256 facilityId;
        uint256 facilityMac;
        bytes32 pubKey;
        bytes32 cipher;
    }

    event Bind(bytes32 indexed _owner, uint indexed _timestamp);
    event Verify(bytes32 indexed _authorized, uint indexed _timestamp);

    mapping(bytes32 => Privacy) internal privacies;
    mapping(bytes32 => mapping(uint256 => Facility)) internal facilitiesOwns;

    function facilitiesOf(bytes32 _owner) external view returns (uint256[] memory facilityMacs);

    function encrypt(Privacy memory _privacy, Facility memory _facility) internal pure returns (bytes32 cipher);

    function bind(bytes32 _bioInfo, uint8 _facilityType, uint256 _facilityId, bytes32 _pubKey) public;

    function verify(bytes32 _bioInfo, uint8 _facilityType, uint256 _facilityId, bytes32 _pubKey) external returns(bool success);
}