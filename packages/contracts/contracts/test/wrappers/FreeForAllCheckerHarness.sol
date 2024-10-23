// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {FreeForAllChecker} from "../../src/extensions/FreeForAllChecker.sol";

// Deploy this contract then call its methods to test FreeForAllExcubia internal methods.
contract FreeForAllCheckerHarness is FreeForAllChecker {
    function exposed__checkPre(address passerby, bytes memory data) public view {
        _checkPre(passerby, data);
    }

    function exposed__checkMain(address passerby, bytes memory data) public view {
        _checkMain(passerby, data);
    }

    function exposed__checkPost(address passerby, bytes memory data) public view {
        _checkPost(passerby, data);
    }
}
