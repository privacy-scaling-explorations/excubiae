// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedERC721Checker} from "./AdvancedERC721Checker.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";
import {Factory} from "../../core/proxy/Factory.sol";

contract AdvancedERC721CheckerFactory is Factory {
    constructor() Factory(address(new AdvancedERC721Checker())) {}

    function deploy(
        address _nftAddress,
        address _rewardNft,
        address _baseERC721Checker,
        uint256 _minBalance,
        uint256 _minTokenId,
        uint256 _maxTokenId
    ) public {
        // 1. Encode.
        bytes memory data = abi.encode(
            _nftAddress,
            _rewardNft,
            _baseERC721Checker,
            _minBalance,
            _minTokenId,
            _maxTokenId
        );

        // 2. Deploy.
        address clone = super._deploy(data);

        // 3. Call initialize().
        AdvancedERC721Checker(clone).initialize();
    }
}
