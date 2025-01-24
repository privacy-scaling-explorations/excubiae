// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAdvancedPolicy, Check} from "../interfaces/IAdvancedPolicy.sol";
import {AdvancedChecker, CheckStatus} from "../checker/AdvancedChecker.sol";
import {Policy} from "./Policy.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

/// @title AdvancedPolicy
/// @notice Implements advanced policy checks with pre, main, and post validation stages.
/// @dev Extends Policy with multi-stage validation. Now clone-friendly with `initialize()`.
abstract contract AdvancedPolicy is IAdvancedPolicy, Policy {
    /// @notice Reference to the validation checker contract. Stored, not immutable.
    AdvancedChecker public ADVANCED_CHECKER;

    /// @notice Controls whether pre-condition checks are required.
    bool public SKIP_PRE;

    /// @notice Controls whether post-condition checks are required.
    bool public SKIP_POST;

    /// @notice Controls whether main check can be executed multiple times.
    bool public ALLOW_MULTIPLE_MAIN;

    /// @notice Tracks validation status for each subject per target.
    mapping(address => CheckStatus) public enforced;

    /**
     * @notice Initialize function for minimal proxy clones.
     *         Decodes appended bytes for (AdvancedChecker, skipPre, skipPost, allowMultipleMain).
     */
    function initialize() public virtual override {
        // 1. Call Policy’s initialize to set ownership and `_initialized`.
        super.initialize();

        // 2. Decode the appended bytes for the advanced config.
        bytes memory data = _getAppendedBytes();
        (address sender, address advCheckerAddr, bool skipPre, bool skipPost, bool allowMultipleMain) = abi.decode(
            data,
            (address, address, bool, bool, bool)
        );

        _transferOwnership(sender);

        ADVANCED_CHECKER = AdvancedChecker(advCheckerAddr);
        SKIP_PRE = skipPre;
        SKIP_POST = skipPost;
        ALLOW_MULTIPLE_MAIN = allowMultipleMain;
    }

    /// @notice Enforces a policy check for a subject, handling multi-stage logic.
    /// @dev Only callable by the target contract.
    function enforce(address subject, bytes[] calldata evidence, Check checkType) external override onlyTarget {
        _enforce(subject, evidence, checkType);
    }

    /// @notice Internal check enforcement logic for advanced multi-stage checks.
    function _enforce(address subject, bytes[] calldata evidence, Check checkType) internal {
        if (!ADVANCED_CHECKER.check(subject, evidence, checkType)) {
            revert UnsuccessfulCheck();
        }

        CheckStatus storage status = enforced[subject];

        if (checkType == Check.PRE) {
            if (SKIP_PRE) revert CannotPreCheckWhenSkipped();
            if (status.pre) revert AlreadyEnforced();
            status.pre = true;
        } else if (checkType == Check.POST) {
            if (SKIP_POST) revert CannotPostCheckWhenSkipped();
            if (status.main == 0) revert MainCheckNotEnforced();
            if (status.post) revert AlreadyEnforced();
            status.post = true;
        } else {
            // MAIN check
            if (!SKIP_PRE && !status.pre) revert PreCheckNotEnforced();
            if (!ALLOW_MULTIPLE_MAIN && status.main > 0) revert MainCheckAlreadyEnforced();
            status.main += 1;
        }

        emit Enforced(subject, target, evidence, checkType);
    }
}
