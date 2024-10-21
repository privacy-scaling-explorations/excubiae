// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {FreeForAllChecker} from "../../src/extensions/FreeForAllChecker.sol";

// Deploy this contract then call its methods to test FreeForAllExcubia internal methods.
contract FreeForAllCheckerHarness is FreeForAllChecker {
    function exposed__check(address passerby, bytes calldata data) public view {
        _check(passerby, data);
    }
}
