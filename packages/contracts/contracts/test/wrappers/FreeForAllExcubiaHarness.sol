// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {FreeForAllExcubia} from "../../src/extensions/FreeForAllExcubia.sol";
import {FreeForAllChecker} from "../../src/extensions/FreeForAllChecker.sol";

contract FreeForAllExcubiaHarness is FreeForAllExcubia {
    /// @notice Constructor for the FreeForAllExcubia contract.
    constructor(address _freeForAllChecker) FreeForAllExcubia(_freeForAllChecker) {}

    function exposed__trait() public pure {
        _trait();
    }

    function exposed__pass(address passerby, bytes calldata data) public {
        _pass(passerby, data);
    }
}
