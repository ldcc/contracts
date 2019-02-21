pragma solidity >=0.4.22 <0.6.0;

import "./BioInterface.sol";

contract Bioauth is BioInterface {

    constructor() public {}

    function facilitiesOf(bytes32 _owner) external view returns (uint256[] memory facilityMacs) {
        facilityMacs = privacies[_owner].facilityMacs;
    }

    function encrypt(Privacy memory _privacy, Facility memory _facility) internal pure returns (bytes32 cipher) {
        bytes memory bioInfo = _toBytes(_privacy.bioInfo);
        bytes memory privKey = _toBytes(_privacy.privKey);
        bytes memory facilityType = _intToBytes(_facility.facilityType);
        bytes memory facilityId = _intToBytes(_facility.facilityId);
        bytes memory facilityMac = _intToBytes(_facility.facilityMac);
        bytes memory pubKey = _toBytes(_facility.pubKey);
        cipher = keccak256(
            abi.encodePacked(
                keccak256(bioInfo),
                keccak256(privKey),
                keccak256(facilityType),
                keccak256(facilityId),
                keccak256(facilityMac),
                keccak256(pubKey)));
    }

    function bind(bytes32 _bioInfo, uint8 _facilityType, uint256 _facilityId, uint256 _facilityMac, bytes32 _pubKey) public {
        Privacy storage privacy = privacies[_bioInfo];
        if (privacy.exists) {
            require(privacy.bioInfo == _bioInfo);
            require(privacy.privKey == '??');
        } else {
            privacy.exists = true;
            privacy.bioInfo = _bioInfo;
            privacy.privKey = '??';
        }
        privacy.facilityMacs.push(_facilityMac);
        Facility memory facility = Facility(_facilityType, _facilityId, _facilityMac, _pubKey, '');
        bytes32 cipher = encrypt(privacy, facility);
        facility.cipher = cipher;
        facilitiesOwns[_bioInfo][_facilityMac] = facility;
        assert(encrypt(privacy, facility) == cipher);
        emit Bind(privacy.bioInfo, now);
    }

    function verify(bytes32 _bioInfo, uint8 _facilityType, uint256 _facilityId, uint256 _facilityMac, bytes32 _pubKey) external returns (bool success) {
        Privacy memory privacy = privacies[_bioInfo];
        require(privacy.exists);
        require(privacy.bioInfo == _bioInfo);
        require(privacy.privKey == '??');
        Facility memory facility = facilitiesOwns[_bioInfo][_facilityMac];
        bytes32 cipher = encrypt(privacy, facility);
        require(facility.facilityType == _facilityType);
        require(facility.facilityId == _facilityId);
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