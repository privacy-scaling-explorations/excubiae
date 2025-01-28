// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPolicy} from "../interfaces/IPolicy.sol";
import {Clone} from "../proxy/Clone.sol";

/// @title Policy
/// @notice Abstract base contract for implementing policies to enforce access control.
/// @dev Extends Clone and Ownable to provide policy initialization, ownership, and target management.
abstract contract Policy is Clone, IPolicy, Ownable(msg.sender) {
    /// @notice The address of the contract being protected by the policy.
    /// @dev Can only be set once by the owner.
    address public target;

    /// @notice Modifier to restrict access to only the target contract.
    modifier onlyTarget() {
        if (msg.sender != target) revert TargetOnly();
        _;
    }

    /// @notice Initializes the contract and sets the owner.
    /// @dev Overrides Clone's `_initialize` to include owner setup.
    function _initialize() internal virtual override {
        super._initialize();

        // Sets the factory as the initial owner.
        _transferOwnership(msg.sender);
    }

    /// @notice Sets the contract address to be protected by this policy.
    /// @dev Can only be called once by the owner.
    /// @param _target The contract address to protect.
    function setTarget(address _target) external virtual onlyOwner {
        if (_target == address(0)) revert ZeroAddress();
        if (target != address(0)) revert TargetAlreadySet();

        target = _target;
        emit TargetSet(_target);
    }
}
