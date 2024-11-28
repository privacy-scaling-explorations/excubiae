// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedPolicy} from "../../AdvancedPolicy.sol";
import {AdvancedERC721Checker} from "./AdvancedERC721Checker.sol";

/**
 * @title AdvancedERC721Policy
 * @notice Policy contract implementing three-phase validation for ERC721 tokens.
 * @dev Extends AdvancedPolicy to enforce ERC721-specific checks through AdvancedERC721Checker.
 */
contract AdvancedERC721Policy is AdvancedPolicy {
    /// @notice Reference to the ERC721 checker contract implementing validation logic.
    AdvancedERC721Checker public immutable CHECKER;

    /// @param _checker Address of the AdvancedERC721Checker contract.
    constructor(AdvancedERC721Checker _checker) AdvancedPolicy(_checker) {
        CHECKER = _checker;
    }

    /// @notice Returns the trait identifier for this policy.
    /// @return String identifying this as an ERC721-based policy.
    function trait() external pure returns (string memory) {
        return "AdvancedERC721";
    }
}
