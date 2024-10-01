// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import {Test} from "forge-std/src/Test.sol";
import {FreeForAllExcubia} from "../src/extensions/FreeForAllExcubia.sol";

contract FreeForAllExcubiaTest is Test {
    FreeForAllExcubia internal freeForAllExcubia;

    address public owner = vm.addr(0x1);
    address public gate = vm.addr(0x2);
    address public passerbyA = vm.addr(0x3);
    address public passerbyB = vm.addr(0x4);

    event GateSet(address indexed gate);
    event GatePassed(address indexed passerby, address indexed gate);

    error OwnableUnauthorizedAccount(address);
    error ZeroAddress();
    error GateNotSet();
    error GateOnly();
    error GateAlreadySet();
    error AlreadyPassed();

    function setUp() public virtual {
        vm.prank(owner);
        freeForAllExcubia = new FreeForAllExcubia();
    }

    /**
     * setGate()
     */
    function testGateOnlyOwner() external {
        vm.prank(address(0));
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0)));
        freeForAllExcubia.setGate(gate);
    }

    function testGateZeroAddress() external {
        vm.prank(owner);
        vm.expectRevert(ZeroAddress.selector);
        freeForAllExcubia.setGate(address(0));
    }

    function testSetGate() external {
        vm.expectEmit(true, true, true, true);
        emit GateSet(gate);

        vm.prank(owner);
        freeForAllExcubia.setGate(gate);

        assertEq(freeForAllExcubia.gate(), gate);
    }

    function testGateAlreadySet() external {
        vm.prank(owner);
        freeForAllExcubia.setGate(gate);

        vm.prank(owner);
        vm.expectRevert(GateAlreadySet.selector);
        freeForAllExcubia.setGate(gate);
    }

    function testTrait() external view {
        assertEq(freeForAllExcubia.trait(), "FreeForAll");
    }

    /**
     * pass() & implicitly _check()
     */
    function testPassNotGate() external {
        vm.prank(passerbyA);
        vm.expectRevert(GateOnly.selector);
        freeForAllExcubia.pass(passerbyA, "");
    }

    function testPass() external {
        vm.prank(owner);
        freeForAllExcubia.setGate(gate);

        vm.expectEmit(true, true, true, true);
        emit GatePassed(passerbyA, gate);

        vm.prank(gate);
        freeForAllExcubia.pass(passerbyA, "");

        assertTrue(freeForAllExcubia.passedPassersby(passerbyA));
    }

    function testNotPassTwice() external {
        vm.prank(owner);
        freeForAllExcubia.setGate(gate);

        assertEq(gate, freeForAllExcubia.gate());
        vm.prank(gate);
        freeForAllExcubia.pass(passerbyA, "");

        assertTrue(freeForAllExcubia.passedPassersby(passerbyA));

        vm.prank(gate);
        vm.expectRevert(AlreadyPassed.selector);
        freeForAllExcubia.pass(passerbyA, "");
    }

    function testPassAnotherPasserby() external {
        vm.prank(owner);
        freeForAllExcubia.setGate(gate);

        vm.expectEmit(true, true, true, true);
        emit GatePassed(passerbyA, gate);

        vm.prank(gate);
        freeForAllExcubia.pass(passerbyA, "");

        vm.expectEmit(true, true, true, true);
        emit GatePassed(passerbyB, gate);

        vm.prank(gate);
        freeForAllExcubia.pass(passerbyB, "");

        assertTrue(freeForAllExcubia.passedPassersby(passerbyB));
    }

    /**
     * Fuzz Tests
     */
    function testFuzzSetGate(address _gate) external {
        vm.assume(_gate != address(0));
        vm.prank(owner);
        freeForAllExcubia.setGate(_gate);
        assertEq(freeForAllExcubia.gate(), _gate);
    }

    function testFuzzPass(address _gate, address _passerby) external {
        vm.assume(_gate != address(0) && _passerby != address(0));
        vm.prank(owner);
        freeForAllExcubia.setGate(_gate);

        vm.expectEmit(true, true, true, true);
        emit GatePassed(_passerby, _gate);

        vm.prank(_gate);
        freeForAllExcubia.pass(_passerby, "");

        assertTrue(freeForAllExcubia.passedPassersby(_passerby));
    }
}
