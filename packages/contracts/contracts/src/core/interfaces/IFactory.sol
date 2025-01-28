// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";

/// @title IFactory
/// @notice Base interface for Excubiae factories
interface IFactory {
    error InitializationFailed();

    /// @notice Emitted when a new clone is deployed
    /// @param clone Address of the deployed clone
    event CloneDeployed(address indexed clone);
}
