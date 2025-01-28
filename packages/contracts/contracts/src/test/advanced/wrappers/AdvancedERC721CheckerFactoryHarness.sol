// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AdvancedERC721CheckerFactory} from "../AdvancedERC721CheckerFactory.sol";

/// @title AdvancedERC721CheckerFactoryHarness
/// @notice Test harness exposing internal methods of `AdvancedERC721CheckerFactory` for testing purposes.
/// @dev Inherits `AdvancedERC721CheckerFactory` and provides external methods for accessing internal logic.
contract AdvancedERC721CheckerFactoryHarness is AdvancedERC721CheckerFactory {
    /// @notice Test exposure for `_deploy` method.
    /// @param data Initialization data to append to the clone.
    /// @return clone Address of the deployed clone contract.
    function exposed__deploy(bytes memory data) external returns (address clone) {
        return _deploy(data);
    }
}
