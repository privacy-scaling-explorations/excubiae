// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Factory} from "../../proxy/Factory.sol";
import {ERC20VotesPolicy} from "./ERC20VotesPolicy.sol";

/// @title ERC20VotesPolicyFactory
/// @notice Factory contract for deploying minimal proxy instances of ERC20VotesPolicy.
/// @dev Simplifies deployment of ERC20VotesPolicy clones with appended configuration data.
contract ERC20VotesPolicyFactory is Factory {
    /// @notice Initializes the factory with the ERC20VotesPolicy implementation.
    constructor() Factory(address(new ERC20VotesPolicy())) {}

    /// @notice Deploys a new ERC20VotesPolicy clone with the specified checker address.
    /// @dev Encodes the checker address and caller as configuration data for the clone.
    /// @param _checkerAddress Address of the checker to use for validation.
    function deploy(address _checkerAddress) public {
        bytes memory data = abi.encode(msg.sender, _checkerAddress);

        address clone = super._deploy(data);

        ERC20VotesPolicy(clone).initialize();
    }
}
