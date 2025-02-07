// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <=0.8.28;

import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {BaseChecker} from "../checker/BaseChecker.sol";

/// @title SemaphoreChecker
/// @notice Semaphore proof of membership validator.
/// @dev Extends BaseChecker to implement proof of membership validation logic using Semaphore.
/// Please note that once a identity is used to register, it cannot be used again, thanks to the nullifier.
contract SemaphoreChecker is BaseChecker {
    /// @notice Address of the Semaphore contract used for proof of membership validation.
    ISemaphore public semaphore;

    /// @notice The unique identifier of the Semaphore group.
    /// @dev The subject can prove membership only for the group having the following identifier.
    uint256 public groupId;

    /// @notice Error thrown when the subject sends a proof with an invalid or mismatching group.
    error IncorrectGroupId();

    /// @notice Error thrown when the subject sends an invalid proof.
    error InvalidProof();

    /// @notice Initializes the contract with necessary parameters values.
    /// @dev Decodes the appended bytes from the clone to set the parameters values.
    function _initialize() internal override {
        super._initialize();

        bytes memory data = _getAppendedBytes();

        (address _semaphore, uint256 _groupId) = abi.decode(data, (address, uint256));

        semaphore = ISemaphore(_semaphore);
        groupId = _groupId;
    }

    /// @notice Validates whether the subject is a member of the group.
    /// @dev Decodes the proof from evidence and checks group membership based on proof validity.
    /// @param subject Address to validate ownership for.
    /// @param evidence Encoded proof used for validation.
    /// @return Boolean indicating whether the subject is a member of the group or not.
    function _check(address subject, bytes calldata evidence) internal view override returns (bool) {
        super._check(subject, evidence);

        ISemaphore.SemaphoreProof memory proof = abi.decode(evidence, (ISemaphore.SemaphoreProof));
        uint256 _scope = proof.scope;

        if (_scope != groupId) revert IncorrectGroupId();
        if (!semaphore.verifyProof(_scope, proof)) revert InvalidProof();

        return true;
    }
}
