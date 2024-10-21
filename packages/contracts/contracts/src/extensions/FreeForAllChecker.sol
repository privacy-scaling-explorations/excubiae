// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Checker} from "../core/Checker.sol";

/// @title FreeForAll Checker Contract.
/// @notice This contract extends the `Checker` contract to implement the checks & allow free access through the `gate`.
/// @dev The contract overrides the `_check` function to always return true.
contract FreeForAllChecker is Checker {
    /// @notice Constructor for the FreeForAllChecker contract.
    constructor() {}

    /// @notice Internal function to handle the `gate` protection logic.
    /// @dev This function always returns true, signaling that any `passerby` is able to pass the `gate`.
    /// @param passerby The address of the entity attempting to pass the `gate`.
    /// @param data Additional data required for the check (e.g., encoded attestation ID).
    function _check(address passerby, bytes calldata data) internal view override {
        super._check(passerby, data);
    }
}
