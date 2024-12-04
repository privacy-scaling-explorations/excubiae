// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IPolicy.
/// @notice Core policy interface for protected contract management.
interface IPolicy {
    /// @notice Emitted when target contract is set.
    event TargetSet(address indexed target);

    /// @notice Core error conditions.
    error ZeroAddress();
    error UnsuccessfulCheck();
    error TargetNotSet();
    error TargetOnly();
    error TargetAlreadySet();
    error AlreadyEnforced();

    /// @notice Returns policy trait identifier.
    /// @return Policy trait string (e.g., "Semaphore").
    function trait() external pure returns (string memory);

    /// @notice Sets protected contract address.
    /// @dev Owner-only, one-time setting.
    /// @param _target Protected contract address.
    function setTarget(address _target) external;
}
