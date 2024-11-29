// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IAdvancedChecker, Check} from "./interfaces/IAdvancedChecker.sol";

struct CheckStatus {
    bool pre;
    uint8 main;
    bool post;
}

/// @title AdvancedChecker.
/// @notice Abstract base contract which can be extended to implement a specific `AdvancedChecker`.
/// @dev The `AdvancedChecker` contract builds upon the `BaseChecker` by introducing additional validation phases.
/// It allows for pre-condition (`PRE`), main (`MAIN`), and post-condition (`POST`) checks, with the option to skip
/// pre and post checks based on constructor parameters. The `_check` method orchestrates the validation process
/// based on the specified check type.
abstract contract AdvancedChecker is IAdvancedChecker {
    /// @notice Flag to determine if pre-condition checks should be skipped.
    bool public immutable SKIP_PRE;

    /// @notice Flag to determine if post-condition checks should be skipped.
    bool public immutable SKIP_POST;

    /// @notice Flag to determine if main checks can be executed multiple times.
    bool public immutable ALLOW_MULTIPLE_MAIN;

    /// @param _skipPre Indicates whether to skip pre-condition checks.
    /// @param _skipPost Indicates whether to skip post-condition checks.
    /// @param _allowMultipleMain Indicates whether the main check can be executed multiple times.
    constructor(bool _skipPre, bool _skipPost, bool _allowMultipleMain) {
        SKIP_PRE = _skipPre;
        SKIP_POST = _skipPost;
        ALLOW_MULTIPLE_MAIN = _allowMultipleMain;
    }

    /// @notice Public method to check the validity of the provided evidence for a given address and check type.
    /// @param subject The address to be checked.
    /// @param evidence The evidence associated with the check.
    /// @param checkType The type of check to perform (PRE, MAIN, POST).
    function check(
        address subject,
        bytes memory evidence,
        Check checkType
    ) external view override returns (bool checked) {
        return _check(subject, evidence, checkType);
    }

    /// @notice Internal method to orchestrate the validation process based on the specified check type.
    /// @param subject The address to be checked.
    /// @param evidence The evidence associated with the check.
    /// @param checkType The type of check to perform (PRE, MAIN, POST).
    function _check(address subject, bytes memory evidence, Check checkType) internal view returns (bool checked) {
        if (SKIP_PRE && checkType == Check.PRE) revert PreCheckSkipped();
        if (SKIP_POST && checkType == Check.POST) revert PostCheckSkipped();

        if (!SKIP_PRE && checkType == Check.PRE) {
            return _checkPre(subject, evidence);
        }

        if (!SKIP_POST && checkType == Check.POST) {
            return _checkPost(subject, evidence);
        }

        return _checkMain(subject, evidence);
    }

    /// @notice Internal method for performing pre-condition checks.
    /// @param subject The address to be checked.
    /// @param evidence The evidence associated with the check.
    function _checkPre(address subject, bytes memory evidence) internal view virtual returns (bool checked) {}

    /// @notice Internal method for performing main checks.
    /// @param subject The address to be checked.
    /// @param evidence The evidence associated with the check.
    function _checkMain(address subject, bytes memory evidence) internal view virtual returns (bool checked) {}

    /// @notice Internal method for performing post-condition checks.
    /// @param subject The address to be checked.
    /// @param evidence The evidence associated with the check.
    function _checkPost(address subject, bytes memory evidence) internal view virtual returns (bool checked) {}
}
