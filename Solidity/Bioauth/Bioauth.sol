pragma solidity >=0.4.22 <0.6.0;

import "./BioInterface.sol";

contract Bioauth is BioInterface {

    constructor() public {}

    function setP(bytes32 _bioInfo, bytes32 _privKey) public {
        Privacy storage privacy = privacySaves[_bioInfo];
        privacy.registed = true;
        privacy.bioInfo = _bioInfo;
        privacy.privKey = _privKey;
    }

    function getP(bytes32 _bioInfo) public view returns (bytes32[2] memory data) {
        Privacy memory privacy = privacySaves[_bioInfo];
        data = [privacy.bioInfo, privacy.privKey];
    }

    function setF(bytes32 _fMac, bytes32 _pubKey) public {
        Facility storage facility = facilitiesOwns[_fMac];
        facility.occupy = false;
        facility.owner = _fMac;
        facility.fMac = _fMac;
        facility.pubKey = _pubKey;
    }

    function getF(bytes32 _fMac) public view returns (bytes32[2] memory data) {
        Facility storage facility = facilitiesOwns[_fMac];
        data = [facility.fMac, facility.pubKey];
    }

    modifier onlyOwner(bytes32 _bioInfo, bytes32 _privKey, bytes32 _fMac, bytes32 _pubKey) {
        Privacy memory p0 = privacySaves[_bioInfo];
        require(p0.bioInfo == _bioInfo);
        require(p0.privKey == _privKey);
        Facility memory f0 = facilitiesOwns[_fMac];
        require(f0.owner == _bioInfo);
        require(f0.fMac == _fMac);
        require(f0.pubKey == _pubKey);
        Privacy memory p1 = Privacy(false, _bioInfo, _privKey);
        Facility memory f1 = Facility(false, _bioInfo, _fMac, _pubKey, "");
        require(f0.cipher == encrypt(p1, f1));
        _;
    }

    function regist(bytes32 _bioInfo, bytes32 _privKey) public {
        Privacy storage privacy = privacySaves[_bioInfo];
        require(!privacy.registed);

        privacy.registed = true;
        privacy.bioInfo = _bioInfo;
        privacy.privKey = _privKey;
        emit Regist(privacy.bioInfo, now);
    }

    function bound(bytes32 _bioInfo, bytes32 _privKey, bytes32 _fMac, bytes32 _pubKey) public {
        Privacy storage privacy = privacySaves[_bioInfo];
        require(privacy.bioInfo == _bioInfo);
        require(privacy.privKey == _privKey);
        Facility storage facility = facilitiesOwns[_fMac];
        require(!facility.occupy);

        facility.occupy = true;
        facility.owner = _bioInfo;
        facility.fMac = _fMac;
        facility.pubKey = _pubKey;
        facility.cipher = encrypt(privacy, facility);
        emit Bound(_bioInfo, now);
    }

    function unBound(bytes32 _bioInfo, bytes32 _privKey, bytes32 _fMac, bytes32 _pubKey) public
    onlyOwner(_bioInfo, _privKey, _fMac, _pubKey) {
        Facility storage facility = facilitiesOwns[_fMac];

        facility.occupy = false;
        delete facility.owner;
        emit UnBound(_bioInfo, now);
    }

    function verify(bytes32 _bioInfo, bytes32 _privKey, bytes32 _fMac, bytes32 _pubKey) public
    onlyOwner(_bioInfo, _privKey, _fMac, _pubKey) returns (bool success) {
        success = true;
        emit Verify(_bioInfo, now);
    }

    function encrypt(Privacy memory _privacy, Facility memory _facility) internal pure returns (bytes32 cipher) {
        cipher = keccak256(
            abi.encodePacked(
                keccak256(_toBytes(_privacy.bioInfo)),
                keccak256(_toBytes(_privacy.privKey)),
                keccak256(_toBytes(_facility.owner)),
                keccak256(_toBytes(_facility.fMac)),
                keccak256(_toBytes(_facility.pubKey))));
    }

    function _toBytes(bytes32 _data) private pure returns (bytes memory b) {
        b = abi.encodePacked(_data);
    }

    function _intToBytes(uint256 x) private pure returns (bytes memory b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), x)}
    }
}