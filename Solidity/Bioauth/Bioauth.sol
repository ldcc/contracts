pragma solidity >=0.4.22 <0.6.0;

import "./BioInterface.sol";

contract Bioauth is BioInterface {

    constructor() public {}

    function facilitiesOf(bytes32 _owner) external view returns (bytes32[] memory fMacs) {
        fMacs = privacies[_owner].fMacs;
    }

    function encrypt(Privacy memory _privacy, Facility memory _facility) internal pure returns (bytes32 cipher) {
        cipher = keccak256(
            abi.encodePacked(
                keccak256(_toBytes(_privacy.bioInfo)),
                keccak256(_toBytes(_privacy.privKey)),
                keccak256(_intToBytes(_facility.fType)),
                keccak256(_intToBytes(_facility.fId)),
                keccak256(_toBytes(_facility.fMac)),
                keccak256(_toBytes(_facility.pubKey))));
    }

    function bind(bytes32 _bioInfo, uint8 _fType, uint256 _fId, bytes32 _fMac, bytes32 _pubKey) public {
        Privacy storage privacy = privacies[_bioInfo];
        if (privacy.exists) {
            require(privacy.bioInfo == _bioInfo);
            require(privacy.privKey == '??');
        } else {
            privacy.exists = true;
            privacy.bioInfo = _bioInfo;
            privacy.privKey = '??';
        }
        privacy.fMacs.push(_fMac);
        Facility memory facility = Facility(_fType, _fId, _fMac, _pubKey, '');
        bytes32 cipher = encrypt(privacy, facility);
        facility.cipher = cipher;
        facilitiesOwns[_bioInfo][_fMac] = facility;
        assert(encrypt(privacy, facility) == cipher);
        emit Bind(privacy.bioInfo, now);
    }

    function verify(bytes32 _bioInfo, uint8 _fType, uint256 _fId, bytes32 _fMac, bytes32 _pubKey) external returns (bool success) {
        Privacy memory privacy = privacies[_bioInfo];
        require(privacy.exists);
        require(privacy.bioInfo == _bioInfo);
        require(privacy.privKey == '??');
        Facility memory facility = facilitiesOwns[_bioInfo][_fMac];
        bytes32 cipher = encrypt(privacy, facility);
        require(facility.fType == _fType);
        require(facility.fId == _fId);
        require(facility.pubKey == _pubKey);
        require(facility.cipher == cipher);
        success = facility.cipher == cipher;
        assert(success);
        emit Verify(privacy.bioInfo, now);
    }

    function _toBytes(bytes32 _data) private pure returns (bytes memory b) {
        b = abi.encodePacked(_data);
    }

    function _intToBytes(uint x) private pure returns (bytes memory b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), x)}
    }
}