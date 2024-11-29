// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedERC721Policy} from "../advanced/AdvancedERC721Policy.sol";
import {AdvancedERC721Checker} from "../advanced/AdvancedERC721Checker.sol";
import {Check} from "../../interfaces/IAdvancedChecker.sol";

// This contract is a harness for testing the AdvancedERC721Policy contract.
// Deploy this contract and call its methods to test the internal methods of AdvancedERC721Policy.
contract AdvancedERC721PolicyHarness is AdvancedERC721Policy {
    constructor(AdvancedERC721Checker _checker) AdvancedERC721Policy(_checker) {}

    /// @notice Exposes the internal `_enforce` method for testing purposes.
    /// @param subject The address of those who have successfully enforced the check.
    /// @param evidence Additional data required for the check (e.g., encoded token identifier).
    /// @param checkType The type of the check to be enforced for the subject with the given data.
    function exposed__enforce(address subject, bytes calldata evidence, Check checkType) public onlyTarget {
        _enforce(subject, evidence, checkType);
    }
}
