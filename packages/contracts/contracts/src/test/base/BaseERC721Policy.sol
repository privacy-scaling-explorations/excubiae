// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BasePolicy} from "../../../src/BasePolicy.sol";
import {BaseERC721Checker} from "./BaseERC721Checker.sol";

/// @title BaseERC721Policy.
/// @notice Policy enforcer for ERC721 token validation.
/// @dev Extends BasePolicy with NFT-specific checks.
contract BaseERC721Policy is BasePolicy {
    /// @notice Checker contract reference.
    BaseERC721Checker public immutable CHECKER;

    /// @notice Initializes with checker contract.
    /// @param _checker Checker contract address.
    constructor(BaseERC721Checker _checker) BasePolicy(_checker) {
        CHECKER = BaseERC721Checker(_checker);
    }

    /// @notice Returns policy identifier.
    /// @return Policy trait string.
    function trait() external pure returns (string memory) {
        return "BaseERC721";
    }
}
