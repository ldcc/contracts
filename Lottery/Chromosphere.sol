pragma solidity ^0.4.0;

contract chromosphere {

    uint8 private constant PRICE = 2;
    uint8 private constant RADIX = 6;
    uint8 private constant MAXRED = 33;
    uint8 private constant MAXBLUE = 16;
    uint256 private constant BOUNSPOOL = 5000000 ether;

    struct Gambler {
        uint256 stake;
        bool[MAXRED] reds;
        bool[MAXBLUE] blues;
    }

    //    struct Ball {
    //        bool color;
    //        uint8 number;
    //    }

    // index 0 and 1 is the percent of rewards amount pre bet
    // index 2-5 are fixed rewards pre bet
    uint256[6] private rewards = [uint256(70), 30, 3000, 200, 10, 5];
    uint[2][6] answer;
    //    Ball[7] private answer;

    uint256 public deadline;
    address private founder;
    address public pool;
    string public name;
    string public symbol;

    mapping(address => Gambler) private gamblers;

    constructor () public payable {
        founder = msg.sender;
    }

    function answerOf() external view returns (uint[2][6] balls) {
        return answer;
    }

    function open(address _currency, uint256 _deadline) public {
        require(founder == msg.sender);
        require(_currency != address(this));
        require(_deadline >= 86400);
        require(deadline == 0);
        if (_currency == address(0)) {
            assert(address(this).balance >= BOUNSPOOL);
        } else {
            assert(_currency.call(bytes4(keccak256("transfer")), address(this), BOUNSPOOL));
            assembly {}
        }
        deadline = _deadline + block.timestamp;
        pool = _currency;
    }

    function enter(uint8[] reds, uint8[] blues) public payable {
        require(deadline > block.timestamp);
        require(reds.length >= RADIX && blues.length >= 1);
        require(reds.length <= MAXRED && blues.length <= MAXBLUE);
        uint256 stake = evalStake(uint8(reds.length), uint8(blues.length));
        if (pool == address(0)) {
            assert(msg.value >= stake);
        } else {
            assert(pool.call(bytes4(keccak256("transfer")), address(this), stake));
        }

        Gambler storage gambler = gamblers[msg.sender];
        for (uint8 i = 0; i <= reds.length; i++) {
            gambler.reds[reds[i]] = true;
        }
        for (uint8 i = 0; i <= blues.length; i++) {
            gambler.blues[blues[i]] = true;
        }
    }

    //    function receivePrize() public {
    //
    //    }

    //    function lottery() public {
    //        require(founder == msg.sender);
    //
    //    }

    function evalStake(uint8 reds, uint8 blues) private pure returns (uint256 stake) {
        stake = fact(reds) / fact(RADIX) / fact(reds - RADIX) * blues * PRICE;
    }

    function fact(uint8 n) private pure returns (uint256 ret) {
        for (; n > 0; n--) {
            ret *= n;
        }
    }

        function random() private view returns (uint8) {
            return uint8(uint256(keccak256(block.timestamp, block.difficulty))%251);
        }
}
