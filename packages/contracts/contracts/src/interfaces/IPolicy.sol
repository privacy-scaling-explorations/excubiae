// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title IPolicy
/// @notice Policy contract interface that defines the basic functionalities for `target` protected contract management.
interface IPolicy {
    /// @notice Event emitted when the `target` address is set.
    /// @param target The address of the contract set as the `target`.
    event TargetSet(address indexed target);

    /// @notice Error thrown when an address equal to zero is given.
    error ZeroAddress();

    /// @notice Error thrown when a subject do not satisfy the checks.
    error UnsuccessfulCheck();

    /// @notice Error thrown when the `target` address is not set.
    error TargetNotSet();

    /// @notice Error thrown when the callee is not the `target` contract.
    error TargetOnly();

    /// @notice Error thrown when the `target` address has been already set.
    error TargetAlreadySet();

    /// @notice Error thrown when the subject has already enforced the `target`.
    error AlreadyEnforced();

    /// @notice Gets the trait of the Policy contract.
    /// @return The specific trait of the Policy contract (e.g., SemaphorePolicy has trait Semaphore).
    function trait() external pure returns (string memory);

    /// @notice Sets the target address.
    /// @dev Only the owner can set the destination `target` address.
    /// @param _target The address of the contract to be set as the target.
    function setTarget(address _target) external;
}
