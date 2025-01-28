// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedERC721Policy} from "../AdvancedERC721Policy.sol";
import {Check} from "../../../core/interfaces/IAdvancedChecker.sol";

/// @title AdvancedERC721PolicyHarness
/// @notice Test harness for `AdvancedERC721Policy` to expose internal methods for testing.
/// @dev Inherits `AdvancedERC721Policy` and allows testing of protected methods.
contract AdvancedERC721PolicyHarness is AdvancedERC721Policy {
    /// @notice Test exposure for the `_initialize` method.
    function exposed__initialize() external {
        _initialize();
    }

    /// @notice Test exposure for the `_enforce` method.
    /// @dev Allows testing of the internal enforcement logic for a specific phase.
    /// @param subject Address to validate.
    /// @param evidence Validation data for the specified check type.
    /// @param checkType Check phase to enforce (PRE, MAIN, POST).
    function exposed__enforce(address subject, bytes[] calldata evidence, Check checkType) public onlyTarget {
        _enforce(subject, evidence, checkType);
    }
}
