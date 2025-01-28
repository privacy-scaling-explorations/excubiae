// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721Policy} from "../BaseERC721Policy.sol";

/// @title BaseERC721PolicyHarness
/// @notice Test harness for `BaseERC721Policy` to expose internal methods for testing.
/// @dev Inherits `BaseERC721Policy` and allows testing of protected methods.
contract BaseERC721PolicyHarness is BaseERC721Policy {
    /// @notice Test exposure for the `_initialize` method.
    function exposed__initialize() external {
        _initialize();
    }

    /// @notice Test exposure for the `_enforce` method.
    /// @dev Allows testing of the internal enforcement logic for a specific phase.
    /// @param subject Address to validate.
    /// @param evidence Validation data for the specified check type.
    function exposed__enforce(address subject, bytes[] calldata evidence) public onlyTarget {
        _enforce(subject, evidence);
    }
}
