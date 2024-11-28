// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedChecker} from "../../AdvancedChecker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title AdvancedERC721Checker
 * @notice Implements advanced checks for ERC721 token requirements.
 * @dev Extends AdvancedChecker to provide three-phase validation:
 *      - Pre-check: Basic token ownership verification.
 *      - Main check: Token balance threshold validation.
 *      - Post-check: Special token ID range verification.
 */
contract AdvancedERC721Checker is AdvancedChecker {
    IERC721 public immutable NFT;
    /// @notice Minimum token balance required for main check.
    uint256 public immutable MIN_BALANCE;
    /// @notice Minimum token ID allowed for post-check validation.
    uint256 public immutable MIN_TOKEN_ID;
    /// @notice Maximum token ID allowed for post-check validation.
    uint256 public immutable MAX_TOKEN_ID;

    constructor(
        IERC721 _nft,
        uint256 _minBalance,
        uint256 _minTokenId,
        uint256 _maxTokenId,
        bool _skipPre,
        bool _skipPost,
        bool _allowMultipleMain
    ) AdvancedChecker(_skipPre, _skipPost, _allowMultipleMain) {
        NFT = _nft;
        MIN_BALANCE = _minBalance;
        MIN_TOKEN_ID = _minTokenId;
        MAX_TOKEN_ID = _maxTokenId;
    }

    /**
     * @notice Pre-check verifies basic token ownership.
     * @dev Validates if the subject owns the specific tokenId provided in evidence.
     * @param subject Address to check ownership for.
     * @param evidence Encoded uint256 tokenId.
     * @return True if subject owns the token, false otherwise.
     */
    function _checkPre(address subject, bytes memory evidence) internal view override returns (bool) {
        super._checkPre(subject, evidence);

        uint256 tokenId = abi.decode(evidence, (uint256));
        return NFT.ownerOf(tokenId) == subject;
    }

    /**
     * @notice Main check verifies minimum token balance.
     * @dev Validates if the subject holds at least MIN_BALANCE tokens.
     * @param subject Address to check balance for.
     * @param evidence Not used in this check.
     * @return True if subject meets minimum balance requirement.
     */
    function _checkMain(address subject, bytes memory evidence) internal view override returns (bool) {
        super._checkMain(subject, evidence);

        return NFT.balanceOf(subject) >= MIN_BALANCE;
    }

    /**
     * @notice Post-check verifies ownership of a token within specific ID range.
     * @dev Validates if subject owns a token with ID between MIN_TOKEN_ID and MAX_TOKEN_ID.
     * @param subject Address to check ownership for.
     * @param evidence Encoded uint256 tokenId.
     * @return True if subject owns a token in valid range.
     */
    function _checkPost(address subject, bytes memory evidence) internal view override returns (bool) {
        super._checkPost(subject, evidence);

        uint256 tokenId = abi.decode(evidence, (uint256));
        return tokenId >= MIN_TOKEN_ID && tokenId <= MAX_TOKEN_ID && NFT.ownerOf(tokenId) == subject;
    }
}
