// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Policy} from "./Policy.sol";
import {IAdvancedPolicy, Check} from "./interfaces/IAdvancedPolicy.sol";
import {AdvancedChecker, CheckStatus} from "./AdvancedChecker.sol";

/// @title AdvancedPolicy
/// @notice Abstract base contract which can be extended to implement a specific `AdvancedPolicy`.
abstract contract AdvancedPolicy is IAdvancedPolicy, Policy {
    /// @dev Reference to the AdvancedChecker contract for validation.
    AdvancedChecker public immutable ADVANCED_CHECKER;

    /// @dev Tracks the check status of each address.
    mapping(address => mapping(address => CheckStatus)) public enforced;

    /// @notice Constructor to initialize the AdvancedChecker contract.
    /// @param _advancedChecker The address of the AdvancedChecker contract.
    constructor(AdvancedChecker _advancedChecker) {
        ADVANCED_CHECKER = _advancedChecker;
    }

    /// @notice Enforces the custom target logic.
    /// @dev Calls the internal `_enforce` function to enforce the target logic.
    /// @dev Must call the `check` to handle the logic of checking subject for specific target.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    /// @param checkType The type of the check to be enforced for the subject with the given data.
    function enforce(address subject, bytes calldata evidence, Check checkType) external override onlyTarget {
        _enforce(subject, evidence, checkType);
    }

    /// @notice Internal function to enforce the target logic.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    /// @param checkType The type of the check to be enforced for the subject with the given data.
    function _enforce(address subject, bytes calldata evidence, Check checkType) internal {
        bool checked = ADVANCED_CHECKER.check(subject, evidence, checkType);

        if (!checked) revert UnsuccessfulCheck();

        if (checkType == Check.PRE) {
            if (ADVANCED_CHECKER.skipPre()) revert PreCheckSkipped();
            else if (enforced[msg.sender][subject].pre) revert AlreadyEnforced();
            else enforced[msg.sender][subject].pre = true;
        } else if (checkType == Check.POST) {
            if (ADVANCED_CHECKER.skipPost()) revert PostCheckSkipped();
            else if (enforced[msg.sender][subject].post) revert AlreadyEnforced();
            else enforced[msg.sender][subject].post = true;
        } else if (checkType == Check.MAIN) {
            if (!ADVANCED_CHECKER.allowMultipleMain() && enforced[msg.sender][subject].main > 0) {
                revert MainCheckAlreadyEnforced();
            } else {
                enforced[msg.sender][subject].main += 1;
            }
        }

        emit Enforced(subject, target, evidence, checkType);
    }
}
