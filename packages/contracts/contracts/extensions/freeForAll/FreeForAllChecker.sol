// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseChecker} from "../../checker/BaseChecker.sol";

/// @title FreeForAllChecker
/// @notice Free for all validator.
/// @dev Extends BaseChecker to implement FreeForAll validation logic.
contract FreeForAllChecker is BaseChecker {
    /// @notice Initializes the contract.
    function _initialize() internal override {
        super._initialize();
    }

    /// @notice Returns true for everycall.
    /// @param subject Address to validate.
    /// @param evidence Encoded data used for validation.
    /// @return Boolean indicating whether the subject passes the check.
    function _check(address subject, bytes calldata evidence) internal view override returns (bool) {
        super._check(subject, evidence);

        return true;
    }
}
