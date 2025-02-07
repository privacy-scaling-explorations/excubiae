// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SemaphorePolicy} from "./SemaphorePolicy.sol";
import {Factory} from "../proxy/Factory.sol";

/// @title SemaphorePolicyFactory
/// @notice Factory contract for deploying minimal proxy instances of SemaphorePolicy.
/// @dev Simplifies deployment of Semaphore policy clones with appended configuration data.
contract SemaphorePolicyFactory is Factory {
    /// @notice Initializes the factory with the SemaphorePolicy implementation.
    constructor() Factory(address(new SemaphorePolicy())) {}

    /// @notice Deploys a new SemaphorePolicy clone with the specified checker address.
    /// @dev Encodes the checker address and caller as configuration data for the clone.
    /// @param _checker Address of the Semaphore checker to use for validation.
    function deploy(address _checker) public {
        // Encode the caller (owner) and checker address for appended data.
        bytes memory data = abi.encode(msg.sender, _checker);

        address clone = super._deploy(data);

        SemaphorePolicy(clone).initialize();
    }
}
