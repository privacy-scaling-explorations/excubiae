// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";

/// @title IFactory
/// @notice Base interface for Excubiae factories
interface IFactory {
    /// @notice Emitted when a new clone is deployed
    /// @param instance Address of the deployed clone
    event CloneDeployed(address indexed instance);

    /// @notice Returns the implementation contract address
    function implementation() external view returns (address);
}
