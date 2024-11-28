// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedERC721Checker} from "../advanced/AdvancedERC721Checker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Check} from "../../interfaces/IAdvancedChecker.sol";

// This contract is a harness for testing the AdvancedERC721Checker contract.
// Deploy this contract and call its methods to test the internal methods of AdvancedERC721Checker.
contract AdvancedERC721CheckerHarness is AdvancedERC721Checker {
    constructor(
        IERC721 _nft,
        uint256 _minBalance,
        uint256 _minTokenId,
        uint256 _maxTokenId,
        bool _skipPre,
        bool _skipPost,
        bool _allowMultipleMain
    ) AdvancedERC721Checker(_nft, _minBalance, _minTokenId, _maxTokenId, _skipPre, _skipPost, _allowMultipleMain) {}

    /// @notice Exposes the internal `_check` method for testing purposes.
    /// @param subject The address to be checked.
    /// @param evidence The data associated with the check.
    /// @param checkType The type of check to perform (PRE, MAIN, POST).
    function exposed__check(address subject, bytes calldata evidence, Check checkType) public view returns (bool) {
        return _check(subject, evidence, checkType);
    }

    /// @notice Exposes the internal `_checkPre` method for testing purposes.
    /// @param subject The address to be checked.
    /// @param evidence The data associated with the check.
    function exposed__checkPre(address subject, bytes calldata evidence) public view returns (bool) {
        return _checkPre(subject, evidence);
    }

    /// @notice Exposes the internal `_checkMain` method for testing purposes.
    /// @param subject The address to be checked.
    /// @param evidence The data associated with the check.
    function exposed__checkMain(address subject, bytes calldata evidence) public view returns (bool) {
        return _checkMain(subject, evidence);
    }

    /// @notice Exposes the internal `_checkPost` method for testing purposes.
    /// @param subject The address to be checked.
    /// @param evidence The data associated with the check.
    function exposed__checkPost(address subject, bytes calldata evidence) public view returns (bool) {
        return _checkPost(subject, evidence);
    }
}
