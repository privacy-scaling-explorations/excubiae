// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

/// @notice Tracks validation status for pre, main, and post checks.
/// @dev Used to maintain check state in AdvancedPolicy.
struct CheckStatus {
    /// @dev Pre-check completion status.
    bool pre;
    /// @dev Number of completed main checks.
    uint8 main;
    /// @dev Post-check completion status.
    bool post;
}

/// @title IAdvancedChecker.
/// @notice Defines multi-phase validation system interface.
/// @dev Implement this for custom validation logic with pre/main/post checks.
interface IAdvancedChecker {
    /// @notice Validates subject against specified check type.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Check phase to execute.
    /// @return checked True if validation passes.
    function check(address subject, bytes calldata evidence, Check checkType) external view returns (bool checked);
}
