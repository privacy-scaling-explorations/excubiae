// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title IBaseChecker.
/// @notice Defines base validation functionality.
interface IBaseChecker {
    /// @notice Validates subject against evidence.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return checked True if validation passes.
    function check(address subject, bytes calldata evidence) external view returns (bool checked);
}
