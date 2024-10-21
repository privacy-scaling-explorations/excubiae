// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title IChecker.
/// @notice Checker contract interface.
interface IChecker {
    /// @dev Defines the custom `gate` protection logic.
    /// @param passerby The address of the entity attempting to pass the `gate`.
    /// @param data Additional data that may be required for the check.
    function check(address passerby, bytes calldata data) external view;
}
