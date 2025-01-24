// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedERC721Checker} from "./AdvancedERC721Checker.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

contract AdvancedERC721CheckerFactory {
    address public immutable erc721CheckerImplementation;

    constructor() {
        // Deploy the master ERC721Checker implementation once.
        erc721CheckerImplementation = address(new AdvancedERC721Checker());
    }

    function createERC721Checker(
        address _nftAddress,
        address _rewardNft,
        address _baseERC721Checker,
        uint256 _minBalance,
        uint256 _minTokenId,
        uint256 _maxTokenId
    ) external returns (address clone) {
        // 1. Encode the address for appending.
        bytes memory data = abi.encode(
            _nftAddress,
            _rewardNft,
            _baseERC721Checker,
            _minBalance,
            _minTokenId,
            _maxTokenId
        );

        // 2. Deploy the clone with appended data.
        clone = LibClone.clone(erc721CheckerImplementation, data);

        // 3. Call initialize() so the new clone stores `_nftAddress` in `nft`.
        AdvancedERC721Checker(clone).initialize();
    }
}
