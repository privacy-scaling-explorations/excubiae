// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseChecker} from "../../src/BaseChecker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract BaseERC721Checker is BaseChecker {
    IERC721 public immutable NFT;

    constructor(IERC721 _nft) {
        NFT = IERC721(_nft);
    }

    function _check(address subject, bytes memory evidence) internal view override returns (bool) {
        // Decode the tokenId from the evidence.
        uint256 tokenId = abi.decode(evidence, (uint256));

        // Return true if the subject is the owner of the tokenId, false otherwise.
        return NFT.ownerOf(tokenId) == subject;
    }
}
