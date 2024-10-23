// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/src/Test.sol";
import {Checker} from "../src/core/Checker.sol";
import {FreeForAllExcubia} from "../src/extensions/FreeForAllExcubia.sol";
import {FreeForAllChecker} from "../src/extensions/FreeForAllChecker.sol";
import {FreeForAllExcubiaHarness} from "./wrappers/FreeForAllExcubiaHarness.sol";
import {FreeForAllCheckerHarness} from "./wrappers/FreeForAllCheckerHarness.sol";

contract FreeForAllExcubiaTest is Test {
    FreeForAllExcubia internal freeForAllExcubia;
    FreeForAllChecker internal freeForAllChecker;
    FreeForAllExcubiaHarness internal freeForAllExcubiaHarness;
    FreeForAllCheckerHarness internal freeForAllCheckerHarness;

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

        freeForAllChecker = new FreeForAllChecker();
        freeForAllExcubia = new FreeForAllExcubia(Checker(freeForAllChecker), 7);

        freeForAllExcubiaHarness = new FreeForAllExcubiaHarness(Checker(freeForAllChecker), 7);
        freeForAllExcubiaHarness.setGate(gate);

        freeForAllCheckerHarness = new FreeForAllCheckerHarness();

        vm.stopPrank();
    }

    function test_trait_Internal() public view {
        // assertEq(freeForAllExcubiaHarness.exposed__trait(), "FreeForAll");
    }

    function test_trait_Match() external view {
        assertEq(freeForAllExcubia.trait(), "FreeForAll");
    }

    function invariant_trait_AlwaysFreeForAll() public view {
        assertEq(
            freeForAllExcubia.trait(),
            "FreeForAll",
            "Invariant violated: the trait must match 'FreeForAll' string"
        );
    }

    function test_setGate() external {
        vm.expectEmit(true, true, false, false);
        emit GateSet(gate);

        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);
    }

    function test_setGate_RevertWhen_CallerIsNotOwner() external {
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0)));
        vm.prank(address(0));
        freeForAllExcubia.setGate(gate);
    }

    function test_setGate_RevertWhen_WithZeroAddress() external {
        vm.expectRevert(ZeroAddress.selector);
        vm.prank(deployer);
        freeForAllExcubia.setGate(address(0));
    }

    function test_setGate_RevertWhen_AlreadySet() external {
        vm.startPrank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.expectRevert(GateAlreadySet.selector);
        freeForAllExcubia.setGate(gate);

        vm.stopPrank();
    }

    function testFuzz_setGate_Addresses(address theGate) public {
        vm.assume(theGate != address(0));

        vm.prank(deployer);
        freeForAllExcubia.setGate(theGate);

        assertEq(freeForAllExcubia.gate(), theGate);
        assert(freeForAllExcubia.gate() != address(0));
        assertEq(freeForAllExcubia.owner(), deployer);
    }

    function testFuzz_setGate_RevertWhen_NotOwnerAddresses(address notOwner) public {
        vm.assume(notOwner != deployer);

        vm.prank(notOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(notOwner)));
        freeForAllExcubia.setGate(gate);

        assertEq(freeForAllExcubia.gate(), address(0));
        assertEq(freeForAllExcubia.owner(), deployer);
    }

    // function test_pass() external {
    //     vm.prank(deployer);
    //     freeForAllExcubia.setGate(gate);

    //     vm.expectEmit(true, true, false, false);
    //     emit GatePassed(passerby, gate);

    //     vm.prank(gate);
    //     freeForAllExcubia.passMainCheck(passerby, "0x");
    // }

    function test_pass_GateCanSelfPass() public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.prank(gate);
        freeForAllExcubia.passMainCheck(gate, "0x");
    }

    function testGas_pass() public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.prank(gate);
        uint256 gasBefore = gasleft();

        freeForAllExcubia.passMainCheck(passerby, "0x");

        uint256 gasAfter = gasleft();
        uint256 gasUsed = gasBefore - gasAfter;
        assert(gasUsed < 70_000);
    }

    function test_pass_RevertWhen_GateNotSet() external {
        vm.prank(gate);
        vm.expectRevert(GateOnly.selector);
        freeForAllExcubia.passMainCheck(passerby, "");

        assertEq(freeForAllExcubia.gate(), address(0));
    }

    function test_pass_RevertWhen_NotGate() external {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.expectRevert(GateOnly.selector);
        freeForAllExcubia.passMainCheck(passerby, "");

        assert(freeForAllExcubia.gate() != address(0));
    }

    function testFuzz_pass_AndCheck(address thePasserby, bytes calldata data) public {
        vm.prank(deployer);
        freeForAllExcubia.setGate(gate);

        vm.prank(gate);
        freeForAllExcubia.passMainCheck(thePasserby, data);

        assertEq(freeForAllExcubia.trait(), "FreeForAll");
    }

    function test_check_Internal() public view {
        freeForAllCheckerHarness.exposed__checkPre(passerby, "0x");
        freeForAllCheckerHarness.exposed__checkMain(passerby, "0x");
        freeForAllCheckerHarness.exposed__checkPost(passerby, "0x");
    }

    function testFuzz_check_Internal(address randomPasserby, bytes calldata randomData) public view {
        freeForAllCheckerHarness.exposed__checkPre(randomPasserby, randomData);
        freeForAllCheckerHarness.exposed__checkMain(randomPasserby, randomData);
        freeForAllCheckerHarness.exposed__checkPost(randomPasserby, randomData);
    }
}
