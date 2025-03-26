// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Factory} from "../../proxy/Factory.sol";
import {SignUpTokenPolicy} from "./SignUpTokenPolicy.sol";

/// @title SignUpTokenPolicyFactory
/// @notice Factory contract for deploying minimal proxy instances of SignUpTokenPolicy.
/// @dev Simplifies deployment of SignUpTokenPolicy clones with appended configuration data.
contract SignUpTokenPolicyFactory is Factory {
    /// @notice Initializes the factory with the SignUpTokenPolicy implementation.
    constructor() Factory(address(new SignUpTokenPolicy())) {}

    /// @notice Deploys a new SignUpTokenPolicy clone with the specified checker address.
    /// @dev Encodes the checker address and caller as configuration data for the clone.
    /// @param checkerAddress Address of the checker to use for validation.
    function deploy(address checkerAddress) public {
        bytes memory data = abi.encode(msg.sender, checkerAddress);

        address clone = super._deploy(data);

        SignUpTokenPolicy(clone).initialize();
    }
}
