// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";

/// @title IFactory
/// @notice Base interface for factory contracts responsible for deploying minimal proxy clones.
/// @dev Provides methods for clone deployment and related events.
interface IFactory {
    /// @notice Emitted when a new clone contract is successfully deployed.
    /// @param clone Address of the deployed clone contract.
    event CloneDeployed(address indexed clone);
}
