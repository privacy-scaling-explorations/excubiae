// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedERC721Checker} from "../advanced/AdvancedERC721Checker.sol";
import {Check} from "../../core/interfaces/IAdvancedChecker.sol";

/// @title AdvancedERC721CheckerHarness
/// @notice Test harness exposing internal methods of `AdvancedERC721Checker` for testing purposes.
/// @dev Inherits `AdvancedERC721Checker` and provides external methods for accessing internal logic.
contract AdvancedERC721CheckerHarness is AdvancedERC721Checker {
    /// @notice Test exposure for `_initialize` method.
    function exposed__initialize() external {
        _initialize();
    }

    /// @notice Test exposure for `_check` method.
    /// @dev Allows testing of the generic validation logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Type of check to perform (PRE, MAIN, POST).
    /// @return Boolean indicating whether validation passed.
    function exposed__check(address subject, bytes[] calldata evidence, Check checkType) public view returns (bool) {
        return _check(subject, evidence, checkType);
    }

    /// @notice Test exposure for `_checkPre` method.
    /// @dev Allows testing of the pre-condition validation logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Boolean indicating whether pre-check validation passed.
    function exposed__checkPre(address subject, bytes[] calldata evidence) public view returns (bool) {
        return _checkPre(subject, evidence);
    }

    /// @notice Test exposure for `_checkMain` method.
    /// @dev Allows testing of the main validation logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Boolean indicating whether main validation passed.
    function exposed__checkMain(address subject, bytes[] calldata evidence) public view returns (bool) {
        return _checkMain(subject, evidence);
    }

    /// @notice Test exposure for `_checkPost` method.
    /// @dev Allows testing of the post-condition validation logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Boolean indicating whether post-check validation passed.
    function exposed__checkPost(address subject, bytes[] calldata evidence) public view returns (bool) {
        return _checkPost(subject, evidence);
    }
}
