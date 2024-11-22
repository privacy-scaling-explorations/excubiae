// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title IBaseChecker
/// @notice BaseChecker contract interface that defines the basic check functionality.
interface IBaseChecker {
    /// @dev Defines the custom `gate` protection logic.
    /// @param passerby The address of the entity attempting to pass the `gate`.
    /// @return checked A boolean that resolves to true when the passerby satisfies the checks; otherwise false.
    function check(address passerby, bytes calldata data) external view returns (bool checked);
}
