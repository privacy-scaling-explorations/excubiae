// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title Check.
/// @notice Defines validation phases in the AdvancedChecker system.
/// @custom:values PRE - Pre-condition validation.
///                MAIN - Primary validation.
///                POST - Post-condition validation.
enum Check {
    PRE,
    MAIN,
    POST
}

/// @title IAdvancedChecker.
/// @notice Defines multi-phase validation system interface.
/// @dev Implement this for custom validation logic with pre/main/post checks.
interface IAdvancedChecker {
    /// @notice Thrown when pre-check validation attempted while skipped.
    error CannotPreCheckWhenSkipped();

    /// @notice Thrown when post-check validation attempted while skipped.
    error CannotPostCheckWhenSkipped();

    /// @notice Validates subject against specified check type.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Check phase to execute.
    /// @return checked True if validation passes.
    function check(address subject, bytes calldata evidence, Check checkType) external view returns (bool checked);
}
