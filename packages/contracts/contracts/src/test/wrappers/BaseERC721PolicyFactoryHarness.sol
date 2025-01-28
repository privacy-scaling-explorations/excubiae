// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721PolicyFactory} from "../base/BaseERC721PolicyFactory.sol";

/// @title BaseERC721PolicyFactoryHarness
/// @notice Test harness exposing internal methods of `BaseERC721PolicyFactory` for testing purposes.
/// @dev Inherits `BaseERC721PolicyFactory` and provides external methods for accessing internal logic.
contract BaseERC721PolicyFactoryHarness is BaseERC721PolicyFactory {
    /// @notice Test exposure for `_deploy` method.
    /// @param data Initialization data to append to the clone.
    /// @return clone Address of the deployed clone contract.
    function exposed__deploy(bytes memory data) external returns (address clone) {
        return _deploy(data);
    }
}
