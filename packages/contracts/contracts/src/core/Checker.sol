// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IChecker} from "./IChecker.sol";

/// @title Checker.
/// @notice Abstract base contract which can be extended to implement specific criteria.
abstract contract Checker is IChecker, Ownable(msg.sender) {
    /// @inheritdoc IChecker
    function check(address passerby, bytes calldata data) external view {
        _check(passerby, data);
    }

    /// @notice Internal function to define the custom `gate` protection logic.
    /// @dev Custom logic to determine if the passerby can pass the `gate`.
    /// @param passerby The address of the entity attempting to pass the `gate`.
    /// @param data Additional data that may be required for the check.
    function _check(address passerby, bytes calldata data) internal view virtual {}
}
