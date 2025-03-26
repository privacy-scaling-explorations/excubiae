// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IPolicy
/// @notice Core interface for managing policies that protect specific contracts.
/// @dev Provides methods for setting and retrieving the protected contract and enforcing checks.
interface IPolicy {
    /// @notice Emitted when the guarded contract is successfully set.
    /// @param guarded Address of the protected contract.
    event TargetSet(address indexed guarded);

    /// @notice Error thrown when a user is already registered.
    error AlreadyEnforced();

    /// @notice Error thrown when a zero address is provided where not allowed.
    error ZeroAddress();

    /// @notice Error thrown when a validation check fails.
    error UnsuccessfulCheck();

    /// @notice Error thrown when the guarded contract is not set.
    error TargetNotSet();

    /// @notice Error thrown when a function is restricted to calls from the guarded contract.
    error TargetOnly();

    /// @notice Error thrown when attempting to set the guarded more than once.
    error TargetAlreadySet();

    /// @notice Retrieves the policy trait identifier.
    /// @dev This is typically used to distinguish policy implementations (e.g., "Semaphore").
    /// @return The policy trait string.
    function trait() external pure returns (string memory);

    /// @notice Sets the contract address to be protected by this policy.
    /// @dev This function is restricted to the owner and can only be called once.
    /// @param _guarded The address of the protected contract.
    function setTarget(address _guarded) external;
}
