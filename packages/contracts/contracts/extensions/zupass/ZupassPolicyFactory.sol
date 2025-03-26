// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Factory} from "../../proxy/Factory.sol";
import {ZupassPolicy} from "./ZupassPolicy.sol";

/// @title ZupassPolicyFactory
/// @notice Factory contract for deploying minimal proxy instances of ZupassPolicy.
/// @dev Simplifies deployment of ZupassPolicy clones with appended configuration data.
contract ZupassPolicyFactory is Factory {
    /// @notice Initializes the factory with the ZupassPolicy implementation.
    constructor() Factory(address(new ZupassPolicy())) {}

    /// @notice Deploys a new ZupassPolicy clone with the specified checker address.
    /// @dev Encodes the checker address and caller as configuration data for the clone.
    /// @param _checkerAddress Address of the checker to use for validation.
    function deploy(address _checkerAddress) public {
        bytes memory data = abi.encode(msg.sender, _checkerAddress);

        address clone = super._deploy(data);

        ZupassPolicy(clone).initialize();
    }
}
