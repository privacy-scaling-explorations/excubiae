// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseChecker} from "../../../src/BaseChecker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title BaseERC721Checker.
/// @notice ERC721 token ownership validator.
/// @dev Extends BaseChecker for NFT ownership verification.
contract BaseERC721Checker is BaseChecker {
    /// @notice NFT contract reference.
    IERC721 public immutable NFT;

    /// @notice Initializes with ERC721 contract.
    /// @param _nft ERC721 contract address.
    constructor(IERC721 _nft) {
        NFT = IERC721(_nft);
    }

    /// @notice Validates token ownership.
    /// @param subject Address to check.
    /// @param evidence Encoded tokenId.
    /// @return True if subject owns token.
    function _check(address subject, bytes memory evidence) internal view override returns (bool) {
        super._check(subject, evidence);
        uint256 tokenId = abi.decode(evidence, (uint256));
        return NFT.ownerOf(tokenId) == subject;
    }
}
