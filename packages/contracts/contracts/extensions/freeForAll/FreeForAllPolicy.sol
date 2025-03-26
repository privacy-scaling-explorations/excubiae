// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BasePolicy} from "../../policy/BasePolicy.sol";

/// @title FreeForAllPolicy
/// @notice A policy which allows anyone to sign up.
contract FreeForAllPolicy is BasePolicy {
    /// @notice Create a new instance of FreeForAllPolicy
    // solhint-disable-next-line no-empty-blocks
    constructor() payable {}

    /// @notice Get the trait of the Policy
    /// @return The type of the Policy
    function trait() public pure override returns (string memory) {
        return "FreeForAll";
    }
}
