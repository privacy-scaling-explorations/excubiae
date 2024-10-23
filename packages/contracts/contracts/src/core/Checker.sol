// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IChecker} from "./IChecker.sol";

/// @title Checker.
/// @notice Abstract base contract which can be extended to implement specific criteria.
contract Checker is IChecker, Ownable(msg.sender) {
    // Enum to represent types of checks
    enum CheckType {
        PreCheck,
        MainCheck,
        PostCheck
    }

    /// @notice Check if the passerby can pass the pre-check.
    /// @param passerby The address of the entity attempting to pass the pre-check.
    function checkPre(address passerby, bytes memory data) external view {
        _checkPre(passerby, data);
    }

    /// @notice Check if the passerby can pass the main check.
    /// @param passerby The address of the entity attempting to pass the main check.
    function checkMain(address passerby, bytes memory data) external view {
        _checkMain(passerby, data);
    }

    /// @notice Check if the passerby can pass the post-check.
    /// @param passerby The address of the entity attempting to pass the post-check.
    function checkPost(address passerby, bytes memory data) external view {
        _checkPost(passerby, data);
    }

    // Internal methods for actual check logic
    function _checkPre(address passerby, bytes memory data) internal view virtual {}

    function _checkMain(address passerby, bytes memory data) internal view virtual {}

    function _checkPost(address passerby, bytes memory data) internal view virtual {}
}
