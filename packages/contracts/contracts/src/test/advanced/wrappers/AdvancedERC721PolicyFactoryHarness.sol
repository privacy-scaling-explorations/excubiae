// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedERC721PolicyFactory} from "../AdvancedERC721PolicyFactory.sol";

/// @title AdvancedERC721PolicyFactoryHarness
/// @notice Test harness exposing internal methods of `AdvancedERC721PolicyFactory` for testing purposes.
/// @dev Inherits `AdvancedERC721PolicyFactory` and provides external methods for accessing internal logic.
contract AdvancedERC721PolicyFactoryHarness is AdvancedERC721PolicyFactory {
    /// @notice Test exposure for `_deploy` method.
    /// @param data Initialization data to append to the clone.
    /// @return clone Address of the deployed clone contract.
    function exposed__deploy(bytes memory data) external returns (address clone) {
        return _deploy(data);
    }
}
