// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721Checker} from "../base/BaseERC721Checker.sol";

/// @title BaseERC721CheckerHarness
/// @notice Test harness exposing internal methods of `BaseERC721Checker` for testing purposes.
/// @dev Inherits `BaseERC721Checker` and provides external methods for accessing internal logic.
contract BaseERC721CheckerHarness is BaseERC721Checker {
    /// @notice Test exposure for `_initialize` method.
    function exposed__initialize() external {
        _initialize();
    }

    /// @notice Test exposure for `_check` method.
    /// @dev Allows testing of the generic validation logic.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Boolean indicating whether validation passed.
    function exposed__check(address subject, bytes[] calldata evidence) public view returns (bool) {
        return _check(subject, evidence);
    }
}
