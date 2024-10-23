// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IExcubia} from "./IExcubia.sol";
import {Checker} from "./Checker.sol";

/// @title Excubia
/// @notice Contract to manage gate-passing logic.
abstract contract Excubia is IExcubia, Ownable(msg.sender) {
    // Enum to represent execution status
    struct ExecutionStatus {
        bool preExecuted;
        bool mainExecuted;
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
    uint8 constant ALLOW_MULTIPLE_MAIN_CHECK = 1 << 2;

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

    /// @notice Pass the pre-check.
    /// @param passerby The address of the entity attempting to pass the pre-check.
    function passPreCheck(address passerby, bytes calldata data) external onlyGate {
        if ((configFlags & SKIP_PRE_CHECK) != 0) revert("Pre-check skipped");
        checker.checkPre(passerby, data); // Call pre-check
        executionStatuses[passerby].preExecuted = true; // Update status to PreExecuted
        emit GatePassed(passerby, data); // Emit event for passing the gate
    }

    /// @notice Pass the main check.
    /// @param passerby The address of the entity attempting to pass the main check.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    function passMainCheck(address passerby, bytes calldata data) external onlyGate {
        ExecutionStatus storage status = executionStatuses[passerby];
        if ((configFlags & ALLOW_MULTIPLE_MAIN_CHECK) == 0) {
            require(!status.mainExecuted, "Already passed main check");
        }
        checker.checkMain(passerby, data); // Call main check
        status.mainExecuted = true; // Update status to CheckExecuted
        emit GatePassed(passerby, data); // Emit event for passing the gate
    }

    /// @notice Pass the post-check.
    /// @param passerby The address of the entity attempting to pass the post-check.
    function passPostCheck(address passerby, bytes calldata data) external onlyGate {
        if ((configFlags & SKIP_POST_CHECK) != 0) revert("Post-check skipped");
        checker.checkPost(passerby, data); // Call post-check
        executionStatuses[passerby].postExecuted = true; // Update status to PostExecuted
        emit GatePassed(passerby, data); // Emit event for passing the gate
    }

    /// @dev Helper function to check if the pre-check should be skipped.
    function skipPreCheck() internal view returns (bool) {
        return (configFlags & SKIP_PRE_CHECK) != 0;
    }

    /// @dev Helper function to check if the post-check should be skipped.
    function skipPostCheck() internal view returns (bool) {
        return (configFlags & SKIP_POST_CHECK) != 0;
    }

    /// @dev Helper function to check if multiple main checks are allowed.
    function allowMultipleMainCheckPasses() internal view returns (bool) {
        return (configFlags & ALLOW_MULTIPLE_MAIN_CHECK) != 0;
    }
}
