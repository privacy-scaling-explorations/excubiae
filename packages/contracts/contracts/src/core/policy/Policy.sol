// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPolicy} from "../interfaces/IPolicy.sol";
import {Clone} from "../proxy/Clone.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

abstract contract Policy is Clone, IPolicy, Ownable(msg.sender) {
    /// @notice The “gatekeeped” contract address set once by the owner (if at all).
    address internal target;

    function _initialize() internal virtual override {
        super._initialize();

        // By default, set the owner to the caller (likely the factory).
        // this is not the zero address as above!
        _transferOwnership(msg.sender);
    }

    /**
     * @notice Only the owner can call `setTarget` once.
     * @param _target The contract to be protected by this policy.
     */
    function setTarget(address _target) external virtual onlyOwner {
        if (_target == address(0)) revert ZeroAddress();
        if (target != address(0)) revert TargetAlreadySet();

        target = _target;
        emit TargetSet(_target);
    }

    /**
     * @notice A helper getter for the `target`.
     */
    function getTarget() external view returns (address) {
        return target;
    }

    /**
     * @notice A modifier that restricts a function to only be called by `target`.
     */
    modifier onlyTarget() {
        if (msg.sender != target) revert TargetOnly();
        _;
    }
}
