// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/src/Test.sol";
import {NFT} from "./utils/NFT.sol";
import {AdvancedERC721Checker} from "./advanced/AdvancedERC721Checker.sol";
import {AdvancedERC721Policy} from "./advanced/AdvancedERC721Policy.sol";
import {AdvancedVoting} from "./advanced/AdvancedVoting.sol";
import {AdvancedERC721CheckerHarness} from "./wrappers/AdvancedERC721CheckerHarness.sol";
import {AdvancedERC721PolicyHarness} from "./wrappers/AdvancedERC721PolicyHarness.sol";
import {IPolicy} from "../interfaces/IPolicy.sol";
import {IAdvancedPolicy} from "../interfaces/IAdvancedPolicy.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Check, IAdvancedChecker} from "../interfaces/IAdvancedChecker.sol";

contract AdvancedChecker is Test {
    NFT internal nft;
    AdvancedERC721Checker internal checker;
    AdvancedERC721CheckerHarness internal checkerHarness;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        checker = new AdvancedERC721Checker(nft, 1, 0, 10);
        checkerHarness = new AdvancedERC721CheckerHarness(nft, 1, 0, 10);

        vm.stopPrank();
    }

    function test_checkPre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        checker.check(subject, abi.encode(0), Check.PRE);

        vm.stopPrank();
    }

    function test_checkPre_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checker.check(notOwner, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_checkPre_whenValid_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checker.check(subject, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_checkMain_whenCallerHasNoTokens_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checker.check(notOwner, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_checkMain_whenCallerHasTokens_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checker.check(subject, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_checkPost_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checker.check(subject, abi.encode(1), Check.POST);

        vm.stopPrank();
    }

    function test_checkPost_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checker.check(notOwner, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_checkPost_whenValid_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checker.check(subject, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_checkerPre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        checkerHarness.exposed__check(subject, abi.encode(0), Check.PRE);

        vm.stopPrank();
    }

    function test_checkerPre_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__check(notOwner, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_checkerPre_whenValid_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__check(subject, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_checkerMain_whenCallerHasNoTokens_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__check(notOwner, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_checkerMain_whenCallerHasTokens_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__check(subject, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_checkerPost_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checkerHarness.exposed__check(subject, abi.encode(1), Check.POST);

        vm.stopPrank();
    }

    function test_checkerPost_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__check(notOwner, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_checkerPost_whenValid_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__check(subject, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_internalPre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checkerHarness.exposed__checkPre(subject, abi.encode(1));

        vm.stopPrank();
    }

    function test_internalPre_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__checkPre(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_internalPre_whenValid_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__checkPre(subject, abi.encode(0)));

        vm.stopPrank();
    }

    function test_internalMain_whenCallerHasNoTokens_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__checkMain(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_internalMain_whenCallerHasTokens_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__checkMain(subject, abi.encode(0)));

        vm.stopPrank();
    }

    function test_internalPost_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checkerHarness.exposed__checkPost(subject, abi.encode(1));

        vm.stopPrank();
    }

    function test_internalPost_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__checkPost(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_internalPost_whenValid_succeeds() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__checkPost(subject, abi.encode(0)));

        vm.stopPrank();
    }
}

contract AdvancedPolicy is Test {
    NFT internal nft;
    AdvancedERC721Checker internal checker;
    AdvancedERC721Checker internal checkerSkipped;
    AdvancedERC721Policy internal policy;
    AdvancedERC721Policy internal policySkipped;
    AdvancedERC721PolicyHarness internal policyHarness;
    AdvancedERC721PolicyHarness internal policyHarnessSkipped;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        checker = new AdvancedERC721Checker(nft, 1, 0, 10);
        checkerSkipped = new AdvancedERC721Checker(nft, 1, 0, 10);
        policy = new AdvancedERC721Policy(checker, false, false, true);
        policyHarness = new AdvancedERC721PolicyHarness(checker, false, false, true);
        policySkipped = new AdvancedERC721Policy(checkerSkipped, true, true, false);
        policyHarnessSkipped = new AdvancedERC721PolicyHarness(checkerSkipped, true, true, false);

        vm.stopPrank();
    }

    function test_trait_returnsCorrectValue() public view {
        assertEq(policy.trait(), "AdvancedERC721");
    }

    function test_setTarget_whenCallerNotOwner_reverts() public {
        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
        policy.setTarget(target);

        vm.stopPrank();
    }

    function test_setTarget_whenZeroAddress_reverts() public {
        vm.startPrank(deployer);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.ZeroAddress.selector));
        policy.setTarget(address(0));

        vm.stopPrank();
    }

    function test_setTarget_whenValid_succeeds() public {
        vm.startPrank(deployer);

        vm.expectEmit(true, true, true, true);
        emit IPolicy.TargetSet(target);

        policy.setTarget(target);

        vm.stopPrank();
    }

    function test_setTarget_whenAlreadySet_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetAlreadySet.selector));
        policy.setTarget(target);

        vm.stopPrank();
    }

    function test_enforcePre_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPreCheckWhenSkipped.selector));
        policySkipped.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(notOwner, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.PRE);

        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforceMain_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.PreCheckNotEnforced.selector));
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.MAIN);

        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenMultipleValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.MAIN);

        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.MAIN);

        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenMultipleNotAllowed_reverts() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policySkipped.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckAlreadyEnforced.selector));
        policySkipped.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforcePost_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);
        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckNotEnforced.selector));
        policy.enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);
        policy.enforce(subject, abi.encode(0x0), Check.PRE);
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        policy.enforce(subject, abi.encode(0x1), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policySkipped.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPostCheckWhenSkipped.selector));
        policySkipped.enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, abi.encode(0x0), Check.PRE);
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(notOwner, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, abi.encode(0x0), Check.PRE);
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.POST);

        policy.enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, abi.encode(0x0), Check.PRE);
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);
        policy.enforce(subject, abi.encode(0x0), Check.POST);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policy.enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPreCheckWhenSkipped.selector));
        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(notOwner, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.PRE);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.PreCheckNotEnforced.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.MAIN);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenMultipleValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.MAIN);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.MAIN);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenMultipleNotAllowed_reverts() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckAlreadyEnforced.selector));
        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckNotEnforced.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        policyHarness.exposed__enforce(subject, abi.encode(0x1), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPostCheckWhenSkipped.selector));
        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(notOwner, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit IAdvancedPolicy.Enforced(subject, target, abi.encode(0x0), Check.POST);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }
}

