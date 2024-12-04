// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedChecker} from "../../AdvancedChecker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title AdvancedERC721Checker.
/// @notice Multi-phase ERC721 token validation.
/// @dev Implements pre, main, and post checks for NFTs.
contract AdvancedERC721Checker is AdvancedChecker {
    /// @notice Contract references and thresholds.
    IERC721 public immutable NFT;
    uint256 public immutable MIN_BALANCE;
    uint256 public immutable MIN_TOKEN_ID;
    uint256 public immutable MAX_TOKEN_ID;

    /// @notice Initializes checker with validation parameters.
    /// @param _nft ERC721 contract address.
    /// @param _minBalance Required token balance.
    /// @param _minTokenId Minimum valid token ID.
    /// @param _maxTokenId Maximum valid token ID.
    constructor(IERC721 _nft, uint256 _minBalance, uint256 _minTokenId, uint256 _maxTokenId) {
        NFT = _nft;
        MIN_BALANCE = _minBalance;
        MIN_TOKEN_ID = _minTokenId;
        MAX_TOKEN_ID = _maxTokenId;
    }

    /// @notice Validates basic token ownership.
    /// @param subject Address to validate.
    /// @param evidence Encoded tokenId.
    /// @return Token ownership status.
    function _checkPre(address subject, bytes memory evidence) internal view override returns (bool) {
        super._checkPre(subject, evidence);
        uint256 tokenId = abi.decode(evidence, (uint256));
        return NFT.ownerOf(tokenId) == subject;
    }

    /// @notice Validates minimum token balance.
    /// @param subject Address to validate.
    /// @param evidence Unused parameter.
    /// @return Balance threshold status.
    function _checkMain(address subject, bytes memory evidence) internal view override returns (bool) {
        super._checkMain(subject, evidence);
        return NFT.balanceOf(subject) >= MIN_BALANCE;
    }

    /// @notice Validates token ID range ownership.
    /// @param subject Address to validate.
    /// @param evidence Encoded tokenId.
    /// @return Token range validation status.
    function _checkPost(address subject, bytes memory evidence) internal view override returns (bool) {
        super._checkPost(subject, evidence);
        uint256 tokenId = abi.decode(evidence, (uint256));
        return tokenId >= MIN_TOKEN_ID && tokenId <= MAX_TOKEN_ID && NFT.ownerOf(tokenId) == subject;
    }
}
