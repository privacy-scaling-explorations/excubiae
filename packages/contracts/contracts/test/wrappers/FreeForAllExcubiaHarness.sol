// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {FreeForAllExcubia} from "../../src/extensions/FreeForAllExcubia.sol";
import {FreeForAllChecker} from "../../src/extensions/FreeForAllChecker.sol";

// This contract is a harness for testing the FreeForAllExcubia contract.
// Deploy this contract and call its methods to test the internal methods of FreeForAllExcubia.
contract FreeForAllExcubiaHarness is FreeForAllExcubia {
    /// @notice Constructor for the FreeForAllExcubiaHarness contract.
    /// @param _freeForAllChecker The instance of the FreeForAllChecker contract used for validation.
    constructor(FreeForAllChecker _freeForAllChecker) FreeForAllExcubia(_freeForAllChecker) {}

    /// @notice Exposes the internal `_pass` method for testing purposes.
    /// @param passerby The address to be passed through the gate.
    /// @param data The data associated with the pass action.
    function exposed__pass(address passerby, bytes calldata data) public {
        _pass(passerby, data);
    }
}
