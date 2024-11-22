// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {IBaseExcubia} from "./IBaseExcubia.sol";
import {Excubia} from "./Excubia.sol";
import {BaseChecker} from "../checker/BaseChecker.sol";

/// @title BaseExcubia
/// @notice Abstract base contract which can be extended to implement a specific `BaseExcubia`.
abstract contract BaseExcubia is Excubia, IBaseExcubia {
    /// @dev Reference to the BaseChecker contract for validation.
    BaseChecker public immutable BASE_CHECKER;

    /// @dev Tracks whether an address has passed the gate check.
    mapping(address => mapping(address => bool)) public isPassed;

    /// @notice Constructor to initialize the BaseChecker contract.
    /// @param _baseChecker The address of the BaseChecker contract.
    constructor(BaseChecker _baseChecker) {
        BASE_CHECKER = _baseChecker;
    }

    /// @notice Passes the gate check for a given address.
    /// @dev Calls the internal `_pass` function to enforce the gate logic.
    /// @param passerby The address attempting to pass the gate.
    /// @param data Additional data required for the check.
    function pass(address passerby, bytes calldata data) external override onlyGate {
        _pass(passerby, data);
    }

    /// @notice Internal function to enforce the gate passing logic.
    /// @param passerby The address attempting to pass the gate.
    /// @param data Additional data required for the check.
    function _pass(address passerby, bytes calldata data) internal {
        BASE_CHECKER.check(passerby, data);

        if (isPassed[msg.sender][passerby]) revert AlreadyPassed();

        isPassed[msg.sender][passerby] = true;

        emit GatePassed(passerby, gate, data);
    }
}
