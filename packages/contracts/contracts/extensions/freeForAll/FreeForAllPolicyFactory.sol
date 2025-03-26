// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Factory} from "../../proxy/Factory.sol";
import {FreeForAllPolicy} from "./FreeForAllPolicy.sol";

/// @title FreeForAllPolicyFactory
/// @notice Factory contract for deploying minimal proxy instances of FreeForAllPolicy.
/// @dev Simplifies deployment of FreeForAllPolicy clones with appended configuration data.
contract FreeForAllPolicyFactory is Factory {
    /// @notice Initializes the factory with the FreeForAllPolicy implementation.
    constructor() Factory(address(new FreeForAllPolicy())) {}

    /// @notice Deploys a new FreeForAllPolicy clone with the specified checker address.
    /// @dev Encodes the checker address and caller as configuration data for the clone.
    /// @param _checkerAddress Address of the checker to use for validation.
    function deploy(address _checkerAddress) public {
        bytes memory data = abi.encode(msg.sender, _checkerAddress);

        address clone = super._deploy(data);

        FreeForAllPolicy(clone).initialize();
    }
}
