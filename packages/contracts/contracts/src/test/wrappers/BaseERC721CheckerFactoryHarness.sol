// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseERC721CheckerFactory} from "../base/BaseERC721CheckerFactory.sol";

/// @title BaseERC721CheckerHarness
/// @notice Test harness exposing internal methods of `BaseERC721CheckerFactory` for testing purposes.
/// @dev Inherits `BaseERC721CheckerFactory` and provides external methods for accessing internal logic.
contract BaseERC721CheckerFactoryHarness is BaseERC721CheckerFactory {
    /// @notice Test exposure for `_deploy` method.
    /// @param data Initialization data to append to the clone.
    /// @return clone Address of the deployed clone contract.
    function exposed__deploy(bytes memory data) external returns (address clone) {
        return _deploy(data);
    }
}
