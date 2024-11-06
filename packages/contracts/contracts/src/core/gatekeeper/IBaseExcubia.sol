// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IExcubia} from "./IExcubia.sol";

/// @title IBaseExcubia
/// @notice BaseExcubia contract interface that extends the IExcubia interface.
interface IBaseExcubia is IExcubia {
    /// @notice Event emitted when someone passes the `gate` check.
    /// @param passerby The address of those who have successfully passed the check.
    /// @param gate The address of the excubia-protected contract address.
    event GatePassed(address indexed passerby, address indexed gate, bytes data);

    /// @notice Enforces the custom gate passing logic.
    /// @dev Must call the `check` to handle the logic of checking passerby for specific gate.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    function pass(address passerby, bytes calldata data) external;
}
