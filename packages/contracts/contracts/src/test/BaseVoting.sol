// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseERC721Policy} from "./BaseERC721Policy.sol";

contract BaseVoting {
    event Registered(address voter);
    event Voted(address voter, uint8 option);

    error NotRegistered();
    error AlreadyVoted();
    error InvalidOption();

    BaseERC721Policy public immutable POLICY;

    // Mapping to track if an address has voted
    mapping(address => bool) public hasVoted;
    // Mapping to count votes for each option
    mapping(uint8 => uint256) public voteCounts;

    constructor(BaseERC721Policy _policy) {
        POLICY = _policy;
    }

    // Function to register a voter using a the policy enforcement.
    function register(uint256 tokenId) external {
        bytes memory evidence = abi.encode(tokenId);
        POLICY.enforce(msg.sender, evidence);

        emit Registered(msg.sender);
    }

    // Function to cast a vote for a given option.
    function vote(uint8 option) external {
        if (!POLICY.enforced(address(this), msg.sender)) revert NotRegistered();
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (option >= 2) revert InvalidOption();

        hasVoted[msg.sender] = true;
        voteCounts[option]++;

        emit Voted(msg.sender, option);
    }
}
