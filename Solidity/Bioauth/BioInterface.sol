// Abstract contract for the full IrIP 20 Token standard
pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract BioInterface {

    struct Privacy {
        address addr;
        bytes32 bioInfo;
        bytes32 privKey;
        Facility[] facilities;
    }

    struct Facility {
        uint8 faciType;
        uint256 faciId;
        bytes32 pubKey;
    }

    event Bind(address indexed _owner, uint indexed _timestamp);
    event Verify(address indexed _authorized, uint indexed _timestamp);

    mapping(bytes32 => Privacy) internal privacies;

    function facilitiesOf(bytes32 _owner) external view returns (Facility[] memory facilities);

    function encrypt(Privacy memory privacy, Facility memory facility) internal pure returns (bytes32 cipher);

    function verify(bytes32 bioInfo, Facility memory facility) public;

    function bind(bytes32 bioInfo, Facility memory facility) public;
}