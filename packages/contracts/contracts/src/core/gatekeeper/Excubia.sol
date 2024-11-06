// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IExcubia} from "./IExcubia.sol";

/// @title Excubia abstract contract.
/// @dev This contract implements the IExcubia interface and manages the gate address.
abstract contract Excubia is IExcubia, Ownable(msg.sender) {
    /// @notice The Excubia-protected contract address.
    /// @dev The gate can be any contract address that requires a prior check to enable logic.
    /// For example, the gate is a Semaphore group that requires the passerby
    /// to meet certain criteria before joining.
    address public gate;

    /// @notice Modifier that restricts access to the gate address.
    modifier onlyGate() {
        if (msg.sender != gate) revert GateOnly();
        _;
    }

    /// @notice Sets the gate address.
    /// @dev Only the owner can set the destination `gate` address.
    /// @param _gate The address of the contract to be set as the gate.
    function setGate(address _gate) public virtual onlyOwner {
        if (_gate == address(0)) revert ZeroAddress();
        if (gate != address(0)) revert GateAlreadySet();

        gate = _gate;

        emit GateSet(_gate);
    }
}
