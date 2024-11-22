// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IBaseChecker} from "./IBaseChecker.sol";

/// @title BaseChecker.
/// @notice Abstract base contract which can be extended to implement a specific `BaseChecker`.
/// @dev The `BaseChecker` contract provides a foundational structure for implementing specific checker logic.
/// It defines a method `check` that invokes a protected `_check` method, which must be implemented by derived
/// contracts.
abstract contract BaseChecker is IBaseChecker {
    /// @notice Checks the validity of the provided data for a given address.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    function check(address passerby, bytes memory data) external view override returns (bool checked) {
        return _check(passerby, data);
    }

    /// @notice Internal method to perform the actual check logic.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    function _check(address passerby, bytes memory data) internal view virtual returns (bool checked);
}
