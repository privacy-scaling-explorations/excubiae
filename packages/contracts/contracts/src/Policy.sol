// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPolicy} from "./interfaces/IPolicy.sol";

/// @title Policy abstract contract.
/// @dev This contract implements the IPolicy interface and manages the target address.
abstract contract Policy is IPolicy, Ownable(msg.sender) {
    /// @notice The Policy-protected contract address.
    /// @dev The target can be any contract address that requires a prior check to enable logic.
    /// For example, the target is a Semaphore group that requires the subject
    /// to meet certain criteria before joining.
    address internal target;

    /// @notice Modifier that restricts access to the target address.
    modifier onlyTarget() {
        if (msg.sender != target) revert TargetOnly();
        _;
    }

    /// @notice Sets the target address.
    /// @dev Only the owner can set the destination `target` address.
    /// @param _target The address of the contract to be set as the target.
    function setTarget(address _target) public virtual onlyOwner {
        if (_target == address(0)) revert ZeroAddress();
        if (target != address(0)) revert TargetAlreadySet();

        target = _target;

        emit TargetSet(_target);
    }

    /// @notice Retrieves the current target address.
    /// @return The address of the current target.
    function getTarget() public view returns (address) {
        return target;
    }
}
