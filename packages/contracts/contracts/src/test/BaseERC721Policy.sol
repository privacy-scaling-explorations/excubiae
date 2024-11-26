// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BasePolicy} from "../../src/BasePolicy.sol";
import {BaseERC721Checker} from "./BaseERC721Checker.sol";

contract BaseERC721Policy is BasePolicy {
    BaseERC721Checker public immutable CHECKER;

    constructor(BaseERC721Checker _checker) BasePolicy(_checker) {
        CHECKER = BaseERC721Checker(_checker);
    }

    function trait() external pure returns (string memory) {
        return "BaseERC721";
    }
}
