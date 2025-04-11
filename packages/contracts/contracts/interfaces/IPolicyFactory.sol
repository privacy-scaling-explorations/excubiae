// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IPolicyFactory
/// @notice Interface for policy factory instances.
/// @dev Provides methods for deploying new policy clones.
interface IPolicyFactory {
    /// @notice Deploys a new policy clone.
    /// @param checkerAddress The address of the checker to use for validation.
    /// @return clone The address of the newly deployed policy clone.
    function deploy(address checkerAddress) external returns (address clone);
}
