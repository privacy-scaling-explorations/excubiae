// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {BaseERC721Policy} from "./BaseERC721Policy.sol";
import {Factory} from "../../core/proxy/Factory.sol";

/**
 * @title BaseERC721PolicyFactory
 * @notice Example factory for deploying minimal proxies of `BaseERC721Policy`.
 */
contract BaseERC721PolicyFactory is Factory {
    constructor() Factory(address(new BaseERC721Policy())) {}

    function deploy(address _checkerAddr) public {
        // 1. Encode.
        bytes memory data = abi.encode(msg.sender, _checkerAddr);

        // 2. Deploy the clone with appended data.
        address clone = super._deploy(data);

        // 3. Call `initialize()` so the clone sets up its owner (the factory) + checker reference.
        BaseERC721Policy(clone).initialize();
    }
}
