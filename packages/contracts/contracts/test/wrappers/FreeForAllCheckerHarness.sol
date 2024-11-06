// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {FreeForAllChecker} from "../../src/extensions/FreeForAllChecker.sol";

// This contract is a harness for testing the FreeForAllChecker contract.
// Deploy this contract and call its methods to test the internal methods of FreeForAllChecker.
contract FreeForAllCheckerHarness is FreeForAllChecker {
    /// @notice Exposes the internal `_check` method for testing purposes.
    /// @param passerby The address to be checked.
    /// @param data The data associated with the check.
    function exposed__check(address passerby, bytes calldata data) public view {
        _check(passerby, data);
    }
}
