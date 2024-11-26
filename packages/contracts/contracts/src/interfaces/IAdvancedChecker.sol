// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @notice This enum defines the types of checks that can be performed in the AdvancedChecker system.
/// @dev The `Check` enum represents the different phases of validation in the AdvancedChecker system.
/// - `PRE`: Represents the pre-condition check that must be satisfied before the `MAIN` check can occur.
/// - `MAIN`: The primary check that is executed, which can be validated multiple times.
/// - `POST`: Represents the post-condition check that can be validated after the `MAIN` check has been completed.
enum Check {
    PRE,
    MAIN,
    POST
}

/// @title IAdvancedChecker.
/// @notice AdvancedChecker contract interface.
interface IAdvancedChecker {
    /// @dev Defines the custom `target` protection logic.
    /// @param subject The address of the entity attempting to interact with the `target`.
    /// @param evidence Additional data that may be required for the check.
    /// @param checkType The type of check to be enforced (e.g., PRE, MAIN, POST).
    /// @return checked A boolean that resolves to true when the subject satisfies the checks; otherwise false.
    function check(address subject, bytes calldata evidence, Check checkType) external view returns (bool checked);
}
