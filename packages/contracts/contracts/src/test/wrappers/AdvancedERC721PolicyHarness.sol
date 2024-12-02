// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedERC721Policy} from "../advanced/AdvancedERC721Policy.sol";
import {AdvancedERC721Checker} from "../advanced/AdvancedERC721Checker.sol";
import {Check} from "../../interfaces/IAdvancedChecker.sol";

/// @title AdvancedERC721PolicyHarness.
/// @notice Test harness for AdvancedERC721Policy internal methods.
contract AdvancedERC721PolicyHarness is AdvancedERC721Policy {
    /// @notice Initializes test harness.
    constructor(AdvancedERC721Checker _checker) AdvancedERC721Policy(_checker) {}

    /// @notice Test exposure for _enforce method.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Check type to enforce.
    function exposed__enforce(address subject, bytes calldata evidence, Check checkType) public onlyTarget {
        _enforce(subject, evidence, checkType);
    }
}
