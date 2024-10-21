// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Excubia} from "../core/Excubia.sol";
import {FreeForAllChecker} from "./FreeForAllChecker.sol";

/// @title FreeForAll Excubia Contract.
/// @notice This contract extends the `Excubia` contract to allow free access through the `gate`.
/// This contract does not perform any checks and allows any `passerby` to pass the `gate`.
/// @dev The contract overrides the `_check` function to always return true.
contract FreeForAllExcubia is Excubia {
    FreeForAllChecker public checker;

    /// @notice Constructor for the FreeForAllExcubia contract.
    constructor(address _freeForAllChecker) {
        checker = FreeForAllChecker(_freeForAllChecker);
    }

    /// @notice Mapping to track already passed passersby.
    mapping(address => bool) public passedPassersby;

    /// @notice The trait of the `Excubia` contract.
    function _trait() internal pure override returns (string memory) {
        super._trait();

        return "FreeForAll";
    }

    /// @notice Internal function to handle the `gate` passing logic.
    /// @dev This function calls the parent `_pass` function and then tracks the `passerby`.
    /// @param passerby The address of the entity passing the `gate`.
    /// @param data Additional data required for the pass (not used in this implementation).
    function _pass(address passerby, bytes calldata data) internal override {
        // we need to manually enforce this.
        this.check(passerby, data);

        // Avoiding passing the `gate` twice with the same address.
        if (passedPassersby[passerby]) revert AlreadyPassed();

        passedPassersby[passerby] = true;

        super._pass(passerby, data);
    }

    /// @dev Defines the custom `gate` protection logic.
    /// @param passerby The address of the entity attempting to pass the `gate`.
    /// @param data Additional data that may be required for the check.
    function check(address passerby, bytes calldata data) external view {
        checker.check(passerby, data);
    }
}
