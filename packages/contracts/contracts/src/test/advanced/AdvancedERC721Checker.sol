// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedChecker} from "../../core/checker/AdvancedChecker.sol";
import {BaseERC721Checker} from "../base/BaseERC721Checker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title AdvancedERC721Checker.
/// @notice Multi-phase NFT validation with aggregated verification contracts.
/// @dev Implements three-phase validation using multiple NFT contracts and external verifiers:
///      - Pre-check: Basic signup token validation using BaseERC721Checker.
///      - Main-check: Balance threshold validation for signup token.
///      - Post-check: Reward eligibility verification for reward token.
contract AdvancedERC721Checker is AdvancedChecker {
    /// @notice External contracts used for verification.
    /// @dev Immutable references derived from verifier array positions:
    ///      - Index 0: Signup NFT contract.
    ///      - Index 1: Reward NFT contract.
    ///      - Index 2: Base ERC721 checker contract.
    IERC721 public signupNft;
    IERC721 public rewardNft;
    BaseERC721Checker public baseERC721Checker;

    uint256 public minBalance;
    uint256 public minTokenId;
    uint256 public maxTokenId;

    function initialize() public virtual override {
        // 1. Call super to handle `_initialized` check.
        super.initialize();

        // 2. Retrieve appended bytes from the clone.
        bytes memory data = _getAppendedBytes();

        // 3. Decode everything in one shot:
        (
            address signupNftAddr,
            address rewardNftAddr,
            address baseCheckerAddr,
            uint256 minBalance_,
            uint256 minTokenId_,
            uint256 maxTokenId_
        ) = abi.decode(data, (address, address, address, uint256, uint256, uint256));

        // 4. Assign to storage variables.
        signupNft = IERC721(signupNftAddr);
        rewardNft = IERC721(rewardNftAddr);
        baseERC721Checker = BaseERC721Checker(baseCheckerAddr);
        minBalance = minBalance_;
        minTokenId = minTokenId_;
        maxTokenId = maxTokenId_;
    }

    /// @notice Pre-check: Validates initial NFT ownership.
    /// @dev Delegates basic ownership check to BaseERC721Checker.
    /// @param subject Address to validate.
    /// @param evidence Array containing encoded tokenId.
    /// @return Validation status from base checker.
    function _checkPre(address subject, bytes[] calldata evidence) internal view override returns (bool) {
        super._checkPre(subject, evidence);
        return baseERC721Checker.check(subject, evidence);
    }

    /// @notice Main-check: Validates token balance requirements.
    /// @dev Ensures subject has exactly MIN_BALANCE tokens.
    /// @param subject Address to validate.
    /// @param evidence Not used in balance check.
    /// @return True if balance meets requirements.
    function _checkMain(address subject, bytes[] calldata evidence) internal view override returns (bool) {
        super._checkMain(subject, evidence);
        return signupNft.balanceOf(subject) >= minBalance && signupNft.balanceOf(subject) <= minBalance;
    }

    /// @notice Post-check: Validates reward eligibility.
    /// @dev Ensures subject doesn't already have reward tokens.
    /// @param subject Address to validate.
    /// @param evidence Not used in reward check.
    /// @return True if subject eligible for rewards.
    function _checkPost(address subject, bytes[] calldata evidence) internal view override returns (bool) {
        super._checkPost(subject, evidence);
        return rewardNft.balanceOf(subject) == 0;
    }
}
