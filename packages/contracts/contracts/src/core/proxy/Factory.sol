// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {IFactory} from "../interfaces/IFactory.sol";

// @todo refactoring & comments
abstract contract Factory is IFactory {
    address public immutable IMPLEMENTATION;

    constructor(address _implementation) {
        IMPLEMENTATION = _implementation;
    }

    function _deploy(bytes memory data) internal returns (address clone) {
        clone = LibClone.clone(IMPLEMENTATION, data);

        emit CloneDeployed(clone);
    }
}
