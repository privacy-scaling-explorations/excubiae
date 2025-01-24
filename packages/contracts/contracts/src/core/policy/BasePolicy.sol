// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBasePolicy} from "../interfaces/IBasePolicy.sol";
import {Policy} from "./Policy.sol";
import {BaseChecker} from "../checker/BaseChecker.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

/// @title BasePolicy
/// @notice Abstract base contract for implementing specific policy checks.
/// @dev Inherits from Policy and implements IBasePolicy interface.
///      Now uses an `initialize()` function for minimal proxy clones.
abstract contract BasePolicy is Policy, IBasePolicy {
    /// @notice Reference to the BaseChecker contract used for validation.
    /// @dev Stored in normal storage (not immutable) so it can be set in `initialize()`.
    BaseChecker public BASE_CHECKER;

    /// @notice Tracks enforcement status for each subject per target.
    mapping(address => bool) public enforced;

    /**
     * @notice Initializes the contract with a BaseChecker instance, reading from appended bytes.
     *         Replaces the old constructor-based approach.
     */
    function initialize() public virtual override {
        // 1. Call the base `Policy.initialize()` to set ownership / handle `_initialized`.
        super.initialize();

        // 2. Decode the appended bytes to get the BaseChecker address (and anything else you might need).
        bytes memory data = _getAppendedBytes();
        (address sender, address baseCheckerAddr) = abi.decode(data, (address, address));

        _transferOwnership(sender);

        // 3. Store in the contract’s storage (previously `immutable`).
        BASE_CHECKER = BaseChecker(baseCheckerAddr);
    }

    /// @notice External function to enforce policy checks.
    /// @dev Only callable by the target contract.
    /// @param subject Address to enforce the check on.
    /// @param evidence Additional data required for verification.
    function enforce(address subject, bytes[] calldata evidence) external override onlyTarget {
        _enforce(subject, evidence);
    }

    /// @notice Internal implementation of enforcement logic.
    function _enforce(address subject, bytes[] memory evidence) internal {
        bool checked = BASE_CHECKER.check(subject, evidence);

        if (enforced[subject]) revert AlreadyEnforced();
        if (!checked) revert UnsuccessfulCheck();

        enforced[subject] = true;

        emit Enforced(subject, target, evidence);
    }
}