contract Voting is Test {
    NFT internal nft;
    AdvancedERC721Checker internal checker;
    AdvancedERC721Policy internal policy;
    AdvancedVoting internal voting;

    address public deployer = vm.addr(0x1);
    address public subject = vm.addr(0x2);
    address public notOwner = vm.addr(0x3);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        checker = new AdvancedERC721Checker(nft, 1, 0, 10);
        policy = new AdvancedERC721Policy(checker, false, false, true);
        voting = new AdvancedVoting(policy);

        vm.stopPrank();
    }

    function test_register_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(deployer);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        voting.register(0);

        vm.stopPrank();
    }

    function test_register_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        voting.register(1);

        vm.stopPrank();
    }

    function test_register_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        voting.register(0);

        vm.stopPrank();
    }

    function test_register_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectEmit(true, true, true, true);
        emit AdvancedVoting.Registered(subject);

        voting.register(0);

        vm.stopPrank();
    }

    function test_register_whenAlreadyRegistered_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        voting.register(0);

        vm.stopPrank();
    }

    function test_vote_whenNotRegistered_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotRegistered.selector));
        voting.vote(0);

        vm.stopPrank();
    }

    function test_vote_whenInvalidOption_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);
        voting.register(0);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.InvalidOption.selector));
        voting.vote(3);

        vm.stopPrank();
    }

    function test_vote_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);
        voting.register(0);

        vm.expectEmit(true, true, true, true);
        emit AdvancedVoting.Voted(subject, 0);

        voting.vote(0);

        vm.stopPrank();
    }

    function test_vote_whenMultipleValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        vm.expectEmit(true, true, true, true);
        emit AdvancedVoting.Voted(subject, 0);
        voting.vote(0);

        vm.stopPrank();
    }

    function test_reward_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        voting.reward(1);

        vm.stopPrank();
    }

    function test_reward_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);
        nft.mint(notOwner);

        vm.stopPrank();

        vm.startPrank(notOwner);

        voting.register(1);
        voting.vote(0);

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        voting.reward(1);

        vm.stopPrank();
    }

    function test_reward_whenNotRegistered_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotRegistered.selector));
        voting.reward(0);

        vm.stopPrank();
    }

    function test_reward_whenNotVoted_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);
        voting.register(0);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotVoted.selector));
        voting.reward(0);

        vm.stopPrank();
    }

    function test_reward_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        vm.expectEmit(true, true, true, true);
        emit AdvancedVoting.RewardClaimed(subject, 0);

        voting.reward(0);

        vm.stopPrank();
    }

    function test_reward_whenAlreadyClaimed_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);
        voting.reward(0);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.AlreadyClaimed.selector));
        voting.reward(0);

        vm.stopPrank();
    }
}
