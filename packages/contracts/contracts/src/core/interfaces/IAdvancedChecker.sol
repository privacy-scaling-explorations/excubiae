// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Check
/// @notice Enum representing validation phases.
/// @dev Used to identify the specific validation phase in multi-phase systems.
/// @dev The PRE and POST checks are optional and may be skipped based on contract settings.
enum Check {
    /// Pre-condition validation.
    PRE,
    /// Primary validation.
    MAIN,
    /// Post-condition validation.
    POST
}

/// @notice Tracks the status of validation checks.
/// @dev Used in AdvancedPolicy to maintain the state of multi-phase checks.
struct CheckStatus {
    /// @notice Indicates whether the pre-condition check has been completed.
    bool pre;
    /// @notice Tracks the number of main checks completed.
    uint8 main;
    /// @notice Indicates whether the post-condition check has been completed.
    bool post;
}

/// @title IAdvancedChecker
/// @notice Interface defining multi-phase validation capabilities.
/// @dev Supports PRE, MAIN, and POST validation phases.
interface IAdvancedChecker {
    /// @notice Validates a subject for a specific check phase.
    /// @dev Implementations should route to appropriate phase-specific logic.
    /// @param subject The address to validate.
    /// @param evidence Custom validation data.
    /// @param checkType The phase of validation to execute (PRE, MAIN, POST).
    /// @return checked Boolean indicating whether the validation passed.
    function check(address subject, bytes calldata evidence, Check checkType) external view returns (bool checked);
}
