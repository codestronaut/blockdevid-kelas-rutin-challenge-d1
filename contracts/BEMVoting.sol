// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract BEMVoting {
    struct Candidate {
        string name;
        string vision;
        uint256 votes;
    }
    
    Candidate[] public candidates;
    mapping(address => bool) public hasChosen;
    mapping(address => bool) public registeredVoter;
    
    uint256 public timeStart;
    uint256 public timeEnd;
    address public admin;
    
    event VoteCasted(address indexed voter, uint256 candidateIndex);
    event CandidateAdded(string name);

    constructor() {
        admin = msg.sender;
    }
    
    modifier onlyDuringVoting() {
        require(
            block.timestamp >= timeStart && 
            block.timestamp <= timeEnd, 
            "Voting has not started or has finished."
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Admin only privilege.");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(registeredVoter[msg.sender], "Voters only privilege.");
        _;
    }

    function registerVoter() public  {
        require(!registeredVoter[msg.sender], "Voter already registered");
        registeredVoter[msg.sender] = true;
        hasChosen[msg.sender] = false;
    }
    
    function addCandidate(string memory _name, string memory _vision) public onlyAdmin {
        require(bytes(_name).length > 0, "Name should not be empty.");

        candidates.push(Candidate({name: _name, vision: _vision, votes: 0}));
        emit CandidateAdded(_name);
    }

    function startVotingSession() public onlyAdmin {
        require(candidates.length > 0, "No candidates to vote");
        timeStart = block.timestamp;
    }

    function vote(uint256 _candidateIndex) public onlyRegisteredVoter onlyDuringVoting {
        require(!hasChosen[msg.sender], "Voter have chosen.");
        require(_candidateIndex < candidates.length, "Candidate not found.");

        candidates[_candidateIndex].votes += 1;
        hasChosen[msg.sender] = true;

        emit VoteCasted(msg.sender, _candidateIndex);
    }

    function stopVotingSession() public onlyAdmin {
        timeEnd = block.timestamp;
    }

    function getResults() public view returns(Candidate[] memory) {
        return candidates;
    }
}