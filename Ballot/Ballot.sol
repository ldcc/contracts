//pragma experimental ABIEncoderV2;
pragma solidity ^0.4.25;

contract Ballot {

    struct Proposal {
        uint8 index;
        bytes16 name;
        bytes32 desc;
        uint256 supporters;
    }

    // uint256 saving the number of votes held per voter
    mapping(address => uint256) public voters;

    string public name;
    address public author;
    uint256 public totalSupply;
    uint256 public totalVotes;
    uint256 public startTime;
    uint256 public endTime;
    Proposal[] public proposals;

    // solhint-disable-next-line no-simple-event-func-name
    event Closed(uint256 timestamp);
    event Poll(address indexed voter, uint8 indexed vote);


    // main code

    constructor(string _name, uint256 _totalSupply, bytes8[] _names, bytes32[] _descs) public payable {
        require(_names.length > 1);
        require(_names.length == _descs.length);
        name = _name;
        author = msg.sender;
        totalSupply = _totalSupply;
        startTime = block.timestamp;
        voters[msg.sender] = _totalSupply;
        for (uint8 i = 0; i < _names.length; i++) {
            proposals.push(Proposal({
                index : i + 1,
                name : _names[i],
                desc : _descs[i],
                supporters : 0}));
        }
        opened();
    }

    function poll(uint8 _vote) public {
        // Voter storage voter = voters[msg.sender];
        require(totalVotes < totalSupply);
        require(_vote > 0 && _vote <= proposals.length);
        require(voters[msg.sender] > 0);
        totalVotes++;
        voters[msg.sender]--;
        proposals[_vote - 1].supporters++;
        emit Poll(msg.sender, _vote);
    }

    function closed() public payable {
        require(msg.sender == author);
        endTime = block.timestamp;
        emit Closed(endTime);
        selfdestruct(author);
    }

    function distribute(address _recipient, uint256 _value) public {
        require(voters[msg.sender] >= _value);
        uint256 recHolds = voters[_recipient];
        voters[msg.sender] -= _value;
        voters[_recipient] += _value;
        assert(voters[_recipient] > recHolds);
    }

    function distributes(address[] _licensees, uint256[] _values) public {
        require(_licensees.length == _values.length);
        for (uint256 i = 0; i < _licensees.length; i++) {
            distribute(_licensees[i], _values[i]);
        }
    }

}
