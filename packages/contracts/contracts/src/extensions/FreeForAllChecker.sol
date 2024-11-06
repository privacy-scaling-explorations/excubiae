// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseChecker} from "../core/checker/BaseChecker.sol";

/// @title FreeForAllChecker Contract.
/// @notice This contract extends the `BaseChecker` to allow unrestricted access through the `gate`.
/// @dev This contract does not perform any checks and allows any `passerby` to pass the `gate`.
/// It overrides the `_check` function to provide no validation, effectively granting free access.
contract FreeForAllChecker is BaseChecker {
    /// @notice Internal method to perform the check for a passerby.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    /// @dev This method is intentionally left empty to allow all passerby addresses to pass without any checks.
    function _check(address passerby, bytes memory data) internal view override {}
}
