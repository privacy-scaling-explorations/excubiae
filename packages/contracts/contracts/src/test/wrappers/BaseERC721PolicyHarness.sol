// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseERC721Policy} from "../base/BaseERC721Policy.sol";
import {BaseERC721Checker} from "../base/BaseERC721Checker.sol";

// This contract is a harness for testing the BaseERC721Policy contract.
// Deploy this contract and call its methods to test the internal methods of BaseERC721Policy.
contract BaseERC721PolicyHarness is BaseERC721Policy {
    constructor(BaseERC721Checker _checker) BaseERC721Policy(_checker) {}

    /// @notice Exposes the internal `_enforce` method for testing purposes.
    /// @param subject The address to be checked.
    /// @param evidence The data associated with the check.
    function exposed__enforce(address subject, bytes calldata evidence) public onlyTarget {
        _enforce(subject, evidence);
    }
}
