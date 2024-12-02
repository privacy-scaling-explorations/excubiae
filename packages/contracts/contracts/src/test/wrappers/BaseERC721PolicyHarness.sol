// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseERC721Policy} from "../base/BaseERC721Policy.sol";
import {BaseERC721Checker} from "../base/BaseERC721Checker.sol";

/// @title BaseERC721PolicyHarness.
/// @notice Test harness for BaseERC721Policy internal methods.
contract BaseERC721PolicyHarness is BaseERC721Policy {
    /// @notice Initializes test harness with checker.
    constructor(BaseERC721Checker _checker) BaseERC721Policy(_checker) {}

    /// @notice Test exposure for _enforce method.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    function exposed__enforce(address subject, bytes calldata evidence) public onlyTarget {
        _enforce(subject, evidence);
    }
}
