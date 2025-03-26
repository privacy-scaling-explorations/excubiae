// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BasePolicy} from "../../policy/BasePolicy.sol";
import {IHats} from "./IHats.sol";

/// @title HatsPolicy
/// @notice A policy contract enforcing Hats validation.
/// Only if they are wearing one of the specified hats
contract HatsPolicy is BasePolicy {
    /// @notice Tracks registered users
    mapping(address => bool) public registered;

    /// @notice Deploy an instance of HatsPolicy
    // solhint-disable-next-line no-empty-blocks
    constructor() payable {}

    /// @notice Registers the user
    /// @param subject The address of the user
    /// @param evidence additional data
    function _enforce(address subject, bytes calldata evidence) internal override {
        // subject must not be already registered
        if (registered[subject]) revert AlreadyEnforced();

        registered[subject] = true;

        super._enforce(subject, evidence);
    }

    /// @notice Get the trait of the Policy
    /// @return The type of the Policy
    function trait() public pure virtual override returns (string memory) {
        return "Hats";
    }
}
