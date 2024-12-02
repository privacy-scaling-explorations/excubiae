// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IAdvancedChecker, Check} from "./interfaces/IAdvancedChecker.sol";

/// @notice Tracks validation status for pre, main, and post checks.
/// @dev Used to maintain check state in AdvancedPolicy.
struct CheckStatus {
    /// @dev Pre-check completion status.
    bool pre;
    /// @dev Number of completed main checks.
    uint8 main;
    /// @dev Post-check completion status.
    bool post;
}

/// @title AdvancedChecker.
/// @notice Multi-phase validation checker with pre, main, and post checks.
/// @dev Base contract for implementing complex validation logic with configurable check phases.
abstract contract AdvancedChecker is IAdvancedChecker {
    /// @notice Controls whether pre-condition checks are required.
    bool public immutable SKIP_PRE;

    /// @notice Controls whether post-condition checks are required.
    bool public immutable SKIP_POST;

    /// @notice Controls whether main check can be executed multiple times.
    bool public immutable ALLOW_MULTIPLE_MAIN;

    /// @notice Sets up checker configuration.
    /// @param _skipPre Skip pre-condition validation.
    /// @param _skipPost Skip post-condition validation.
    /// @param _allowMultipleMain Allow multiple main validations.
    constructor(bool _skipPre, bool _skipPost, bool _allowMultipleMain) {
        SKIP_PRE = _skipPre;
        SKIP_POST = _skipPost;
        ALLOW_MULTIPLE_MAIN = _allowMultipleMain;
    }

    /// @notice Entry point for validation checks.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Type of check (PRE, MAIN, POST).
    /// @return checked Validation result.
    function check(
        address subject,
        bytes memory evidence,
        Check checkType
    ) external view override returns (bool checked) {
        return _check(subject, evidence, checkType);
    }

    /// @notice Core validation logic router.
    /// @dev Directs to appropriate check based on type and configuration.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Check type to perform.
    /// @return checked Validation result.
    /// @custom:throws PreCheckSkipped If PRE check attempted when skipped.
    /// @custom:throws PostCheckSkipped If POST check attempted when skipped.
    function _check(address subject, bytes memory evidence, Check checkType) internal view returns (bool checked) {
        // Validate skip conditions first.
        if (checkType == Check.PRE && SKIP_PRE) revert PreCheckSkipped();
        if (checkType == Check.POST && SKIP_POST) revert PostCheckSkipped();

        // Route to appropriate check.
        return
            checkType == Check.PRE
                ? _checkPre(subject, evidence)
                : checkType == Check.POST
                    ? _checkPost(subject, evidence)
                    : _checkMain(subject, evidence);
    }

    /// @notice Pre-condition validation implementation.
    /// @dev Override to implement pre-check logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return checked Validation result.
    function _checkPre(address subject, bytes memory evidence) internal view virtual returns (bool checked) {}

    /// @notice Main validation implementation.
    /// @dev Override to implement main check logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return checked Validation result.
    function _checkMain(address subject, bytes memory evidence) internal view virtual returns (bool checked) {}

    /// @notice Post-condition validation implementation.
    /// @dev Override to implement post-check logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return checked Validation result.
    function _checkPost(address subject, bytes memory evidence) internal view virtual returns (bool checked) {}
}
