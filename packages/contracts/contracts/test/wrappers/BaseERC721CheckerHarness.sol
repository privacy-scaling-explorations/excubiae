// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseERC721Checker} from "../../src/test/BaseERC721Checker.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// This contract is a harness for testing the BaseERC721Checker contract.
// Deploy this contract and call its methods to test the internal methods of BaseERC721Checker.
contract BaseERC721CheckerHarness is BaseERC721Checker {
    constructor(IERC721 _nft) BaseERC721Checker(_nft) {}

    /// @notice Exposes the internal `_check` method for testing purposes.
    /// @param subject The address to be checked.
    /// @param evidence The data associated with the check.
    function exposed__check(address subject, bytes calldata evidence) public view returns (bool) {
        return _check(subject, evidence);
    }
}
