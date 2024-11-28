// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IBaseChecker} from "./interfaces/IBaseChecker.sol";

/// @title BaseChecker.
/// @notice Abstract base contract which can be extended to implement a specific `BaseChecker`.
/// @dev The `BaseChecker` contract provides a foundational structure for implementing specific checker logic.
/// It defines a method `check` that invokes a protected `_check` method, which must be implemented by derived
/// contracts.
abstract contract BaseChecker is IBaseChecker {
    /// @notice Checks the validity of the provided evidence for a given address.
    /// @param subject The address to be checked.
    /// @param evidence The evidence associated with the check.
    function check(address subject, bytes memory evidence) external view override returns (bool checked) {
        return _check(subject, evidence);
    }

    /// @notice Internal method to perform the actual check logic.
    /// @param subject The address to be checked.
    /// @param evidence The evidence associated with the check.
    function _check(address subject, bytes memory evidence) internal view virtual returns (bool checked) {}
}
