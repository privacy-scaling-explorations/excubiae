// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IBaseChecker
/// @notice Interface defining base validation functionality for policies.
/// @dev Contracts implementing this interface must define the `check` method.
interface IBaseChecker {
    /// @notice Validates a subject against provided evidence.
    /// @param subject The address to validate.
    /// @param evidence An array of custom validation data.
    /// @return checked Boolean indicating whether the validation passed.
    function check(address subject, bytes[] calldata evidence) external view returns (bool checked);
}
