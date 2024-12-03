// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721Checker} from "../base/BaseERC721Checker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title BaseERC721CheckerHarness.
/// @notice Test harness for BaseERC721Checker internal methods.
contract BaseERC721CheckerHarness is BaseERC721Checker {
    /// @notice Initializes test harness with NFT contract.
    constructor(IERC721 _nft) BaseERC721Checker(_nft) {}

    /// @notice Test exposure for _check method.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Validation result.
    function exposed__check(address subject, bytes calldata evidence) public view returns (bool) {
        return _check(subject, evidence);
    }
}
