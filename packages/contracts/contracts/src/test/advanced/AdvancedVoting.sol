// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedPolicy} from "../../AdvancedPolicy.sol";
import {Check} from "../../interfaces/IAdvancedPolicy.sol";

/// @title AdvancedVoting.
/// @notice Advanced voting system with NFT-based phases and eligibility verification.
/// @dev Implements a three-phase governance process using NFT validation:
///      1. Registration: Validates ownership of signup NFT (under-the-hood uses the BaseERC721Checker).
///      2. Voting: Validates token balances and records votes (single token = single vote).
///      3. Eligibility: Validates criteria for governance participation benefits.
contract AdvancedVoting {
    /// @notice Emitted on successful phase completion.
    /// @param voter Address that completed the phase.
    event Registered(address voter);
    /// @param option Selected voting option (0 or 1).
    event Voted(address voter, uint8 option);
    /// @param voter Address that met eligibility criteria.
    event Eligible(address voter);

    /// @notice Validation error states.
    /// @dev Thrown when phase requirements not met.
    error NotRegistered(); // Pre-check (registration) not completed.
    error NotVoted(); // Main check (voting) not completed.
    error AlreadyEligible(); // Post check (eligibility) already verified.
    error InvalidOption(); // Vote option out of valid range.
    error NotEligible(); // Eligibility criteria not met.

    /// @notice Policy contract managing multi-phase validation.
    /// @dev Handles all NFT-based checks through aggregated verifiers.
    AdvancedPolicy public immutable POLICY;

    /// @notice Vote tracking per option.
    /// @dev Maps option ID (0 or 1) to total votes received.
    mapping(uint8 => uint256) public voteCounts;

    /// @notice Initializes voting system.
    /// @param _policy Advanced policy contract with configured verifiers.
    constructor(AdvancedPolicy _policy) {
        POLICY = _policy;
    }

    /// @notice Registration phase handler.
    /// @dev Validates signup NFT ownership using BaseERC721Checker.
    /// @param tokenId ID of the signup NFT to validate.
    /// @custom:requirements
    /// - Token must exist.
    /// - Caller must be token owner.
    /// - Token ID must be within valid range.
    /// @custom:emits Registered when registration succeeds.
    function register(uint256 tokenId) external {
        bytes[] memory _evidence = new bytes[](1);
        _evidence[0] = abi.encode(tokenId);

        POLICY.enforce(msg.sender, _evidence, Check.PRE);

        emit Registered(msg.sender);
    }

    /// @notice Voting phase handler.
    /// @dev Validates voting power and records vote choice.
    /// @param option Binary choice (0 or 1).
    /// @custom:requirements
    /// - Registration must be completed.
    /// - Option must be valid (0 or 1).
    /// - Token balance must meet requirements.
    /// @custom:emits Voted when vote is recorded.
    function vote(uint8 option) external {
        (bool pre, , ) = POLICY.enforced(msg.sender);
        if (!pre) revert NotRegistered();
        if (option >= 2) revert InvalidOption();

        bytes[] memory _evidence = new bytes[](1);
        _evidence[0] = abi.encode(option);

        POLICY.enforce(msg.sender, _evidence, Check.MAIN);

        unchecked {
            voteCounts[option]++;
        }

        emit Voted(msg.sender, option);
    }

    /// @notice Eligibility verification phase.
    /// @dev Validates completion of governance process and checks eligibility criteria.
    /// @custom:requirements
    /// - Caller must be registered (passed PRE check).
    /// - Caller must have voted (passed MAIN check).
    /// - Caller must not be already verified (no POST check).
    /// - Caller must meet eligibility criteria (no existing benefits).
    /// @custom:emits Eligible when verification succeeds.
    function eligible() external {
        (bool pre, uint8 main, bool post) = POLICY.enforced(msg.sender);

        if (!pre) revert NotRegistered();
        if (main == 0) revert NotVoted();
        if (post) revert AlreadyEligible();

        POLICY.enforce(msg.sender, new bytes[](1), Check.POST);

        emit Eligible(msg.sender);
    }
}
