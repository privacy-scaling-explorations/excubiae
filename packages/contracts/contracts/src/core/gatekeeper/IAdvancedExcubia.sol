// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IExcubia} from "./IExcubia.sol";
import {Check} from "../checker/IAdvancedChecker.sol";

/// @title IAdvancedExcubia
/// @notice AdvancedExcubia contract interface that extends the IExcubia interface.
interface IAdvancedExcubia is IExcubia {
    /// @notice Error thrown when the PRE check is skipped.
    error PreCheckSkipped();

    /// @notice Error thrown when the MAIN check cannot be executed more than once.
    error MainCheckAlreadyEnforced();

    /// @notice Error thrown when the POST check is skipped.
    error PostCheckSkipped();

    /// @notice Event emitted when someone passes the `gate` check.
    /// @param passerby The address of those who have successfully passed the check.
    /// @param gate The address of the excubia-protected contract address.
    /// @param data Additional data related to the gate check.
    /// @param checkType The type of check that was performed (e.g., PRE, MAIN, POST).
    event GatePassed(address indexed passerby, address indexed gate, bytes data, Check checkType);

    /// @notice Enforces the custom gate passing logic.
    /// @dev Must call the right `check` method based on the `checkType` to handle the logic of checking
    /// passerby for specific gate.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    /// @param checkType The type of the check to be enforced for the passerby with the given data.
    function pass(address passerby, bytes calldata data, Check checkType) external;
}
