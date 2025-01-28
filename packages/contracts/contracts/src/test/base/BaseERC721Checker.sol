// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseChecker} from "../../core/checker/BaseChecker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title BaseERC721Checker.
/// @notice ERC721 token ownership validator.
/// @dev Extends BaseChecker for NFT ownership verification.
contract BaseERC721Checker is BaseChecker {
    /// @notice NFT contract reference.
    IERC721 public nft;

    function _initialize() internal override {
        // 1. Call super to handle `_initialized` check.
        super._initialize();

        // 2. Retrieve appended bytes from the clone.
        bytes memory data = _getAppendedBytes();

        // 3. Decode as a single address.
        address nftAddress = abi.decode(data, (address));

        // 4. Store it in our storage variable.
        nft = IERC721(nftAddress);
    }

    /// @notice Validates token ownership.
    /// @param subject Address to check.
    /// @param evidence Encoded tokenId.
    /// @return True if subject owns token.
    function _check(address subject, bytes[] calldata evidence) internal view override returns (bool) {
        super._check(subject, evidence);
        uint256 tokenId = abi.decode(evidence[0], (uint256));
        return nft.ownerOf(tokenId) == subject;
    }
}
