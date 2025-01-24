// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721Checker} from "./BaseERC721Checker.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

contract BaseERC721CheckerFactory {
    address public immutable erc721CheckerImplementation;

    constructor() {
        // Deploy the master ERC721Checker implementation once.
        erc721CheckerImplementation = address(new BaseERC721Checker());
    }

    function createERC721Checker(address _nftAddress) external returns (address clone) {
        // 1. Encode the address for appending.
        bytes memory data = abi.encode(_nftAddress);

        // 2. Deploy the clone with appended data.
        clone = LibClone.clone(erc721CheckerImplementation, data);

        // 3. Call initialize() so the new clone stores `_nftAddress` in `nft`.
        BaseERC721Checker(clone).initialize();
    }
}
