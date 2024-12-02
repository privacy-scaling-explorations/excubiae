// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Policy} from "./Policy.sol";
import {IAdvancedPolicy, Check} from "./interfaces/IAdvancedPolicy.sol";
import {AdvancedChecker, CheckStatus} from "./AdvancedChecker.sol";

/// @title AdvancedPolicy.
/// @notice Implements advanced policy checks with pre, main, and post validation stages.
/// @dev Extends Policy contract with multi-stage validation capabilities.
abstract contract AdvancedPolicy is IAdvancedPolicy, Policy {
    /// @notice Reference to the validation checker contract.
    /// @dev Immutable to ensure checker cannot be changed after deployment.
    AdvancedChecker public immutable ADVANCED_CHECKER;

    /// @notice Tracks validation status for each subject per target.
    /// @dev Maps target => subject => CheckStatus.
    mapping(address => mapping(address => CheckStatus)) public enforced;

    /// @notice Initializes contract with an AdvancedChecker instance.
    /// @param _advancedChecker Address of the AdvancedChecker contract.
    constructor(AdvancedChecker _advancedChecker) {
        ADVANCED_CHECKER = _advancedChecker;
    }

    /// @notice Enforces policy check for a subject.
    /// @dev Only callable by target contract.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Type of check (PRE, MAIN, POST).
    function enforce(address subject, bytes calldata evidence, Check checkType) external override onlyTarget {
        _enforce(subject, evidence, checkType);
    }

    /// @notice Internal check enforcement logic.
    /// @dev Handles different check types and their dependencies.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Type of check to perform.
    /// @custom:throws UnsuccessfulCheck If validation fails.
    /// @custom:throws AlreadyEnforced If check was already completed.
    /// @custom:throws PreCheckNotEnforced If PRE check is required but not done.
    /// @custom:throws MainCheckNotEnforced If MAIN check is required but not done.
    /// @custom:throws MainCheckAlreadyEnforced If multiple MAIN checks not allowed.
    function _enforce(address subject, bytes calldata evidence, Check checkType) internal {
        if (!ADVANCED_CHECKER.check(subject, evidence, checkType)) {
            revert UnsuccessfulCheck();
        }

        CheckStatus storage status = enforced[msg.sender][subject];

        // Handle PRE check.
        if (checkType == Check.PRE) {
            if (!ADVANCED_CHECKER.SKIP_POST() && status.pre) {
                revert AlreadyEnforced();
            }
            status.pre = true;
            emit Enforced(subject, target, evidence, checkType);
            return;
        }

        // Handle POST check.
        if (checkType == Check.POST) {
            if (status.post) {
                revert AlreadyEnforced();
            }
            if (!ADVANCED_CHECKER.SKIP_PRE() && !status.pre) {
                revert PreCheckNotEnforced();
            }
            if (status.main == 0) {
                revert MainCheckNotEnforced();
            }
            status.post = true;
            emit Enforced(subject, target, evidence, checkType);
            return;
        }

        // Handle MAIN check.
        if (!ADVANCED_CHECKER.ALLOW_MULTIPLE_MAIN() && status.main > 0) {
            revert MainCheckAlreadyEnforced();
        }
        if (!ADVANCED_CHECKER.SKIP_PRE() && !status.pre) {
            revert PreCheckNotEnforced();
        }
        status.main += 1;
        emit Enforced(subject, target, evidence, checkType);
    }
}
