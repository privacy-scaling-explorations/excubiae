// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {FreeForAllExcubia} from "../../src/extensions/FreeForAllExcubia.sol";

contract FreeForAllExcubiaTestWrapper is FreeForAllExcubia {
    function exposed_check(address passerby, bytes calldata data) public view {
        _check(passerby, data);
    }

    function exposed_pass(address passerby, bytes calldata data) public {
        _pass(passerby, data);
    }
}
