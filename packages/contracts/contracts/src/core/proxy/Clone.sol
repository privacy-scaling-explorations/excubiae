// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IClone} from "../interfaces/IClone.sol";
import {LibClone} from "solady/src/utils/LibClone.sol";

// @todo refactoring & comments
abstract contract Clone is IClone {
    bool private _initialized;

    function initialize() external {
        _initialize();
    }

    function getAppendedBytes() external returns (bytes memory) {
        return _getAppendedBytes();
    }

    function _initialize() internal virtual {
        if (_initialized) revert AlreadyInitialized();
        _initialized = true;
    }

    function _getAppendedBytes() internal virtual returns (bytes memory) {
        return LibClone.argsOnClone(address(this));
    }
}
