// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import {Test} from "forge-std/src/Test.sol";
import {console2} from "forge-std/src/console2.sol";

import {Lock} from "../src/Lock.sol";

contract LockTest is Test {
    Lock internal lock;

    function setUp() public virtual {
        // Set unlock time to 1 hour from now
        lock = new Lock{value: 1 ether}(block.timestamp + 1 hours);
    }

    function test_CannotWithdrawYet() external {
        // Attempt to withdraw before unlock time
        vm.expectRevert("You can't withdraw yet");
        lock.withdraw();
    }
}
