// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {AdvancedERC721Policy} from "./AdvancedERC721Policy.sol";

/**
 * @title AdvancedERC721PolicyFactory
 * @notice Example factory for deploying minimal proxies of `AdvancedERC721Policy`.
 */
contract AdvancedERC721PolicyFactory {
    /// @notice Address of the "master" (implementation) policy.
    address public immutable advancedERC721PolicyImplementation;

    constructor() {
        // Deploy the logic contract once.
        // Or set it externally if already deployed.
        advancedERC721PolicyImplementation = address(new AdvancedERC721Policy());
    }

    /**
     * @notice Deploys a new minimal proxy clone, passing in `_checkerAddr` for initialization.
     * @param _checkerAddr The address of the BaseERC721Checker to use.
     * @return clone The address of the newly deployed clone.
     */
    function createERC721Policy(
        address _checkerAddr,
        bool _skipPre,
        bool _skipPost,
        bool _allowMultipleMain
    ) external returns (address clone) {
        // 1. Encode the checker address for appending.
        bytes memory data = abi.encode(msg.sender, _checkerAddr, _skipPre, _skipPost, _allowMultipleMain);

        // 2. Deploy the clone with appended data.
        clone = LibClone.clone(advancedERC721PolicyImplementation, data);

        // 3. Call `initialize()` so the clone sets up its owner (the factory) + checker reference.
        AdvancedERC721Policy(clone).initialize();
    }
}
