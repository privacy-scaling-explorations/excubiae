// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {BasePolicy} from "../../policy/BasePolicy.sol";

/// @title SignUpTokenPolicy
/// @notice This contract allows to gatekeep MACI signups
/// by requiring new voters to own a certain ERC721 token
contract SignUpTokenPolicy is BasePolicy {
    /// @notice a mapping of tokenIds to whether they have been used to sign up
    mapping(uint256 => bool) public registeredTokenIds;

    /// @notice creates a new SignUpTokenPolicy
    // solhint-disable-next-line no-empty-blocks
    constructor() payable {}

    /// @notice Registers the user if they own the token with the token ID encoded in
    /// _data. Throws if the user does not own the token or if the token has
    /// already been used to sign up.
    /// @param _subject The user's Ethereum address.
    /// @param _evidence The ABI-encoded tokenId as a uint256.
    function _enforce(address _subject, bytes calldata _evidence) internal override {
        // Decode the given _data bytes into a uint256 which is the token ID
        uint256 tokenId = abi.decode(_evidence, (uint256));

        // Check if the token has already been used
        if (registeredTokenIds[tokenId]) {
            revert AlreadyEnforced();
        }

        // Mark the token as already used
        registeredTokenIds[tokenId] = true;

        super._enforce(_subject, _evidence);
    }

    /// @notice Get the trait of the Policy
    /// @return The type of the Policy
    function trait() public pure override returns (string memory) {
        return "Token";
    }
}
