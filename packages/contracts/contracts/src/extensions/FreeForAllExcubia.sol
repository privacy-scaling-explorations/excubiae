// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseExcubia} from "../core/gatekeeper/BaseExcubia.sol";
import {FreeForAllChecker} from "./FreeForAllChecker.sol";

/// @title FreeForAll Excubia Contract.
/// @notice This contract extends the `Excubia` contract to allow free access through the `gate`.
/// @dev This contract does not perform any checks and allows any `passerby` to pass the `gate`.
/// It overrides the `_check` function to always return true, effectively granting unrestricted access.
contract FreeForAllExcubia is BaseExcubia {
    /// @notice Constructor for the FreeForAllExcubia contract.
    /// @param _freeForAllChecker The instance of the FreeForAllChecker contract used for validation.
    constructor(FreeForAllChecker _freeForAllChecker) BaseExcubia(_freeForAllChecker) {}

    /// @notice Returns the trait of the `Excubia` contract.
    /// @return A string representing the trait, which is "FreeForAll".
    function trait() external pure override returns (string memory) {
        return "FreeForAll";
    }
}
