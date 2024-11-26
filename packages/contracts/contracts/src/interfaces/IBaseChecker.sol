// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title IBaseChecker
/// @notice BaseChecker contract interface that defines the basic check functionality.
interface IBaseChecker {
    /// @dev Defines the custom `target` protection logic.
    /// @param subject The address of the entity attempting to the `target`.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    /// @return checked A boolean that resolves to true when the subject satisfies the checks; otherwise false.
    function check(address subject, bytes calldata evidence) external view returns (bool checked);
}
