// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {FreeForAllExcubia} from "../../src/extensions/FreeForAllExcubia.sol";

// Deploy this contract then call its methods to test FreeForAllExcubia internal methods.
contract FreeForAllExcubiaHarness is FreeForAllExcubia {
    function exposed__trait() public pure {
        _trait();
    }

    function exposed__check(address passerby, bytes calldata data) public view {
        _check(passerby, data);
    }

    function exposed__pass(address passerby, bytes calldata data) public {
        _pass(passerby, data);
    }
}
