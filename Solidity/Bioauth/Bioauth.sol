pragma solidity >=0.4.22 <0.6.0;

import "./BioInterface.sol";

contract Bioauth is BioInterface {

    constructor() public {}

    function facilitiesOf(bytes32 _owner) external view returns (uint256[] memory facilityMacs) {
        facilityMacs = privacies[_owner].facilityMacs;
    }

    function encrypt(Privacy memory _privacy, Facility memory _facility) internal pure returns (bytes32 cipher) {
        cipher = keccak256(
            keccak256(
                keccak256(_privacy.bioInfo),
                keccak256(_privacy.privKey)),
            keccak256(
                keccak256(_facility.facilityType),
                keccak256(_facility.facilityId),
                keccak256(_facility.facilityMac),
                keccak256(_facility.pubKey)));
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
        Facility facility = Facility({
            facilityType : _facilityType,
            facilityId : _facilityId,
            facilityMac : _facilityMac,
            pubKey : _pubKey});
        byte32 cipher = encrypt(privacy, facility);
        facility.cipher = cipher;
        facilitiesOwns[_bioInfo][_facilityMac] = facility;
        assert(encrypt(privacy, facility) == cipher);
        emit Bind(privacy.bioInfo, now);
    }

    function verify(bytes32 _bioInfo, uint8 _facilityType, uint256 _facilityId, uint256 _facilityMac, bytes32 _pubKey) external view returns (bool success) {
        Privacy storage privacy = privacies[_bioInfo];
        require(privacy.exists);
        require(privacy.bioInfo == _bioInfo);
        require(privacy.privKey == '??');
        Facility facility = facilitiesOwns[_bioInfo][_facilityMac];
        bytes32 cipher = encrypt(privacy, facility);
        success = facility.cipher == cipher;
        require(success);
        emit Verify(privacy.bioInfo, now);
    }
}