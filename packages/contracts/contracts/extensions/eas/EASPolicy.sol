// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BasePolicy} from "../../policy/BasePolicy.sol";

/// @title EASPolicy
/// @notice A policy contract enforcing EAS validation.
/// Only if they've received an attestation of a specific schema from a trusted attester
contract EASPolicy is BasePolicy {
    // a mapping of attestations that have already registered
    mapping(bytes32 => bool) public registeredAttestations;

    /// @notice Deploy an instance of EASPolicy
    // solhint-disable-next-line no-empty-blocks
    constructor() payable {}

    /// @notice Register an user based on their attestation
    /// @dev Throw if the attestation is not valid or just complete silently
    /// @param subject The user's Ethereum address.
    /// @param evidence The ABI-encoded schemaId as a uint256.
    function _enforce(address subject, bytes calldata evidence) internal override {
        // decode the argument
        bytes32 attestationId = abi.decode(evidence, (bytes32));

        // ensure that the attestation has not been registered yet
        if (registeredAttestations[attestationId]) {
            revert AlreadyEnforced();
        }

        // register the attestation so it cannot be called again with the same one
        registeredAttestations[attestationId] = true;

        super._enforce(subject, evidence);
    }

    /// @notice Get the trait of the Policy
    /// @return The type of the Policy
    function trait() public pure override returns (string memory) {
        return "EAS";
    }
}
