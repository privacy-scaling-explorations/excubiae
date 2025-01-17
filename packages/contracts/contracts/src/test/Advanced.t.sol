// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/src/Test.sol";
import {NFT} from "./utils/NFT.sol";
import {BaseERC721Checker} from "./base/BaseERC721Checker.sol";
import {AdvancedERC721Checker} from "./advanced/AdvancedERC721Checker.sol";
import {AdvancedERC721Policy} from "./advanced/AdvancedERC721Policy.sol";
import {AdvancedVoting} from "./advanced/AdvancedVoting.sol";
import {AdvancedERC721CheckerHarness} from "./wrappers/AdvancedERC721CheckerHarness.sol";
import {AdvancedERC721PolicyHarness} from "./wrappers/AdvancedERC721PolicyHarness.sol";
import {IChecker} from "../interfaces/IChecker.sol";
import {IPolicy} from "../interfaces/IPolicy.sol";
import {IAdvancedPolicy} from "../interfaces/IAdvancedPolicy.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Check} from "../interfaces/IAdvancedChecker.sol";

contract AdvancedChecker is Test {
    NFT internal signupNft;
    NFT internal rewardNft;
    BaseERC721Checker internal baseChecker;
    AdvancedERC721Checker internal advancedChecker;
    AdvancedERC721CheckerHarness internal advancedCheckerHarness;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    address[] internal baseVerifiers;
    address[] internal advancedVerifiers;
    bytes[] public evidence = new bytes[](1);
    bytes[] public wrongEvidence = new bytes[](1);

    function setUp() public virtual {
        vm.startPrank(deployer);

        signupNft = new NFT();
        rewardNft = new NFT();

        baseVerifiers = new address[](1);
        baseVerifiers[0] = address(signupNft);
        baseChecker = new BaseERC721Checker(baseVerifiers);

        advancedVerifiers = new address[](3);
        advancedVerifiers[0] = address(signupNft);
        advancedVerifiers[1] = address(rewardNft);
        advancedVerifiers[2] = address(baseChecker);

        advancedChecker = new AdvancedERC721Checker(advancedVerifiers, 1, 0, 10);
        advancedCheckerHarness = new AdvancedERC721CheckerHarness(advancedVerifiers, 1, 0, 10);

        evidence[0] = abi.encode(0);
        wrongEvidence[0] = abi.encode(1);

        vm.stopPrank();
    }

    function test_getVerifierAtIndex_ReturnsCorrectAddress() public view {
        assertEq(advancedChecker.getVerifierAtIndex(0), address(signupNft));
    }

    function test_getVerifierAtIndex_RevertWhen_VerifierNotFound() public {
        vm.expectRevert(abi.encodeWithSelector(IChecker.VerifierNotFound.selector));
        advancedChecker.getVerifierAtIndex(5);
    }

    function test_getVerifierAtIndex_internal_ReturnsCorrectAddress() public view {
        assertEq(advancedCheckerHarness.exposed__getVerifierAtIndex(0), address(signupNft));
    }

    function test_getVerifierAtIndex_internal_RevertWhen_VerifierNotFound() public {
        vm.expectRevert(abi.encodeWithSelector(IChecker.VerifierNotFound.selector));
        advancedCheckerHarness.exposed__getVerifierAtIndex(5);
    }

    function test_checkPre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        advancedChecker.check(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_checkPre_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(!advancedChecker.check(notOwner, evidence, Check.PRE));

        vm.stopPrank();
    }

    function test_checkPre_whenValid_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedChecker.check(subject, evidence, Check.PRE));

        vm.stopPrank();
    }

    function test_checkMain_whenCallerHasNoTokens_returnsFalse() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(!advancedChecker.check(notOwner, evidence, Check.MAIN));

        vm.stopPrank();
    }

    function test_checkMain_whenCallerHasTokens_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedChecker.check(subject, evidence, Check.MAIN));

        vm.stopPrank();
    }

    function test_checkPost_whenCallerBalanceGreaterThanZero_returnsFalse() public {
        vm.startPrank(target);

        rewardNft.mint(subject);

        assert(!advancedChecker.check(subject, evidence, Check.POST));

        vm.stopPrank();
    }

    function test_checkPost_whenValid_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedChecker.check(subject, evidence, Check.POST));

        vm.stopPrank();
    }

    function test_checkerPre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        advancedCheckerHarness.exposed__check(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_checkerPre_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(!advancedCheckerHarness.exposed__check(notOwner, evidence, Check.PRE));

        vm.stopPrank();
    }

    function test_checkerPre_whenValid_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedCheckerHarness.exposed__check(subject, evidence, Check.PRE));

        vm.stopPrank();
    }

    function test_checkerMain_whenCallerHasNoTokens_returnsFalse() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(!advancedCheckerHarness.exposed__check(notOwner, evidence, Check.MAIN));

        vm.stopPrank();
    }

    function test_checkerMain_whenCallerHasTokens_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedCheckerHarness.exposed__check(subject, evidence, Check.MAIN));

        vm.stopPrank();
    }

    function test_checkerPost_whenCallerBalanceGreaterThanZero_returnsFalse() public {
        vm.startPrank(target);

        rewardNft.mint(subject);

        assert(!advancedCheckerHarness.check(subject, evidence, Check.POST));

        vm.stopPrank();
    }

    function test_checkerPost_whenValid_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedCheckerHarness.exposed__check(subject, evidence, Check.POST));

        vm.stopPrank();
    }

    function test_internalPre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        advancedCheckerHarness.exposed__checkPre(subject, wrongEvidence);

        vm.stopPrank();
    }

    function test_internalPre_whenCallerNotOwner_returnsFalse() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(!advancedCheckerHarness.exposed__checkPre(notOwner, evidence));

        vm.stopPrank();
    }

    function test_internalPre_whenValid_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedCheckerHarness.exposed__checkPre(subject, evidence));

        vm.stopPrank();
    }

    function test_internalMain_whenCallerHasNoTokens_returnsFalse() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(!advancedCheckerHarness.exposed__checkMain(notOwner, evidence));

        vm.stopPrank();
    }

    function test_internalMain_whenCallerHasTokens_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedCheckerHarness.exposed__checkMain(subject, evidence));

        vm.stopPrank();
    }

    function test_internalPost_whenCallerBalanceGreaterThanZero_returnsFalse() public {
        vm.startPrank(target);

        rewardNft.mint(subject);

        assert(!advancedCheckerHarness.exposed__checkPost(subject, evidence));

        vm.stopPrank();
    }

    function test_internalPost_whenValid_succeeds() public {
        vm.startPrank(target);

        signupNft.mint(subject);

        assert(advancedCheckerHarness.exposed__checkPost(subject, evidence));

        vm.stopPrank();
    }
}

