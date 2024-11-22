// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IAdvancedChecker, Check} from "./IAdvancedChecker.sol";

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
    bool public skipPre;

    /// @notice Flag to determine if post-condition checks should be skipped.
    bool public skipPost;

    /// @notice Flag to determine if main checks can be executed multiple times.
    bool public allowMultipleMain;

    /// @param _skipPre Indicates whether to skip pre-condition checks.
    /// @param _skipPost Indicates whether to skip post-condition checks.
    /// @param _allowMultipleMain Indicates whether the main check can be executed multiple times.
    constructor(bool _skipPre, bool _skipPost, bool _allowMultipleMain) {
        skipPre = _skipPre;
        skipPost = _skipPost;
        allowMultipleMain = _allowMultipleMain;
    }

    /// @notice Public method to check the validity of the provided data for a given address and check type.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    /// @param checkType The type of check to perform (PRE, MAIN, POST).
    function check(address passerby, bytes memory data, Check checkType) external view override returns (bool checked) {
        return _check(passerby, data, checkType);
    }

    /// @notice Internal method to orchestrate the validation process based on the specified check type.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    /// @param checkType The type of check to perform (PRE, MAIN, POST).
    function _check(address passerby, bytes memory data, Check checkType) internal view returns (bool checked) {
        if (!skipPre && checkType == Check.PRE) {
            return _checkPre(passerby, data);
        } else if (!skipPost && checkType == Check.POST) {
            return _checkPost(passerby, data);
        } else if (checkType == Check.MAIN) {
            return _checkMain(passerby, data);
        }

        return false;
    }

    /// @notice Internal method for performing pre-condition checks.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    function _checkPre(address passerby, bytes memory data) internal view virtual returns (bool checked) {}

    /// @notice Internal method for performing main checks.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    function _checkMain(address passerby, bytes memory data) internal view virtual returns (bool checked) {}

    /// @notice Internal method for performing post-condition checks.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    function _checkPost(address passerby, bytes memory data) internal view virtual returns (bool checked) {}
}
