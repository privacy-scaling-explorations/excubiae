// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Checker} from "../core/Checker.sol";

/// @title FreeForAll Checker Contract.
/// @notice This contract extends the `Checker` contract to implement the checks & allow free access through the `gate`.
contract FreeForAllChecker is Checker {
    /// @notice Constructor for the FreeForAllChecker contract.
    constructor() {}

    /// @notice Check if the passerby can pass the pre-check.
    /// @param passerby The address of the entity attempting to pass the pre-check.
    function _checkPre(address passerby, bytes memory data) internal view override {
        // Always allow passing the pre-check
    }

    /// @notice Check if the passerby can pass the main check.
    /// @param passerby The address of the entity attempting to pass the main check.
    function _checkMain(address passerby, bytes memory data) internal view override {
        // Always allow passing the main check
    }

    /// @notice Check if the passerby can pass the post-check.
    /// @param passerby The address of the entity attempting to pass the post-check.
    function _checkPost(address passerby, bytes memory data) internal view override {
        // Always allow passing the post-check
    }
}
