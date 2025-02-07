// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBaseChecker} from "../../../interfaces/IBaseChecker.sol";

/// @title BaseCheckerMock
/// @notice This contract is a mock implementation of the IBaseChecker interface for testing purposes.
contract BaseCheckerMock is IBaseChecker {
    ///@dev mock check() method that returns always false.
    function check(address /*subject*/, bytes calldata /*evidence*/) external pure override returns (bool) {
        return false;
    }
}
