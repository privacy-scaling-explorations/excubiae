// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SemaphoreChecker} from "./SemaphoreChecker.sol";
import {Factory} from "../proxy/Factory.sol";

/// @title SemaphoreCheckerFactory
/// @notice Factory contract for deploying minimal proxy instances of SemaphoreChecker.
/// @dev Utilizes the Factory pattern to streamline deployment of SemaphoreChecker clones with configuration data.
contract SemaphoreCheckerFactory is Factory {
    /// @notice Initializes the factory with the SemaphoreChecker implementation.
    /// @dev The constructor sets the SemaphoreChecker contract as the implementation for cloning.
    constructor() Factory(address(new SemaphoreChecker())) {}

    /// @notice Deploys a new SemaphoreChecker clone with the specified Semaphore contract and group ID.
    /// @dev Encodes the Semaphore contract address and group ID as initialization data for the clone.
    /// @param _semaphore Address of the Semaphore contract.
    /// @param _groupId Unique identifier of the Semaphore group.
    function deploy(address _semaphore, uint256 _groupId) public {
        bytes memory data = abi.encode(_semaphore, _groupId);
        address clone = super._deploy(data);
        SemaphoreChecker(clone).initialize();
    }
}
