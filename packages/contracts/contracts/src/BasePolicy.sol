// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IBasePolicy} from "./interfaces/IBasePolicy.sol";
import {Policy} from "./Policy.sol";
import {BaseChecker} from "./BaseChecker.sol";

/// @title BasePolicy
/// @notice Abstract base contract which can be extended to implement a specific `BasePolicy`.
abstract contract BasePolicy is Policy, IBasePolicy {
    /// @dev Reference to the BaseChecker contract for validation.
    BaseChecker public immutable BASE_CHECKER;

    /// @dev Tracks whether the check has been enforced for a subject.
    mapping(address => mapping(address => bool)) public enforced;

    /// @notice Constructor to initialize the BaseChecker contract.
    /// @param _baseChecker The address of the BaseChecker contract.
    constructor(BaseChecker _baseChecker) {
        BASE_CHECKER = _baseChecker;
    }

    /// @notice Enforces the custom target enforcing logic.
    /// @dev Must call the `check` to handle the logic of checking subject for specific target.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    function enforce(address subject, bytes calldata evidence) external override onlyTarget {
        _enforce(subject, evidence);
    }

    /// @notice Enforces the custom target enforcing logic.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    function _enforce(address subject, bytes calldata evidence) internal {
        bool checked = BASE_CHECKER.check(subject, evidence);

        if (enforced[msg.sender][subject]) revert AlreadyEnforced();
        if (!checked) revert UnsuccessfulCheck();

        enforced[msg.sender][subject] = checked;

        emit Enforced(subject, target, evidence);
    }
}
