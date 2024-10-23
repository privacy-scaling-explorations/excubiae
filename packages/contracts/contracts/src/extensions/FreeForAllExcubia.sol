// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Excubia} from "../core/Excubia.sol";
import {Checker} from "../core/Checker.sol";
import {FreeForAllChecker} from "./FreeForAllChecker.sol";

/// @title FreeForAll Excubia Contract.
/// @notice This contract extends the `Excubia` contract to allow free access through the `gate`.
/// This contract does not perform any checks and allows any `passerby` to pass the `gate`.
/// @dev The contract overrides the `_check` function to always return true.
contract FreeForAllExcubia is Excubia {
    /// @notice Constructor for the FreeForAllExcubia contract.
    constructor(
        Checker _freeForAllChecker,
        bool _skipPreCheck,
        bool _skipPostCheck,
        bool _allowMultipleMainCheckPasses
    ) Excubia(_freeForAllChecker, true, true, true) {}

    /// @notice The trait of the `Excubia` contract.
    function _trait() internal pure override returns (string memory) {
        super._trait();

        return "FreeForAll";
    }
}
