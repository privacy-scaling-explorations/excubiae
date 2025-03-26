// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Factory} from "../../proxy/Factory.sol";
import {GitcoinPassportPolicy} from "./GitcoinPassportPolicy.sol";

/// @title GitcoinPassportPolicyFactory
/// @notice Factory contract for deploying minimal proxy instances of GitcoinPassportPolicy.
/// @dev Simplifies deployment of GitcoinPassportPolicy clones with appended configuration data.
contract GitcoinPassportPolicyFactory is Factory {
    /// @notice Initializes the factory with the GitcoinPassportPolicy implementation.
    constructor() Factory(address(new GitcoinPassportPolicy())) {}

    /// @notice Deploys a new GitcoinPassportPolicy clone with the specified checker address.
    /// @dev Encodes the checker address and caller as configuration data for the clone.
    /// @param checkerAddress Address of the checker to use for validation.
    function deploy(address checkerAddress) public {
        bytes memory data = abi.encode(msg.sender, checkerAddress);

        address clone = super._deploy(data);

        GitcoinPassportPolicy(clone).initialize();
    }
}
