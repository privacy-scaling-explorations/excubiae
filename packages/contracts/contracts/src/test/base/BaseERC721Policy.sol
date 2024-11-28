// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BasePolicy} from "../../../src/BasePolicy.sol";
import {BaseERC721Checker} from "./BaseERC721Checker.sol";

/**
 * @title BaseERC721Policy
 * @notice Policy contract for basic ERC721 token validation.
 * @dev Extends BasePolicy to enforce NFT ownership checks.
 */
contract BaseERC721Policy is BasePolicy {
    /// @notice Reference to the checker contract for token validation.
    BaseERC721Checker public immutable CHECKER;

    constructor(BaseERC721Checker _checker) BasePolicy(_checker) {
        CHECKER = BaseERC721Checker(_checker);
    }

    /// @notice Returns the trait identifier for this policy.
    function trait() external pure returns (string memory) {
        return "BaseERC721";
    }
}
