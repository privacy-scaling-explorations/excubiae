// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721Policy} from "./BaseERC721Policy.sol";

/// @title BaseVoting.
/// @notice Simple voting system with NFT-based access control.
/// @dev Implements basic voting functionality with two phases:
///      1. Registration: Validates NFT ownership.
///      2. Voting: Records validated votes.
contract BaseVoting {
    /// @notice Emitted on successful registration/voting.
    event Registered(address voter);
    event Voted(address voter, uint8 option);

    /// @notice System error conditions.
    error NotRegistered();
    error AlreadyVoted();
    error InvalidOption();

    /// @notice Policy contract for NFT validation.
    BaseERC721Policy public immutable POLICY;

    /// @dev Maps voter address => voting status.
    mapping(address => bool) public hasVoted;
    /// @dev Maps option ID => vote count.
    mapping(uint8 => uint256) public voteCounts;

    /// @notice Sets up voting system.
    /// @param _policy Contract for voter validation.
    constructor(BaseERC721Policy _policy) {
        POLICY = _policy;
    }

    /// @notice Register using NFT ownership proof.
    /// @dev Enforces NFT ownership check through policy.
    /// @param tokenId NFT used for registration.
    /// @custom:requirements Caller must own the NFT with tokenId.
    /// @custom:emits Registered on successful registration.
    function register(uint256 tokenId) external {
        // Encode token ID for policy verification.
        bytes memory evidence = abi.encode(tokenId);

        // Verify NFT ownership.
        POLICY.enforce(msg.sender, evidence);

        emit Registered(msg.sender);
    }

    /// @notice Cast vote after registration.
    /// @dev Updates vote counts if validation passes.
    /// @param option Vote choice (0 or 1).
    /// @custom:requirements
    /// - Caller must be registered.
    /// - Caller must not have voted.
    /// - Option must be valid (0 or 1).
    /// @custom:emits Voted on successful vote cast.
    function vote(uint8 option) external {
        // Verify registration and voting status.
        if (!POLICY.enforced(address(this), msg.sender)) revert NotRegistered();
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (option >= 2) revert InvalidOption();

        // Record vote.
        hasVoted[msg.sender] = true;
        voteCounts[option]++;

        emit Voted(msg.sender, option);
    }
}
