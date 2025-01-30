// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedPolicy} from "../../core/policy/AdvancedPolicy.sol";
import {Check} from "../../core/interfaces/IAdvancedPolicy.sol";

/// @title AdvancedVoting
/// @notice Multi-phase governance system with NFT-based validation.
/// @dev Combines pre, main, and post phases for registration, voting, and eligibility verification.
contract AdvancedVoting {
    /// @notice Emitted when a voter registers successfully.
    /// @param voter Address of the voter who registered.
    event Registered(address voter);

    /// @notice Emitted when a vote is cast successfully.
    /// @param voter Address of the voter who cast their vote.
    /// @param option The chosen voting option (0 or 1).
    event Voted(address voter, uint8 option);

    /// @notice Emitted when a voter is deemed eligible.
    /// @param voter Address of the voter who met eligibility criteria.
    event Eligible(address voter);

    /// @notice Error thrown when a user attempts an action without registering first.
    error NotRegistered();

    /// @notice Error thrown when a user attempts to verify eligibility without voting.
    error NotVoted();

    /// @notice Error thrown when a user tries to verify eligibility more than once.
    error AlreadyEligible();

    /// @notice Error thrown when an invalid voting option is provided.
    error InvalidOption();

    /// @notice Error thrown when a user does not meet the eligibility criteria.
    error NotEligible();

    /// @notice Reference to the policy contract enforcing multi-phase validation.
    AdvancedPolicy public immutable POLICY;

    /// @notice Tracks the vote count for each option (0 or 1).
    mapping(uint8 => uint256) public voteCounts;

    /// @notice Constructor to set the policy contract.
    /// @param _policy Address of the AdvancedPolicy contract to use for validation.
    constructor(AdvancedPolicy _policy) {
        POLICY = _policy;
    }

    /// @notice Registers a user for voting by validating their NFT ownership.
    /// @dev Enforces the pre-check phase using the AdvancedPolicy contract.
    /// @param tokenId The ID of the NFT used to verify registration eligibility.
    function register(uint256 tokenId) external {
        // Prepare evidence with the tokenId encoded as bytes.
        bytes[] memory _evidence = new bytes[](1);
        _evidence[0] = abi.encode(tokenId);

        // Enforce the pre-check phase using the provided policy.
        POLICY.enforce(msg.sender, _evidence, Check.PRE);

        // Emit an event to log the registration.
        emit Registered(msg.sender);
    }

    /// @notice Allows a registered user to cast their vote.
    /// @dev Enforces the main-check phase and updates the vote count.
    /// @param option The chosen voting option (0 or 1).
    function vote(uint8 option) external {
        // Retrieve the enforcement status of the sender from the policy.
        (bool pre, , ) = POLICY.enforced(msg.sender);

        // Ensure the user has registered before voting.
        if (!pre) revert NotRegistered();

        // Validate that the voting option is within the allowed range.
        if (option >= 2) revert InvalidOption();

        // Prepare evidence with the chosen option encoded as bytes.
        bytes[] memory _evidence = new bytes[](1);
        _evidence[0] = abi.encode(option);

        // Enforce the main-check phase using the policy.
        POLICY.enforce(msg.sender, _evidence, Check.MAIN);

        // Increment the vote count for the chosen option.
        unchecked {
            voteCounts[option]++;
        }

        // Emit an event to log the voting action.
        emit Voted(msg.sender, option);
    }

    /// @notice Verifies a user's eligibility after voting has concluded.
    /// @dev Enforces the post-check phase to ensure eligibility criteria are met.
    function eligible() external {
        // Retrieve the enforcement status for all phases.
        (bool pre, uint8 main, bool post) = POLICY.enforced(msg.sender);

        // Ensure the user has completed the registration phase.
        if (!pre) revert NotRegistered();

        // Ensure the user has cast at least one vote.
        if (main == 0) revert NotVoted();

        // Ensure the user has not already been marked as eligible.
        if (post) revert AlreadyEligible();

        // Enforce the post-check phase using the policy.
        POLICY.enforce(msg.sender, new bytes[](1), Check.POST);

        // Emit an event to log the eligibility status.
        emit Eligible(msg.sender);
    }
}
