pragma solidity ^0.4.24;

contract chromosphere {

    uint8 private constant PRICE = 2;
    uint8 private constant RADIX = 6;
    uint8 private constant MAXRED = 33;
    uint8 private constant MAXBLUE = 16;
    uint8 private constant MAXBALL = 7;
    uint256 private constant COOLDOWN = 86400;
    uint256 private constant BOUNSPOOL = 5000000 ether;

    struct Gambler {
        address addr;
        bool[MAXRED] reds;
        bool[MAXBLUE] blues;
    }

    uint256 public deadline;
    address public founder;
    address public pool;
    string public name;
    string public symbol;
    bool private active;

    // index 0 and 1 is the percent of rewards amount pre bet
    // index 2-5 are fixed rewards pre bet
    uint256[6] private bonusPool;
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

        delete bonusPool;
        delete answer;
        delete gamblers;
        if (_currency == address(0)) {
            require(address(this).balance >= BOUNSPOOL);
        } else {
            require(_currency.call.gas(90000)(bytes4(keccak256("transferFrom")), msg.sender, address(this), BOUNSPOOL));
        }
        deadline = _deadline;
        pool = _currency;
        active = true;
    }


    function lottery() public {
        require(active);
        require(msg.sender == founder);
        require(now >= deadline);
        uint256 number = block.number;
        for (uint8 i = 0; i < MAXBALL; i++) {
            if (i < RADIX) {
                answer[i] = _randBall(blockhash(number - i), MAXRED);
            } else {
                answer[i] = _randBall(blockhash(number - i), MAXBLUE);
            }
        }
        // TODO get token balance
        uint256 bal = address(this).balance;
        for (uint256 i = 0; i < gamblers.length; i++) {
            Gambler memory gambler = gamblers[i];
            (uint8 level, uint256 bonus) = _evalvel(gambler, bal);
            if (level > 0) {
                bonusPool[level] += bonus;
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
            require(pool.call.gas(90000)(bytes4(keccak256("transferFrom")), msg.sender, address(this), stake));
        }

        bool[MAXRED] memory reds;
        bool[MAXBLUE] memory blues;
        for (uint8 i = 0; i <= _reds.length; i++) {
            reds[_reds[i]] = true;
        }
        for (uint8 i = 0; i <= _blues.length; i++) {
            blues[_blues[i]] = true;
        }
        Gambler memory gambler = Gambler(msg.sender, reds, blues);
        gamblers.push(gambler);
    }

    function takePrize() public returns (bool) {
        require(!active);
        require(now < deadline + COOLDOWN);
        uint256 bal;
        if (pool == address(0)) {
            bal = address(this).balance;
        } else {
            // TODO get token balance
            require(pool.call.value(0).gas(0)(bytes4(keccak256("balanceOf")), address(this)));
            assembly {
                returndatacopy(0x0, 0x0, returndatasize)
                return(0x0, returndatasize)
            }
        }
        for (uint256 i = 0; i < gamblers.length; i++) {
            Gambler memory gambler = gamblers[i];
            if (gambler.addr == msg.sender) {
                delete gamblers[i];
                (uint8 level, uint256 bonus) = _evalvel(gambler, bal);
                if (level == 0) {
                    return false;
                } else {
                    _takePrize(gambler.addr, bonus);
                    return true;
                }
            }
        }
        return false;
    }

    function _takePrize(address _winner, uint256 _bonus) private {
        if (pool == address(0)) {
            require(address(this).balance >= _bonus);
            _winner.transfer(_bonus);
        } else {
            require(pool.call.gas(90000)(bytes4(keccak256("transfer")), _winner, _bonus));
        }
    }

    function _evalvel(Gambler memory _gambler, uint256 bal) private constant returns (uint8, uint256) {
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
        return _evalBonus(reds, blues, bal);
    }

    function _evalBonus(uint8 _reds, uint8 _blues, uint256 bal) private pure returns (uint8, uint256) {
        uint8 stake = _reds + _blues;
        if (stake == MAXBALL) {
            return (1, bal * 7 / 10);
        } else if (stake == MAXBALL - 1) {
            if (_blues == 0) {
                return (2, bal * 3 / 10);
            } else {
                return (3, stake * 3000);
            }
        } else if (stake == MAXBALL - 2) {
            return (4, stake * 200);
        } else if (stake == MAXBALL - 3) {
            return (5, stake * 10);
        } else if (_blues > 0) {
            return (6, stake * 5);
        } else {
            return (0, 0);
        }
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
