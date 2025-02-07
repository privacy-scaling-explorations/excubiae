// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {BasePolicy} from "../policy/BasePolicy.sol";

/// @title SemaphorePolicy
/// @notice Policy contract enforcing Semaphore group membership validation.
/// @dev Extends BasePolicy to add logic for tracking and preventing nullifier reuse, ensuring one-time proof validity.
contract SemaphorePolicy is BasePolicy {
    /// @notice Mapping to track spent nullifiers for each validated proof.
    mapping(uint256 => bool) public spentNullifiers;

    /// @notice Error thrown when a proof is submitted with an already spent nullifier.
    error AlreadySpentNullifier();

    /// @notice Returns the policy trait identifier.
    /// @dev Identifies the policy as a Semaphore-based validation mechanism.
    /// @return The trait identifier string "Semaphore".
    function trait() external pure returns (string memory) {
        return "Semaphore";
    }

    /// @notice Internal enforcement logic to validate proofs and track nullifier usage.
    /// @dev Decodes the Semaphore proof from evidence and ensures the nullifier hasn't been previously used.
    /// @param subject Address of the entity being validated.
    /// @param evidence Encoded Semaphore proof data.
    function _enforce(address subject, bytes calldata evidence) internal override {
        ISemaphore.SemaphoreProof memory proof = abi.decode(evidence, (ISemaphore.SemaphoreProof));
        uint256 _nullifier = proof.nullifier;

        if (spentNullifiers[_nullifier]) revert AlreadySpentNullifier();

        spentNullifiers[_nullifier] = true;

        super._enforce(subject, evidence);
    }
}
