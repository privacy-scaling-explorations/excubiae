// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseChecker} from "../../../src/BaseChecker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title BaseERC721Checker
 * @notice Implements basic token ownership validation for ERC721 tokens.
 * @dev Extends BaseChecker to provide simple ownership verification.
 */
contract BaseERC721Checker is BaseChecker {
    IERC721 public immutable NFT;

    /**
     * @notice Initializes the checker with an ERC721 token contract.
     * @param _nft Address of the ERC721 contract to check against.
     */
    constructor(IERC721 _nft) {
        NFT = IERC721(_nft);
    }

    /**
     * @notice Checks if the subject owns the specified token.
     * @dev Validates if the subject is the owner of the tokenId provided in evidence.
     * @param subject Address to check ownership for.
     * @param evidence Encoded uint256 tokenId.
     * @return True if subject owns the token, false otherwise.
     */
    function _check(address subject, bytes memory evidence) internal view override returns (bool) {
        super._check(subject, evidence);

        uint256 tokenId = abi.decode(evidence, (uint256));
        return NFT.ownerOf(tokenId) == subject;
    }
}
