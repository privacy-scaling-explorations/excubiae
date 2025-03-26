// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BasePolicy} from "../../policy/BasePolicy.sol";
import {IGitcoinPassportDecoder} from "./IGitcoinPassportDecoder.sol";

/// @title GitcoinPassportPolicy
/// @notice A policy contract enforcing gitcoin validation.
/// Only if they've received an attestation of a specific schema from a trusted attester
contract GitcoinPassportPolicy is BasePolicy {
    // a mapping of attestations that have already registered
    mapping(address => bool) public enforcedUsers;

    /// @notice Deploy an instance of GitcoinPassportPolicy
    // solhint-disable-next-line no-empty-blocks
    constructor() payable {}

    /// @notice Register an user based on their attestation
    /// @dev Throw if the attestation is not valid or just complete silently
    /// @param subject The user's Ethereum address.
    /// @param evidence The ABI-encoded schemaId as a uint256.
    function _enforce(address subject, bytes calldata evidence) internal override {
        // ensure that the user has not been registered yet
        if (enforcedUsers[subject]) revert AlreadyEnforced();

        // register the user so it cannot register again
        enforcedUsers[subject] = true;

        super._enforce(subject, evidence);
    }

    /// @notice Get the trait of the Policy
    /// @return The type of the Policy
    function trait() public pure override returns (string memory) {
        return "GitcoinPassport";
    }
}
