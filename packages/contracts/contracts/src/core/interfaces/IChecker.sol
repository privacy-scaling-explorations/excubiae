// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IChecker
/// @notice Core checker interface for attribute verification functionalities.
interface IChecker {
    /// @notice Core error conditions.
    error VerifierNotFound();

    /// @notice Retrieves the verifier address at a specific index.
    /// @param index The index of the verifier in the array.
    /// @return The address of the verifier at the specified index.
    /// @custom:throws VerifierNotFound if no address have been specified at given index.
    function getVerifierAtIndex(uint256 index) external view returns (address);
}
