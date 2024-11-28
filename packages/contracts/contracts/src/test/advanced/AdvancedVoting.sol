// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AdvancedPolicy} from "../../AdvancedPolicy.sol";
import {Check} from "../../interfaces/IAdvancedPolicy.sol";

/**
 * @title AdvancedVoting
 * @notice Voting contract with three-phase validation and NFT rewards.
 * @dev Uses pre-check for registration, main check for voting, and post-check for claiming NFT rewards.
 */
contract AdvancedVoting {
    event Registered(address voter);
    event Voted(address voter, uint8 option);
    event RewardClaimed(address voter, uint256 rewardId);

    error NotRegistered();
    error NotVoted();
    error AlreadyClaimed();
    error InvalidOption();
    error NotOwnerOfReward();

    /// @notice Policy contract handling validation checks.
    AdvancedPolicy public immutable POLICY;

    /// @notice Tracks vote counts for each option.
    mapping(uint8 => uint256) public voteCounts;

    constructor(AdvancedPolicy _policy) {
        POLICY = _policy;
    }

    /**
     * @notice Register to participate in voting.
     * @dev Validates NFT ownership through pre-check.
     * @param tokenId Token ID to verify ownership.
     */
    function register(uint256 tokenId) external {
        bytes memory evidence = abi.encode(tokenId);

        POLICY.enforce(msg.sender, evidence, Check.PRE);

        emit Registered(msg.sender);
    }

    /**
     * @notice Cast vote after verifying registration.
     * @dev Requires pre-check completion and validates voting power.
     * @param option Voting option (0 or 1).
     */
    function vote(uint8 option) external {
        (bool pre, , ) = POLICY.enforced(address(this), msg.sender);

        if (!pre) revert NotRegistered();
        if (option >= 2) revert InvalidOption();

        bytes memory evidence = abi.encode(option);
        POLICY.enforce(msg.sender, evidence, Check.MAIN);

        unchecked {
            voteCounts[option]++;
        }

        emit Voted(msg.sender, option);
    }

    /**
     * @notice Claim NFT reward after voting.
     * @dev Validates voting participation and transfers reward NFT.
     * @param rewardId NFT ID to be claimed as reward.
     */
    function reward(uint256 rewardId) external {
        (bool pre, uint8 main, bool post) = POLICY.enforced(address(this), msg.sender);

        if (!pre) revert NotRegistered();
        if (main == 0) revert NotVoted();
        if (post) revert AlreadyClaimed();

        bytes memory evidence = abi.encode(rewardId);
        POLICY.enforce(msg.sender, evidence, Check.POST);

        emit RewardClaimed(msg.sender, rewardId);
    }
}
