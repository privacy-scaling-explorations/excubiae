// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BaseERC721Policy} from "./BaseERC721Policy.sol";

/**
 * @title BaseVoting
 * @notice Basic voting contract with NFT-based access control.
 * @dev Uses BaseERC721Policy for voter validation.
 */
contract BaseVoting {
    event Registered(address voter);
    event Voted(address voter, uint8 option);

    error NotRegistered();
    error AlreadyVoted();
    error InvalidOption();

    /// @notice Policy contract for voter validation.
    BaseERC721Policy public immutable POLICY;

    /// @notice Tracks if an address has voted.
    mapping(address => bool) public hasVoted;
    /// @notice Counts votes for each option.
    mapping(uint8 => uint256) public voteCounts;

    constructor(BaseERC721Policy _policy) {
        POLICY = _policy;
    }

    /// @notice Register voter using NFT ownership verification.
    /// @param tokenId Token ID to verify ownership.
    function register(uint256 tokenId) external {
        bytes memory evidence = abi.encode(tokenId);
        POLICY.enforce(msg.sender, evidence);
        emit Registered(msg.sender);
    }

    /// @notice Cast vote for given option.
    /// @param option Voting option (0 or 1).
    function vote(uint8 option) external {
        if (!POLICY.enforced(address(this), msg.sender)) revert NotRegistered();
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (option >= 2) revert InvalidOption();

        hasVoted[msg.sender] = true;
        voteCounts[option]++;
        emit Voted(msg.sender, option);
    }
}
