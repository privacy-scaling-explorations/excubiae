// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Checker} from "../../src/core/Checker.sol";
import {FreeForAllExcubia} from "../../src/extensions/FreeForAllExcubia.sol";
import {FreeForAllChecker} from "../../src/extensions/FreeForAllChecker.sol";

contract FreeForAllExcubiaHarness is FreeForAllExcubia {
    /// @notice Constructor for the FreeForAllExcubia contract.
    constructor(Checker _freeForAllChecker, uint8 _configFlags) FreeForAllExcubia(_freeForAllChecker, _configFlags) {}

    function exposed__trait() public pure {
        _trait();
    }
}
