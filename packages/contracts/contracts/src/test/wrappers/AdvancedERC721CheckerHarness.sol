// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedERC721Checker} from "../advanced/AdvancedERC721Checker.sol";
import {Check} from "../../core/interfaces/IAdvancedChecker.sol";
// @todo refactoring
/// @title AdvancedERC721CheckerHarness.
/// @notice Test harness exposing internal methods of AdvancedERC721Checker.
/// @dev Inherits AdvancedERC721Checker and exposes protected methods for testing.
contract AdvancedERC721CheckerHarness is AdvancedERC721Checker {
    /// @notice Initializes test harness with checker configuration.
    /// @param _verifiers Array of addresses for existing verification contracts.
    /// @param _minBalance Minimum token balance required.
    /// @param _minTokenId Minimum valid token ID.
    /// @param _maxTokenId Maximum valid token ID.
    // constructor(
    //     address[] memory _verifiers,
    //     uint256 _minBalance,
    //     uint256 _minTokenId,
    //     uint256 _maxTokenId
    // ) AdvancedERC721Checker(_verifiers, _minBalance, _minTokenId, _maxTokenId) {}
    /// @notice Test exposure for _check method.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @param checkType Type of check to perform.
    /// @return Validation result.
    // function exposed__check(address subject, bytes[] calldata evidence, Check checkType) public view returns (bool) {
    //     return _check(subject, evidence, checkType);
    // }
    /// @notice Test exposure for _checkPre method.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Pre-check validation result.
    // function exposed__checkPre(address subject, bytes[] calldata evidence) public view returns (bool) {
    //     return _checkPre(subject, evidence);
    // }
    /// @notice Test exposure for _checkMain method.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Main validation result.
    // function exposed__checkMain(address subject, bytes[] calldata evidence) public view returns (bool) {
    //     return _checkMain(subject, evidence);
    // }
    /// @notice Test exposure for _checkPost method.
    /// @param subject Address to validate.
    /// @param evidence Validation data.
    /// @return Post-check validation result.
    // function exposed__checkPost(address subject, bytes[] calldata evidence) public view returns (bool) {
    //     return _checkPost(subject, evidence);
    // }
    /// @notice Test exposure for _getVerifierAtIndex method.
    /// @param index The index of the verifier in the array.
    /// @return The address of the verifier at the specified index.
    /// @custom:throws VerifierNotFound if no address have been specified at given index.
    // function exposed__getVerifierAtIndex(uint256 index) public view returns (address) {
    //     return _getVerifierAtIndex(index);
    // }
}
