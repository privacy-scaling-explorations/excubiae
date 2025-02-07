// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {BasePolicy} from "../policy/BasePolicy.sol";

/// @title SemaphorePolicy
/// @notice Policy contract enforcing proof of membership of Semaphore group validation.
/// @dev Extends BasePolicy to add specific behavior for Semaphore proof of membership validation.
contract SemaphorePolicy is BasePolicy {
    /// @notice Tracks nullifier spent for each valid proof / check.
    mapping(uint256 => bool) public spentNullifiers;

    /// @notice Error thrown when the subject sends a proof with an already spent nullifier.
    error AlreadySpentNullifier();

    /// @notice Returns a trait identifier for the policy.
    /// @dev Used to identify the policy type.
    /// @return The trait string "Semaphore".
    function trait() external pure returns (string memory) {
        return "Semaphore";
    }

    /// @notice Internal logic for enforcing checks.
    /// @param subject Address to enforce the policy on.
    /// @param evidence Custom validation data.
    function _enforce(address subject, bytes calldata evidence) internal override {
        ISemaphore.SemaphoreProof memory proof = abi.decode(evidence, (ISemaphore.SemaphoreProof));
        uint256 _nullifier = proof.nullifier;

        if (spentNullifiers[_nullifier]) revert AlreadySpentNullifier();

        spentNullifiers[_nullifier] = true;

        super._enforce(subject, evidence);
    }
}
