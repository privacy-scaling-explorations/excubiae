// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IClone
/// @notice Interface for cloneable contracts with initialization logic.
/// @dev Supports minimal proxy pattern and appended bytes retrieval.
interface IClone {
    /// @notice Error thrown when the clone is already initialized.
    error AlreadyInitialized();

    /// @notice Initializes the clone contract.
    /// @dev Typically used for setting up state or configuration data.
    function initialize() external;

    /// @notice Retrieves appended bytes from the clone's runtime bytecode.
    /// @return Appended bytes passed during the clone's creation.
    function getAppendedBytes() external view returns (bytes memory);
}
