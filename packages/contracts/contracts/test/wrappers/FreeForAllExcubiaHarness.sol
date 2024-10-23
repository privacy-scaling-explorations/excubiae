// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Checker} from "../../src/core/Checker.sol";
import {FreeForAllExcubia} from "../../src/extensions/FreeForAllExcubia.sol";
import {FreeForAllChecker} from "../../src/extensions/FreeForAllChecker.sol";

contract FreeForAllExcubiaHarness is FreeForAllExcubia {
    /// @notice Constructor for the FreeForAllExcubia contract.
    constructor(
        Checker _freeForAllChecker,
        bool _skipPreCheck,
        bool _skipPostCheck,
        bool _allowMultipleMainCheckPasses
    ) FreeForAllExcubia(_freeForAllChecker, _skipPreCheck, _skipPostCheck, _allowMultipleMainCheckPasses) {}

    function exposed__trait() public pure {
        _trait();
    }
}
