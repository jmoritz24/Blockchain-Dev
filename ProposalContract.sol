// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address owner;
    uint256 private counter;
    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    mapping(uint256 => Proposal) proposal_history;
    mapping(uint256 => mapping(address => bool)) private hasVoted;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active, "The proposal is not active");
        _;
    }

    modifier newVoter() {
        require(msg.sender != owner, "The owner cannot vote");
        require(!hasVoted[counter][msg.sender], "Address has already voted");
        _;
    }

    function setOwner(address new_owner) external onlyOwner {
        require(new_owner != address(0), "Invalid owner address");
        owner = new_owner;
    }

    function create(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal({
            title: _title,
            description: _description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _total_vote_to_end,
            current_state: false,
            is_active: _total_vote_to_end > 0
        });
    }

    function vote(uint8 choice) external active newVoter {
        Proposal storage proposal = proposal_history[counter];

        if (choice == 1) {
            proposal.approve += 1;
        } else if (choice == 2) {
            proposal.reject += 1;
        } else if (choice == 0) {
            proposal.pass += 1;
        } else {
            revert("Invalid vote choice");
        }

        hasVoted[counter][msg.sender] = true;
        proposal.current_state = calculateCurrentState(proposal);

        uint256 totalVotes = proposal.approve + proposal.reject + proposal.pass;
        if (totalVotes == proposal.total_vote_to_end) {
            proposal.is_active = false;
        }
    }

    function terminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }

    function isVoted(address voter) public view returns (bool) {
        return hasVoted[counter][voter];
    }

    function getCurrentProposal() external view returns (Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns (Proposal memory) {
        return proposal_history[number];
    }

    function calculateCurrentState(Proposal storage proposal) private view returns (bool) {
        return proposal.approve > proposal.reject;
    }
}
