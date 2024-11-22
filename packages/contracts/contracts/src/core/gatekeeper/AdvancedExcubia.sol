// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Excubia} from "./Excubia.sol";
import {IAdvancedExcubia, Check} from "./IAdvancedExcubia.sol";
import {AdvancedChecker, CheckStatus} from "../checker/AdvancedChecker.sol";

/// @title AdvancedExcubia
/// @notice Abstract base contract which can be extended to implement a specific `AdvancedExcubia`.
abstract contract AdvancedExcubia is IAdvancedExcubia, Excubia {
    /// @dev Reference to the AdvancedChecker contract for validation.
    AdvancedChecker public immutable ADVANCED_CHECKER;

    /// @dev Tracks the check status of each address.
    mapping(address => mapping(address => CheckStatus)) public isPassed;

    /// @notice Constructor to initialize the AdvancedChecker contract.
    /// @param _advancedChecker The address of the AdvancedChecker contract.
    constructor(AdvancedChecker _advancedChecker) {
        ADVANCED_CHECKER = _advancedChecker;
    }

    /// @notice Passes the gate check for a given address.
    /// @dev Calls the internal `_pass` function to enforce the gate logic.
    /// @param passerby The address attempting to pass the gate.
    /// @param data Additional data required for the check.
    /// @param checkType The type of check being performed (PRE, MAIN, POST).
    function pass(address passerby, bytes calldata data, Check checkType) external override onlyGate {
        _pass(passerby, data, checkType);
    }

    /// @notice Internal function to enforce the gate passing logic.
    /// @param passerby The address attempting to pass the gate.
    /// @param data Additional data required for the check.
    /// @param checkType The type of check being performed (PRE, MAIN, POST).
    function _pass(address passerby, bytes calldata data, Check checkType) internal {
        bool checked = ADVANCED_CHECKER.check(passerby, data, checkType);

        if (!checked) revert CheckNotPassed();

        if (checkType == Check.PRE) {
            if (ADVANCED_CHECKER.skipPre()) revert PreCheckSkipped();
            else if (isPassed[msg.sender][passerby].pre) revert AlreadyPassed();
            else isPassed[msg.sender][passerby].pre = true;
        } else if (checkType == Check.POST) {
            if (ADVANCED_CHECKER.skipPost()) revert PostCheckSkipped();
            else if (isPassed[msg.sender][passerby].post) revert AlreadyPassed();
            else isPassed[msg.sender][passerby].post = true;
        } else if (checkType == Check.MAIN) {
            if (!ADVANCED_CHECKER.allowMultipleMain() && isPassed[msg.sender][passerby].main > 0)
                revert MainCheckAlreadyEnforced();
            else isPassed[msg.sender][passerby].main += 1;
        }

        emit GatePassed(passerby, gate, data, checkType);
    }
}
