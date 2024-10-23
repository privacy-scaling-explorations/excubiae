// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IExcubia} from "./IExcubia.sol";
import {Checker} from "./Checker.sol";

/// @title Excubia
/// @notice Contract to manage gate-passing logic.
abstract contract Excubia is IExcubia, Ownable(msg.sender) {
    // Enum to represent execution status
    enum ExecutionStatus {
        None,
        PreExecuted,
        CheckExecuted,
        PostExecuted
    }

    // Mapping to track execution status for each passerby
    mapping(address => ExecutionStatus) public executionStatus;

    // Reference to the Checker contract
    Checker public checker;

    // Configuration variables for skipping checks
    bool public skipPreCheckConfig;
    bool public skipPostCheckConfig;

    // Flag to determine if the main check can be passed multiple times
    bool public allowMultipleMainCheckPasses;

    address public gate;

    // Constructor to set the configuration for skipping checks and initialize the Checker contract
    constructor(Checker _checkerAddress, bool _skipPreCheck, bool _skipPostCheck, bool _allowMultipleMainCheckPasses) {
        skipPreCheckConfig = _skipPreCheck;
        skipPostCheckConfig = _skipPostCheck;
        allowMultipleMainCheckPasses = _allowMultipleMainCheckPasses;
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

    /// @notice Pass the pre-check.
    /// @param passerby The address of the entity attempting to pass the pre-check.
    function passPreCheck(address passerby, bytes calldata data) external onlyGate {
        require(!skipPreCheckConfig, "Pre-check skipped");
        checker.checkPre(passerby, data); // Call pre-check
        executionStatus[passerby] = ExecutionStatus.PreExecuted; // Update status to PreExecuted
        emit GatePassed(passerby, data); // Emit event for passing the gate
    }

    /// @notice Pass the main check.
    /// @param passerby The address of the entity attempting to pass the main check.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    function passMainCheck(address passerby, bytes calldata data) external onlyGate {
        if (!allowMultipleMainCheckPasses) {
            require(executionStatus[passerby] != ExecutionStatus.CheckExecuted, "Already passed main check");
        }
        checker.checkMain(passerby, data); // Call main check
        executionStatus[passerby] = ExecutionStatus.CheckExecuted; // Update status to CheckExecuted
        emit GatePassed(passerby, data); // Emit event for passing the gate
    }

    /// @notice Pass the post-check.
    /// @param passerby The address of the entity attempting to pass the post-check.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    function passPostCheck(address passerby, bytes calldata data) external onlyGate {
        require(!skipPostCheckConfig, "Post-check skipped");
        checker.checkPost(passerby, data); // Call post-check
        executionStatus[passerby] = ExecutionStatus.PostExecuted; // Update status to PostExecuted
        emit GatePassed(passerby, data); // Emit event for passing the gate
    }
}
