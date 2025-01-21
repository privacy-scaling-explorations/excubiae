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
    IERC721 public immutable SIGNUP_NFT;
    IERC721 public immutable REWARD_NFT;
    BaseERC721Checker public immutable BASE_ERC721_CHECKER;

    /// @notice Validation thresholds.
    uint256 public immutable MIN_BALANCE;
    uint256 public immutable MIN_TOKEN_ID;
    uint256 public immutable MAX_TOKEN_ID;

    /// @notice Initializes checker with verification chain.
    /// @dev Orders of verifiers array is crucial:
    ///      [signupNFT, rewardNFT, baseChecker]
    /// @param _verifiers Ordered array of verification contract addresses.
    /// @param _minBalance Required signup token balance.
    /// @param _minTokenId Lower bound for valid token IDs.
    /// @param _maxTokenId Upper bound for valid token IDs.
    constructor(
        address[] memory _verifiers,
        uint256 _minBalance,
        uint256 _minTokenId,
        uint256 _maxTokenId
    ) AdvancedChecker(_verifiers) {
        SIGNUP_NFT = IERC721(_getVerifierAtIndex(0));
        REWARD_NFT = IERC721(_getVerifierAtIndex(1));
        BASE_ERC721_CHECKER = BaseERC721Checker(_getVerifierAtIndex(2));
        MIN_BALANCE = _minBalance;
        MIN_TOKEN_ID = _minTokenId;
        MAX_TOKEN_ID = _maxTokenId;
    }

    /// @notice Pre-check: Validates initial NFT ownership.
    /// @dev Delegates basic ownership check to BaseERC721Checker.
    /// @param subject Address to validate.
    /// @param evidence Array containing encoded tokenId.
    /// @return Validation status from base checker.
    function _checkPre(address subject, bytes[] calldata evidence) internal view override returns (bool) {
        super._checkPre(subject, evidence);
        return BASE_ERC721_CHECKER.check(subject, evidence);
    }

    /// @notice Main-check: Validates token balance requirements.
    /// @dev Ensures subject has exactly MIN_BALANCE tokens.
    /// @param subject Address to validate.
    /// @param evidence Not used in balance check.
    /// @return True if balance meets requirements.
    function _checkMain(address subject, bytes[] calldata evidence) internal view override returns (bool) {
        super._checkMain(subject, evidence);
        return SIGNUP_NFT.balanceOf(subject) >= MIN_BALANCE && SIGNUP_NFT.balanceOf(subject) <= MIN_BALANCE;
    }

    /// @notice Post-check: Validates reward eligibility.
    /// @dev Ensures subject doesn't already have reward tokens.
    /// @param subject Address to validate.
    /// @param evidence Not used in reward check.
    /// @return True if subject eligible for rewards.
    function _checkPost(address subject, bytes[] calldata evidence) internal view override returns (bool) {
        super._checkPost(subject, evidence);
        return REWARD_NFT.balanceOf(subject) == 0;
    }
}
