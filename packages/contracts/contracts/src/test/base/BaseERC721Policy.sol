// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BasePolicy} from "../../core/policy/BasePolicy.sol";

/**
 * @title BaseERC721Policy
 * @notice Policy enforcer for ERC721 token validation, built on top of BasePolicy.
 * @dev In a minimal proxy context, we remove the constructor arguments and use `initialize()`.
 */
contract BaseERC721Policy is BasePolicy {
    /**
     * @notice A sample policy identifier.
     */
    function trait() external pure returns (string memory) {
        return "BaseERC721";
    }
}
