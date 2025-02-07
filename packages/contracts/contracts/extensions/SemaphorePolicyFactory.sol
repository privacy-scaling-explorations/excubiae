// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SemaphorePolicy} from "./SemaphorePolicy.sol";
import {Factory} from "../proxy/Factory.sol";

/// @title SemaphorePolicyFactory
/// @notice Factory contract for deploying minimal proxy instances of SemaphorePolicy.
/// @dev Utilizes the Factory pattern to deploy SemaphorePolicy clones with custom configuration data.
contract SemaphorePolicyFactory is Factory {
    /// @notice Initializes the factory with the SemaphorePolicy implementation.
    /// @dev The constructor sets the SemaphorePolicy contract as the implementation for cloning.
    constructor() Factory(address(new SemaphorePolicy())) {}

    /// @notice Deploys a new SemaphorePolicy clone with the specified checker address.
    /// @dev Encodes the deployer (as owner) and checker address as initialization data for the clone.
    /// @param _checker Address of the Semaphore checker used for proof validation.
    function deploy(address _checker) public {
        bytes memory data = abi.encode(msg.sender, _checker);
        address clone = super._deploy(data);
        SemaphorePolicy(clone).initialize();
    }
}
