// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    uint256 private counter; // This line is added
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

    function create(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external {
        counter += 1;
        proposal_history[counter] = Proposal({
            title: _title,
            description: _description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _total_vote_to_end,
            current_state: false,
            is_active: true
        });
    }
}
