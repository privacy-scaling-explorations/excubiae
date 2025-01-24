// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedPolicy} from "../../core/policy/AdvancedPolicy.sol";
import {AdvancedERC721Checker} from "./AdvancedERC721Checker.sol";

/// @title AdvancedERC721Policy.
/// @notice Three-phase ERC721 validation policy.
/// @dev Enforces multi-stage checks through AdvancedERC721Checker.
contract AdvancedERC721Policy is AdvancedPolicy {
    /// @notice Returns policy identifier.
    function trait() external pure returns (string memory) {
        return "AdvancedERC721";
    }
}
