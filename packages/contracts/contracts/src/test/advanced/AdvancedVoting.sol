// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedPolicy} from "../../AdvancedPolicy.sol";
import {Check} from "../../interfaces/IAdvancedPolicy.sol";

/// @title AdvancedVoting.
/// @notice Multi-phase voting system with NFT validation and rewards.
/// @dev Implements a three-phase voting process:
///      1. Registration (PRE): Validates initial NFT ownership.
///      2. Voting (MAIN): Validates voting power and records vote.
///      3. Rewards (POST): Validates and distributes NFT rewards.
contract AdvancedVoting {
    /// @notice Events for tracking system state changes.
    event Registered(address voter);
    event Voted(address voter, uint8 option);
    event RewardClaimed(address voter, uint256 rewardId);

    /// @notice System error conditions.
    error NotRegistered();
    error NotVoted();
    error AlreadyClaimed();
    error InvalidOption();
    error NotOwnerOfReward();

    /// @notice Policy contract for validation checks.
    AdvancedPolicy public immutable POLICY;

    /// @notice Tracks total votes per option.
    /// @dev Maps option ID => vote count.
    mapping(uint8 => uint256) public voteCounts;

    /// @notice Sets up voting system with policy contract.
    /// @param _policy Contract handling validation logic.
    constructor(AdvancedPolicy _policy) {
        POLICY = _policy;
    }

    /// @notice First phase - Register voter with NFT ownership proof.
    /// @dev Enforces PRE check through policy contract.
    /// @param tokenId NFT used for registration.
    /// @custom:requirements Caller must own the NFT with tokenId.
    /// @custom:emits Registered on successful registration.
    function register(uint256 tokenId) external {
        // Encode token ID for policy verification.
        bytes memory evidence = abi.encode(tokenId);

        // Verify NFT ownership through policy's PRE check.
        POLICY.enforce(msg.sender, evidence, Check.PRE);

        emit Registered(msg.sender);
    }

    /// @notice Second phase - Cast vote after registration.
    /// @dev Enforces MAIN check and updates vote counts.
    /// @param option Vote choice (0 or 1).
    /// @custom:requirements
    /// - Caller must be registered (passed PRE check).
    /// - Option must be valid (0 or 1).
    /// @custom:emits Voted on successful vote cast.
    function vote(uint8 option) external {
        // Check registration status (PRE check completion).
        (bool pre, , ) = POLICY.enforced(address(this), msg.sender);

        if (!pre) revert NotRegistered();
        if (option >= 2) revert InvalidOption();

        // Verify voting power through policy's MAIN check.
        bytes memory evidence = abi.encode(option);
        POLICY.enforce(msg.sender, evidence, Check.MAIN);

        // Increment vote count safely.
        unchecked {
            voteCounts[option]++;
        }

        emit Voted(msg.sender, option);
    }

    /// @notice Final phase - Claim NFT reward after voting.
    /// @dev Enforces POST check for reward distribution.
    /// @param rewardId Identifier of NFT reward to claim.
    /// @custom:requirements
    /// - Caller must be registered (passed PRE check).
    /// - Caller must have voted (passed MAIN check).
    /// - Caller must not have claimed before (no POST check).
    /// @custom:emits RewardClaimed on successful claim.
    function reward(uint256 rewardId) external {
        // Verify completion of previous phases.
        (bool pre, uint8 main, bool post) = POLICY.enforced(address(this), msg.sender);

        if (!pre) revert NotRegistered();
        if (main == 0) revert NotVoted();
        if (post) revert AlreadyClaimed();

        // Verify reward eligibility through policy's POST check.
        bytes memory evidence = abi.encode(rewardId);
        POLICY.enforce(msg.sender, evidence, Check.POST);

        emit RewardClaimed(msg.sender, rewardId);
    }
}
