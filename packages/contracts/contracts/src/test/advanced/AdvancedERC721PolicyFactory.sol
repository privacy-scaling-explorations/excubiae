// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {AdvancedERC721Policy} from "./AdvancedERC721Policy.sol";
import {Factory} from "../../core/proxy/Factory.sol";

/**
 * @title AdvancedERC721PolicyFactory
 * @notice Example factory for deploying minimal proxies of `AdvancedERC721Policy`.
 */
contract AdvancedERC721PolicyFactory is Factory {
    constructor() Factory(address(new AdvancedERC721Policy())) {}

    function deploy(address _checkerAddr, bool _skipPre, bool _skipPost, bool _allowMultipleMain) public {
        // 1. Encode.
        bytes memory data = abi.encode(msg.sender, _checkerAddr, _skipPre, _skipPost, _allowMultipleMain);

        // 2. Deploy.
        address clone = super._deploy(data);

        // 3. Call `initialize()`.
        AdvancedERC721Policy(clone).initialize();
    }
}