contract AdvancedPolicy is Test {
    event TargetSet(address indexed target);
    event Enforced(address indexed subject, address indexed target, bytes[] evidence, Check checkType);

    NFT internal signupNft;
    NFT internal rewardNft;
    BaseERC721Checker internal baseChecker;
    AdvancedERC721Checker internal advancedChecker;
    AdvancedERC721Checker internal advancedCheckerSkipped;
    AdvancedERC721Policy internal policy;
    AdvancedERC721Policy internal policySkipped;
    AdvancedERC721PolicyHarness internal policyHarness;
    AdvancedERC721PolicyHarness internal policyHarnessSkipped;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    address[] internal baseVerifiers;
    address[] internal advancedVerifiers;
    bytes[] public evidence = new bytes[](1);
    bytes[] public wrongEvidence = new bytes[](1);

    function setUp() public virtual {
        vm.startPrank(deployer);

        signupNft = new NFT();
        rewardNft = new NFT();

        baseVerifiers = new address[](1);
        baseVerifiers[0] = address(signupNft);
        baseChecker = new BaseERC721Checker(baseVerifiers);

        advancedVerifiers = new address[](3);
        advancedVerifiers[0] = address(signupNft);
        advancedVerifiers[1] = address(rewardNft);
        advancedVerifiers[2] = address(baseChecker);

        advancedChecker = new AdvancedERC721Checker(advancedVerifiers, 1, 0, 10);
        advancedCheckerSkipped = new AdvancedERC721Checker(advancedVerifiers, 1, 0, 10);
        policy = new AdvancedERC721Policy(advancedChecker, false, false, true);
        policyHarness = new AdvancedERC721PolicyHarness(advancedChecker, false, false, true);
        policySkipped = new AdvancedERC721Policy(advancedCheckerSkipped, true, true, false);
        policyHarnessSkipped = new AdvancedERC721PolicyHarness(advancedCheckerSkipped, true, true, false);

        evidence[0] = abi.encode(0);
        wrongEvidence[0] = abi.encode(1);

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
        emit TargetSet(target);

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
        policy.enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        policy.enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPreCheckWhenSkipped.selector));
        policySkipped.enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(notOwner, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.PRE);

        policy.enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePre_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, evidence, Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policy.enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforceMain_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.PreCheckNotEnforced.selector));
        policy.enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, evidence, Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.MAIN);

        policy.enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenMultipleValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, evidence, Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.MAIN);

        policy.enforce(subject, evidence, Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.MAIN);

        policy.enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMain_whenMultipleNotAllowed_reverts() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policySkipped.enforce(subject, evidence, Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckAlreadyEnforced.selector));
        policySkipped.enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforcePost_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);
        policy.enforce(subject, evidence, Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckNotEnforced.selector));
        policy.enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policySkipped.enforce(subject, evidence, Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPostCheckWhenSkipped.selector));
        policySkipped.enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, evidence, Check.PRE);
        policy.enforce(subject, evidence, Check.MAIN);

        rewardNft.mint(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, evidence, Check.PRE);
        policy.enforce(subject, evidence, Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.POST);

        policy.enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePost_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, evidence, Check.PRE);
        policy.enforce(subject, evidence, Check.MAIN);
        policy.enforce(subject, evidence, Check.POST);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policy.enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPreCheckWhenSkipped.selector));
        policyHarnessSkipped.exposed__enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(notOwner, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.PRE);

        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforcePreInternal_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.PreCheckNotEnforced.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.MAIN);

        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenMultipleValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.MAIN);

        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.MAIN);

        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforceMainInternal_whenMultipleNotAllowed_reverts() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarnessSkipped.exposed__enforce(subject, evidence, Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckAlreadyEnforced.selector));
        policyHarnessSkipped.exposed__enforce(subject, evidence, Check.MAIN);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenPreCheckMissing_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);
        policyHarness.exposed__enforce(subject, evidence, Check.PRE);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.MainCheckNotEnforced.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenChecksSkipped_reverts() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarnessSkipped.exposed__enforce(subject, evidence, Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.CannotPostCheckWhenSkipped.selector));
        policyHarnessSkipped.exposed__enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, evidence, Check.PRE);
        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        rewardNft.mint(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, evidence, Check.PRE);
        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);

        vm.expectEmit(true, true, true, true);
        emit Enforced(subject, target, evidence, Check.POST);

        policyHarness.exposed__enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }

    function test_enforcePostInternal_whenAlreadyEnforced_reverts() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarness.exposed__enforce(subject, evidence, Check.PRE);
        policyHarness.exposed__enforce(subject, evidence, Check.MAIN);
        policyHarness.exposed__enforce(subject, evidence, Check.POST);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policyHarness.exposed__enforce(subject, evidence, Check.POST);

        vm.stopPrank();
    }
}

