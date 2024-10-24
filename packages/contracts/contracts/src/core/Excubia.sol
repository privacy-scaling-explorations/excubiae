// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IExcubia} from "./IExcubia.sol";
import {Checker, CheckType} from "./Checker.sol";

/// @title Excubia
/// @notice Contract to manage gate-passing logic.
abstract contract Excubia is IExcubia, Ownable(msg.sender) {
    // Enum to represent execution status
    struct ExecutionStatus {
        bool preExecuted;
        uint8 continueExecuted;
        bool postExecuted;
    }

    // Mapping to track execution status for each passerby
    mapping(address => ExecutionStatus) public executionStatuses;

    // Reference to the Checker contract (immutable for gas optimization)
    Checker public immutable checker;

    // Configuration flags packed into a single uint8 to save gas
    uint8 public configFlags;

    // Gate address
    address public gate;

    // Configuration constants for bit manipulation
    uint8 constant SKIP_PRE_CHECK = 1 << 0;
    uint8 constant SKIP_POST_CHECK = 1 << 1;
    uint8 constant ALLOW_MULTIPLE_CONTINUE_CHECK = 1 << 2;

    // Constructor to set the configuration flags and initialize the Checker contract
    constructor(Checker _checkerAddress, uint8 _configFlags) {
        configFlags = _configFlags;
        checker = Checker(_checkerAddress);
    }

    /// @dev Modifier to restrict function calls to only from the gate address.
    modifier onlyGate() {
        if (msg.sender != gate) revert GateOnly();
        _;
    }

    /// @inheritdoc IExcubia
    function trait() external pure returns (string memory) {
        return _trait();
    }

    function setGate(address _gate) public onlyOwner {
        if (_gate == address(0)) revert ZeroAddress();
        if (gate != address(0)) revert GateAlreadySet();

        gate = _gate;

        emit GateSet(_gate);
    }

    /// @notice Internal function to define the trait of the Excubia contract.
    /// @dev maintain consistency across `_pass` & `_check` definitions.
    /// @return The specific trait of the Excubia contract (e.g., SemaphoreExcubia has trait Semaphore).
    function _trait() internal pure virtual returns (string memory) {}

    function passCheck(address passerby, bytes calldata data, uint8 checkType) external virtual onlyGate {
        _passCheck(passerby, data, checkType);
    }

    /// @notice Pass a check (pre, continue, or post).
    /// @param passerby The address of the entity attempting to pass the check.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    /// @param checkType The type of check to perform (0: pre, 1: continue, 2: post).
    function _passCheck(address passerby, bytes calldata data, uint8 checkType) internal onlyGate {
        if (checkType == uint8(CheckType.PreCheck)) {
            // Pre-check
            if ((configFlags & SKIP_PRE_CHECK) != 0) revert("Pre-check skipped");
            checker.checkPre(passerby, data);
            executionStatuses[passerby].preExecuted = true;
        } else if (checkType == uint8(CheckType.ContinueCheck)) {
            // Continue check
            if ((configFlags & SKIP_PRE_CHECK) == 0) assert(executionStatuses[passerby].preExecuted);
            ExecutionStatus storage status = executionStatuses[passerby];
            if ((configFlags & ALLOW_MULTIPLE_CONTINUE_CHECK) == 0) {
                require(status.continueExecuted >= 1, "Already passed continue check");
            }
            checker.checkContinue(passerby, data);
            status.continueExecuted += 1;
        } else if (checkType == uint8(CheckType.PostCheck)) {
            // Post-check
            if ((configFlags & SKIP_POST_CHECK) != 0) revert("Post-check skipped");
            if ((configFlags & SKIP_PRE_CHECK) == 0)
                assert(executionStatuses[passerby].preExecuted && executionStatuses[passerby].continueExecuted >= 1);
            checker.checkPost(passerby, data);
            executionStatuses[passerby].postExecuted = true;
        } else {
            revert("Invalid check type");
        }
        emit GatePassed(passerby, data);
    }
}
