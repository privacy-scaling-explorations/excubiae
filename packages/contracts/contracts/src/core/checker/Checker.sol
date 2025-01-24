// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IChecker} from "../interfaces/IChecker.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

// @todo refactoring & comments
abstract contract Checker is IChecker {
    bool private _initialized;

    error AlreadyInitialized();

    function initialize() public virtual {
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;
    }

    function _getAppendedBytes() internal view returns (bytes memory) {
        return LibClone.argsOnClone(address(this));
    }
}