contract Voting is Test {
    event Registered(address voter);
    event Voted(address voter, uint8 option);
    event Eligible(address voter);

    NFT internal signupNft;
    NFT internal rewardNft;
    BaseERC721Checker internal baseChecker;
    AdvancedERC721Checker internal advancedChecker;
    AdvancedERC721Policy internal policy;
    AdvancedVoting internal voting;

    address public deployer = vm.addr(0x1);
    address public subject = vm.addr(0x2);
    address public notOwner = vm.addr(0x3);

    address[] internal baseVerifiers;
    address[] internal advancedVerifiers;

    function setUp() public virtual {
        vm.startPrank(deployer);

        signupNft = new NFT();
        rewardNft = new NFT();

        baseVerifiers = new address[](1);
        baseVerifiers[0] = address(signupNft);
        baseChecker = new BaseERC721Checker(baseVerifiers);

        advancedVerifiers = new address[](3);
        advancedVerifiers[0] = address(signupNft);
        advancedVerifiers[1] = address(rewardNft);
        advancedVerifiers[2] = address(baseChecker);

        advancedChecker = new AdvancedERC721Checker(advancedVerifiers, 1, 0, 10);
        policy = new AdvancedERC721Policy(advancedChecker, false, false, true);
        voting = new AdvancedVoting(policy);

        vm.stopPrank();
    }

    function test_register_whenCallerNotTarget_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(deployer);
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        voting.register(0);

        vm.stopPrank();
    }

    function test_register_whenTokenDoesNotExist_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        voting.register(1);

        vm.stopPrank();
    }

    function test_register_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        voting.register(0);

        vm.stopPrank();
    }

    function test_register_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectEmit(true, true, true, true);
        emit Registered(subject);

        voting.register(0);

        vm.stopPrank();
    }

    function test_register_whenAlreadyRegistered_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

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
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotRegistered.selector));
        voting.vote(0);

        vm.stopPrank();
    }

    function test_vote_whenInvalidOption_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

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
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);
        voting.register(0);

        vm.expectEmit(true, true, true, true);
        emit Voted(subject, 0);

        voting.vote(0);

        vm.stopPrank();
    }

    function test_vote_whenMultipleValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        vm.expectEmit(true, true, true, true);
        emit Voted(subject, 0);
        voting.vote(0);

        vm.stopPrank();
    }

    function test_eligible_whenCheckFails_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);
        signupNft.mint(notOwner);

        vm.stopPrank();

        vm.startPrank(notOwner);

        voting.register(1);
        voting.vote(0);

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        rewardNft.mint(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        voting.eligible();

        vm.stopPrank();
    }

    function test_eligible_whenNotRegistered_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotRegistered.selector));
        voting.eligible();

        vm.stopPrank();
    }

    function test_eligible_whenNotVoted_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);
        voting.register(0);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotVoted.selector));
        voting.eligible();

        vm.stopPrank();
    }

    function test_eligible_whenValid_succeeds() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        vm.expectEmit(true, true, true, true);
        emit Eligible(subject);

        voting.eligible();

        vm.stopPrank();
    }

    function test_eligible_whenAlreadyEligible_reverts() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        signupNft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);
        voting.eligible();

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.AlreadyEligible.selector));
        voting.eligible();

        vm.stopPrank();
    }
}
