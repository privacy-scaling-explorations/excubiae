// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IPolicy} from "./IPolicy.sol";

/// @title IBasePolicy
/// @notice BasePolicy contract interface that extends the IPolicy interface.
interface IBasePolicy is IPolicy {
    /// @notice Event emitted when someone enforcing the `target` check.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param target The address of the policy-protected contract address.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    event Enforced(address indexed subject, address indexed target, bytes evidence);

    /// @notice Enforces the custom target enforcing logic.
    /// @dev Must call the `check` to handle the logic of checking subject for specific target.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    function enforce(address subject, bytes calldata evidence) external;
}
