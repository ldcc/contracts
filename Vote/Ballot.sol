//pragma experimental ABIEncoderV2;
pragma solidity ^0.4.21;

contract Ballot {

    struct Voter {
        uint256 ticket;
        mapping(uint8 => uint8) votes;
    }

    struct Proposal {
        uint8 vote;
        bytes16 name;
        bytes32 desc;
        uint256 supporters;
    }

    mapping(address => Voter) public voters;

    bool public status;
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

    constructor(string _name, uint256 _totalSupply, bytes8[] _names, bytes32[] _descs) public payable {
        require(_names.length > 1);
        require(_names.length == _descs.length);
        name = _name;
        author = msg.sender;
        totalSupply = _totalSupply;
        voters[msg.sender].ticket = _totalSupply;
        for (uint8 i = 0; i < _names.length; i++) {
            proposals.push(Proposal({
                vote : i + 1,
                name : _names[i],
                desc : _descs[i],
                supporters : 0}));
        }
    }

    function poll(uint8 _vote) public {
        require(status);
        require(totalVotes < totalSupply);
        require(_vote > 0 && _vote <= proposals.length);
        Voter storage voter = voters[msg.sender];
        require(voter.ticket > 0);

        totalVotes++;
        voter.ticket--;
        voter.votes[_vote]++;
        voters[msg.sender] = voter;
        proposals[_vote - 1].supporters++;

        emit Poll(msg.sender, _vote);
    }

    function opened() public {
        require(!status);
        status = true;
        startTime = block.timestamp;
        emit Opened(startTime);
    }

    function closed() public payable {
        status = false;
        endTime = block.timestamp;
        emit Closed(endTime);
        selfdestruct(author);
    }

}
