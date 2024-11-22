// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @title IExcubia
/// @notice Excubia contract interface that defines the basic functionalities for gate management.
interface IExcubia {
    /// @notice Event emitted when the `gate` address is set.
    /// @param gate The address of the contract set as the `gate`.
    event GateSet(address indexed gate);

    /// @notice Error thrown when an address equal to zero is given.
    error ZeroAddress();

    /// @notice Error thrown when a passerby do not satisfy the checks.
    error CheckNotPassed();

    /// @notice Error thrown when the `gate` address is not set.
    error GateNotSet();

    /// @notice Error thrown when the callee is not the `gate` contract.
    error GateOnly();

    /// @notice Error thrown when the `gate` address has been already set.
    error GateAlreadySet();

    /// @notice Error thrown when the passerby has already passed the `gate`.
    error AlreadyPassed();

    /// @notice Gets the trait of the Excubia contract.
    /// @return The specific trait of the Excubia contract (e.g., SemaphoreExcubia has trait Semaphore).
    function trait() external pure returns (string memory);

    /// @notice Sets the gate address.
    /// @dev Only the owner can set the destination `gate` address.
    /// @param _gate The address of the contract to be set as the gate.
    function setGate(address _gate) external;
}
