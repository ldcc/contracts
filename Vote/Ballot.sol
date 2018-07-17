//pragma experimental ABIEncoderV2;
pragma solidity ^0.4.21;

contract Ballot {

    struct Voter {
        bool voted;
        uint8 vote;
    }

    struct Proposal {
        uint8 vote;
        bytes32 name;
        bytes32 desc;
        uint256 supporters;
    }

    mapping(address => Voter) public voters;

    bool public state;
    string public name;
    address public author;
    uint256 public totalSupply;
    uint256 public totalVotes;
    uint256 public startTime;
    uint256 public endTime;
    Proposal[] public proposals;

    // solhint-disable-next-line no-simple-event-func-name
    event Opened(uint256 timestamp);
    event Closed(uint256 timestamp);
    event Poll(address indexed voter, uint8 indexed choice);


    // main code

    constructor(string _name, uint256 _totalSupply, bytes32[] _names, bytes32[] _descs) public payable {
        require(_names.length > 1);
        require(_names.length == _descs.length);
        name = _name;
        author = msg.sender;
        totalSupply = _totalSupply;
        for (uint8 i = 0; i < _names.length; i++) {
            proposals.push(Proposal({
                vote : i + 1,
                name : _names[i],
                desc : _descs[i],
                supporters : 0}));
        }
    }

    function poll(uint8 _vote) public returns (bool success) {
        require(state);
        require(totalVotes < totalSupply);
        require(_vote > 0, "Vote should be better than zero.");
        require(_vote <= proposals.length, "Vote should be lower than proposals length.");
        Voter storage voter = voters[msg.sender];
        require(!voter.voted, "Already voted");

        voter.voted = true;
        voter.vote = _vote;
        proposals[_vote - 1].supporters++;
        totalVotes++;
        voters[msg.sender] = voter;
        emit Poll(msg.sender, _vote);
        if (totalVotes == totalSupply) {
            closed();
        }
        return true;
    }

    function opened() public {
        state = true;
        startTime = block.timestamp;
        emit Opened(startTime);
    }

    function closed() public payable {
        state = false;
        endTime = block.timestamp;
        emit Closed(endTime);
        selfdestruct(author);
    }
}
