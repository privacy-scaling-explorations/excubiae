// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedPolicy} from "../../AdvancedPolicy.sol";
import {AdvancedERC721Checker} from "./AdvancedERC721Checker.sol";

/// @title AdvancedERC721Policy.
/// @notice Three-phase ERC721 validation policy.
/// @dev Enforces multi-stage checks through AdvancedERC721Checker.
contract AdvancedERC721Policy is AdvancedPolicy {
    /// @notice Initializes with checker contract.
    constructor(
        AdvancedERC721Checker _checker,
        bool _skipPre,
        bool _skipPost,
        bool _allowMultipleMain
    ) AdvancedPolicy(_checker, _skipPre, _skipPost, _allowMultipleMain) {
        ADVANCED_CHECKER = _checker;
    }

    /// @notice Returns policy identifier.
    function trait() external pure returns (string memory) {
        return "AdvancedERC721";
    }
}
