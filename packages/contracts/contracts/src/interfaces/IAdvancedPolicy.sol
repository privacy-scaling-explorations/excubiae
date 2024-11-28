// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IPolicy} from "./IPolicy.sol";
import {Check} from "./IAdvancedChecker.sol";

/// @title IAdvancedPolicy
/// @notice IAdvancedPolicy contract interface that extends the IPolicy interface.
interface IAdvancedPolicy is IPolicy {
    /// @notice Error thrown when the MAIN check cannot be executed more than once.
    error MainCheckAlreadyEnforced();

    /// @notice Error thrown when the PRE check has not been enforced yet.
    error PreCheckNotEnforced();

    /// @notice Error thrown when the MAIN check has not been enforced yet.
    error MainCheckNotEnforced();

    /// @notice Event emitted when someone enforces the `target` check.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param target The address of the policy-protected contract address.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    /// @param checkType The type of check that was performed (e.g., PRE, MAIN, POST).
    event Enforced(address indexed subject, address indexed target, bytes evidence, Check checkType);

    /// @notice Enforces the custom target enforcing logic.
    /// @dev Must call the right `check` method based on the `checkType` to handle the logic of checking
    /// subject for specific target.
    /// @dev Must call the `check` to handle the logic of checking subject for specific target.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    /// @param checkType The type of the check to be enforced for the subject with the given data.
    function enforce(address subject, bytes calldata evidence, Check checkType) external;
}
