pragma solidity ^0.4.24;

contract chromosphere {

    uint8 private constant PRICE = 2;
    uint8 private constant RADIX = 6;
    uint8 private constant MAXRED = 33;
    uint8 private constant MAXBLUE = 16;
    uint8 private constant MAXBALL = 7;
    uint256 private constant COOLDOWN = 86400;
    uint256 private constant BONUSPOOL = 5000000 ether;

    struct Gambler {
        address addr;
        bool[MAXRED] reds;
        bool[MAXBLUE] blues;
        uint8 bonusLevel;
        uint256 bonus;
    }

    uint256 public deadline;
    uint256 public bonusSupply;
    address public founder;
    address public pool;
    string public name;
    string public symbol;
    bool private active;

    // bonusPool should never be modify
    // index 0 and 1 are the percent of each win-bonus
    // index 2-5 are fixed bonus for each bet
    uint256[6] private bonusPool = [10, 5, 3000, 200, 10, 5];
    uint8[MAXBALL] private answer;
    Gambler[] private gamblers;

    constructor(string _name, string _symbol) public payable {
        name = _name;
        symbol = _symbol;
        founder = msg.sender;
        active = false;
    }

    function answerOf() external view returns (uint8[7] balls) {
        balls = answer;
    }

    function open(address _currency, uint256 _deadline) public {
        require(!active);
        require(founder == msg.sender);
        require(_currency != address(this));
        require(_deadline >= COOLDOWN + now);
        require(now >= COOLDOWN + deadline);

        uint256 supply;
        if (_currency == address(0)) {
            supply = address(this).balance;
        } else {
            bytes memory data = abi.encodeWithSignature("balanceOf(address)", address(this));
            assembly {
                let result := call(90000, _currency, 0, add(data, 0x20), mload(data), 0, 0)
                let ptr := mload(0x40)
                let size := returndatasize
                returndatacopy(ptr, 0, size)

                if iszero(result) {
                    revert(ptr, size)
                }
                supply := mload(ptr)
            }
        }
        require(supply >= BONUSPOOL);

        delete answer;
        delete gamblers;
        bonusSupply = supply;
        deadline = _deadline;
        pool = _currency;
        active = true;
    }


    function lottery() public {
        require(active);
        require(msg.sender == founder);
        require(now >= deadline);
        uint256 i;
        for (i = 0; i < MAXBALL; i++) {
            if (i < RADIX) {
                answer[i] = _randBall(blockhash(block.number - i), MAXRED);
            } else {
                answer[i] = _randBall(blockhash(block.number - i), MAXBLUE);
            }
        }

        uint256[] memory superWinners = new uint256[](gamblers.length);
        (uint256 bonusAmount, uint256 remaining) = (0, 0);
        (uint8 tops, uint8 secs, uint8 j) = (0, 0, 0);
        for (i = 0; i < gamblers.length; i++) {
            Gambler storage gambler = gamblers[i];
            (uint8 level, uint256 bonus) = _evalvel(gambler);
            gambler.bonusLevel = level;
            gambler.bonus = bonus;
            if (level > 2) {
                bonusAmount += bonus;
            } else if (level > 0) {
                superWinners[j] = i;
                j++;
                if (level == 1) {
                    tops++;
                } else {
                    secs++;
                }
            }
        }
        require(bonusSupply > bonusAmount);
        remaining = bonusSupply - bonusAmount;
        uint256 topBonus = remaining * 7 / 10;
        uint256 secBonus = remaining - topBonus;
        for (i = 0; i < superWinners.length; i++) {
            Gambler storage gambler = gamblers[superWinners[i]];
            if (gambler.bonusLevel == 1) {
                gambler.bonus *= (topBonus / tops);
            } else {
                gambler.bonus *= (secBonus / secs);
            }
        }

        deadline = now;
        active = false;
        assert(answer.length == MAXBALL);
    }

    function enter(uint8[] _reds, uint8[] _blues) public payable {
        require(active);
        require(now < deadline);
        require(_reds.length >= RADIX && _blues.length >= 1);
        require(_reds.length <= MAXRED && _blues.length <= MAXBLUE);
        uint256 stake = _evalStake(uint8(_reds.length), uint8(_blues.length));
        if (pool == address(0)) {
            require(msg.value >= stake);
        } else {
            bytes4 signature = bytes4(keccak256("transferFrom(address,address,uint256)"));
            require(pool.call.gas(90000)(signature, msg.sender, address(this), stake));
        }

        bool[MAXRED] memory reds;
        bool[MAXBLUE] memory blues;
        for (uint8 i = 0; i <= _reds.length; i++) {
            reds[_reds[i]] = true;
        }
        for (uint8 i = 0; i <= _blues.length; i++) {
            blues[_blues[i]] = true;
        }
        Gambler memory gambler = Gambler(msg.sender, reds, blues, 0, 0);
        gamblers.push(gambler);
        bonusSupply += stake;
    }

    function takePrize() public returns (bool) {
        require(!active);
        require(now < deadline + COOLDOWN);
        for (uint256 i = 0; i < gamblers.length; i++) {
            Gambler memory gambler = gamblers[i];
            if (gambler.addr == msg.sender) {
                delete gamblers[i];
                //                (uint8 level, uint256 bonus) = _evalvel(gambler);
                //                if (level == 0) {
                //                    return false;
                //                } else {
                //                    _takePrize(gambler.addr, bonus);
                //                    return true;
                //                }
            }
        }
        return false;
    }

    function _takePrize(address _winner, uint256 _bonus) private {
        if (pool == address(0)) {
            require(address(this).balance >= _bonus);
            _winner.transfer(_bonus);
        } else {
            bytes4 signature = bytes4(keccak256("transfer(address,uint256)"));
            require(pool.call.gas(gasleft())(signature, _winner, _bonus));
        }
    }

    function _evalvel(Gambler storage _gambler) private constant returns (uint8 level, uint256 bonus) {
        (uint8 reds, uint8 blues) = (0, 0);
        for (uint8 i = 0; i < MAXBALL; i++) {
            if (i < RADIX) {
                if (_gambler.reds[answer[i]]) {
                    reds += 1;
                }
            } else {
                if (_gambler.reds[answer[i]]) {
                    blues += 1;
                }
            }
        }
        uint8 stake = reds + blues;
        if (stake == MAXBALL) {
            level = 1;
        } else if (stake == MAXBALL - 1) {
            if (blues == 0) {
                level = 2;
            } else {
                level = 3;
            }
        } else if (stake == MAXBALL - 2) {
            level = 4;
        } else if (stake == MAXBALL - 3) {
            level = 5;
        } else if (blues > 0) {
            level = 6;
        }
        bonus = level > 0 ? stake * bonusPool[level - 1] : 0;
    }

    function _evalStake(uint8 _reds, uint8 _blues) private pure returns (uint256) {
        return _fact(_reds) / _fact(RADIX) / _fact(_reds - RADIX) * _blues * PRICE;
    }

    function _fact(uint8 n) private pure returns (uint256 ret) {
        for (; n > 0; n--) {
            ret *= n;
        }
    }

    // DISCLAIMER: This is pretty random... but not truly random.
    function _randBall(bytes32 _hash, uint8 _r) private constant returns (uint8) {
        bytes memory b = abi.encodePacked(block.difficulty, block.coinbase, now, _hash);
        return uint8(uint256(keccak256(b)) % _r) + 1;
    }
}
