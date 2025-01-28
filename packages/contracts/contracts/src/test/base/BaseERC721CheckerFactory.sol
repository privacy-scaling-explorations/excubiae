// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721Checker} from "./BaseERC721Checker.sol";
import {Factory} from "../../core/proxy/Factory.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

contract BaseERC721CheckerFactory is Factory {
    constructor() Factory(address(new BaseERC721Checker())) {}

    function deploy(address _nftAddress) public {
        // 1. Encode the address for appending.
        bytes memory data = abi.encode(_nftAddress);

        // 2. Deploy the clone with appended data.
        address clone = super._deploy(data);

        // 3. Call initialize() so the new clone stores `_nftAddress` in `nft`.
        BaseERC721Checker(clone).initialize();
    }
}
