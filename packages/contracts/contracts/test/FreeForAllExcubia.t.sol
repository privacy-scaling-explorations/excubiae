// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import {Test} from "forge-std/src/Test.sol";
import {FreeForAllExcubia} from "../src/extensions/FreeForAllExcubia.sol";
import {FreeForAllExcubiaTestWrapper} from "./wrappers/FreeForAllExcubiaTestWrapper.sol";

contract FreeForAllExcubiaTest is Test {
    FreeForAllExcubia internal freeForAllExcubia;
    FreeForAllExcubiaTestWrapper internal freeForAllExcubiaTW;

    address public deployer = vm.addr(0x1);
    address public gate = vm.addr(0x2);
    address public passerby = vm.addr(0x3);

    event GateSet(address indexed gate);
    event GatePassed(address indexed passerby, address indexed gate);

    error OwnableUnauthorizedAccount(address);
    error ZeroAddress();
    error GateNotSet();
    error GateOnly();
    error GateAlreadySet();
    error AlreadyPassed();

    function setUp() public virtual {
        vm.startPrank(deployer);

        freeForAllExcubia = new FreeForAllExcubia();

        freeForAllExcubiaTW = new FreeForAllExcubiaTestWrapper();
        freeForAllExcubiaTW.setGate(gate);

        vm.stopPrank();
    }

    function testInternalCheck() public view {
        freeForAllExcubiaTW.exposed_check(passerby, "");
    }

    function testInternalPass() public {
        vm.expectEmit(true, true, false, false);
        emit GatePassed(passerby, gate);

        freeForAllExcubiaTW.exposed_pass(passerby, "");

        assertTrue(freeForAllExcubiaTW.passedPassersby(passerby));
    }

    function testFuzz_InternalCheck(address randomPasserby, bytes calldata randomData) public view {
        freeForAllExcubiaTW.exposed_check(randomPasserby, randomData);
    }

    function testFuzz_InternalPass(address randomPasserby, bytes calldata randomData) public {
        vm.expectEmit(true, true, false, false);
        emit GatePassed(randomPasserby, gate);

        freeForAllExcubiaTW.exposed_pass(randomPasserby, randomData);

        assertTrue(freeForAllExcubiaTW.passedPassersby(randomPasserby));
        vm.expectRevert(AlreadyPassed.selector);
        freeForAllExcubiaTW.exposed_pass(randomPasserby, randomData);
    }

    function test_RevertWhen_SetGateCallerIsNotOwner() external {
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0)));
        vm.prank(address(0));
        freeForAllExcubia.setGate(gate);
    }

    function test_RevertWhen_SetGateWithZeroAddress() external {
        vm.expectRevert(ZeroAddress.selector);
        vm.prank(deployer);
        freeForAllExcubia.setGate(address(0));
    }

    function test_SetGate() external {
        vm.expectEmit(true, true, false, false);
        emit GateSet(gate);

        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);
    }

    function test_RevertIf_GateAlreadySet() external {
        vm.startPrank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.expectRevert(GateAlreadySet.selector);
        freeForAllExcubia.setGate(gate);

        vm.stopPrank();
    }

    function testFuzz_SetGateWhateverAddress(address theGate) public {
        vm.assume(theGate != address(0));

        vm.prank(deployer);
        freeForAllExcubia.setGate(theGate);

        assertEq(freeForAllExcubia.gate(), theGate);
        assert(freeForAllExcubia.gate() != address(0));
        assertEq(freeForAllExcubia.owner(), deployer);
    }

    function testFuzz_RevertWhen_SetGateWithWhateverNotOwner(address notOwner) public {
        vm.assume(notOwner != deployer);

        vm.prank(notOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(notOwner)));
        freeForAllExcubia.setGate(gate);

        assertEq(freeForAllExcubia.gate(), address(0));
        assertEq(freeForAllExcubia.owner(), deployer);
    }

    function test_TraitMatch() external view {
        assertEq(freeForAllExcubia.trait(), "FreeForAll");
    }

    function test_RevertIf_PassWhenGateNotSet() external {
        vm.prank(gate);
        vm.expectRevert(GateOnly.selector);
        freeForAllExcubia.pass(passerby, "");

        assertEq(freeForAllExcubia.gate(), address(0));
    }

    function test_RevertIf_PassWhenNotGate() external {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.expectRevert(GateOnly.selector);
        freeForAllExcubia.pass(passerby, "");

        assert(freeForAllExcubia.gate() != address(0));
    }

    function test_PassTheGate() external {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.expectEmit(true, true, false, false);
        emit GatePassed(passerby, gate);

        vm.prank(gate);
        freeForAllExcubia.pass(passerby, "0x");

        assertTrue(freeForAllExcubia.passedPassersby(passerby));
    }

    function test_RevertIf_PasserbyPassTwice() external {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.startPrank(gate);
        freeForAllExcubia.pass(passerby, "0x");

        vm.expectRevert(AlreadyPassed.selector);
        freeForAllExcubia.pass(passerby, "0x");

        vm.stopPrank();
    }

    function testFuzz_PassAndCheck(address thePasserby, bytes calldata data) public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.prank(gate);
        freeForAllExcubia.pass(thePasserby, data);

        assertTrue(freeForAllExcubia.passedPassersby(thePasserby));
        assertEq(freeForAllExcubia.trait(), "FreeForAll");
    }

    function testFuzz_RevertWhen_PassTwice(address thePasserby) public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.startPrank(gate);
        freeForAllExcubia.pass(thePasserby, "0x");

        vm.expectRevert(AlreadyPassed.selector);
        freeForAllExcubia.pass(thePasserby, "0x");

        vm.stopPrank();

        assertTrue(freeForAllExcubia.passedPassersby(thePasserby));
        assertEq(freeForAllExcubia.trait(), "FreeForAll");
    }

    function testFuzz_CheckFunction(address thePasserby, bytes calldata data) public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        freeForAllExcubia.check(thePasserby, data);

        vm.prank(gate);
        freeForAllExcubia.pass(thePasserby, data);

        freeForAllExcubia.check(thePasserby, data);
    }

    function invariant_GateNeverZeroAfterSet() public view {
        if (freeForAllExcubia.gate() != address(0)) {
            assert(freeForAllExcubia.gate() != address(0));
        }
    }

    function invariant_TraitAlwaysFreeForAll() public view {
        assertEq(freeForAllExcubia.trait(), "FreeForAll");
    }

    function testGas_Pass() public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.prank(gate);
        uint256 gasBefore = gasleft();

        freeForAllExcubia.pass(passerby, "0x");

        uint256 gasAfter = gasleft();
        uint256 gasUsed = gasBefore - gasAfter;
        assert(gasUsed < 30000);
    }

    function test_GatePassesSelf() public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.prank(gate);
        freeForAllExcubia.pass(gate, "0x");

        assertTrue(freeForAllExcubia.passedPassersby(gate));
    }
}
