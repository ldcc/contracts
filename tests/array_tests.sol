pragma solidity ^0.4.0;

contract array_tests {

    uint256 public x;
    uint256[] public xs;

    constructor () public payable {
        xs = [uint256(1), 2, 3];
    }

    function testArray() public {
        uint256[] memory a = xs;
        delete xs;
        x = a.length;
    }

    function xsAdd1() public {
        xs.push(uint256(1));
    }

    function getX() public view returns (uint256 res) {
        return x;
    }
}
