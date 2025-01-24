// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {BaseERC721Policy} from "./BaseERC721Policy.sol";

/**
 * @title BaseERC721PolicyFactory
 * @notice Example factory for deploying minimal proxies of `BaseERC721Policy`.
 */
contract BaseERC721PolicyFactory {
    /// @notice Address of the "master" (implementation) policy.
    address public immutable baseERC721PolicyImplementation;

    constructor() {
        // Deploy the logic contract once.
        // Or set it externally if already deployed.
        baseERC721PolicyImplementation = address(new BaseERC721Policy());
    }

    /**
     * @notice Deploys a new minimal proxy clone, passing in `_checkerAddr` for initialization.
     * @param _checkerAddr The address of the BaseERC721Checker to use.
     * @return clone The address of the newly deployed clone.
     */
    function createERC721Policy(address _checkerAddr) external returns (address clone) {
        // 1. Encode the checker address for appending.
        bytes memory data = abi.encode(msg.sender, _checkerAddr);

        // 2. Deploy the clone with appended data.
        clone = LibClone.clone(baseERC721PolicyImplementation, data);

        // 3. Call `initialize()` so the clone sets up its owner (the factory) + checker reference.
        BaseERC721Policy(clone).initialize();
    }
}
