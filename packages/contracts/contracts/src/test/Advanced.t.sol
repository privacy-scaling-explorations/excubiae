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
        checker = new AdvancedERC721Checker(nft, 1, 0, 10, false, false, true);
        checkerHarness = new AdvancedERC721CheckerHarness(nft, 1, 0, 10, false, false, true);

        vm.stopPrank();
    }

    function test_check_pre_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        checker.check(subject, abi.encode(0), Check.PRE);

        vm.stopPrank();
    }

    function test_check_pre_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checker.check(notOwner, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_check_pre() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checker.check(subject, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_check_main_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checker.check(notOwner, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_check_main() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checker.check(subject, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_check_post_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checker.check(subject, abi.encode(1), Check.POST);

        vm.stopPrank();
    }

    function test_check_post_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checker.check(notOwner, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_check_post() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checker.check(subject, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_check_pre_internal_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        checkerHarness.exposed__check(subject, abi.encode(0), Check.PRE);

        vm.stopPrank();
    }

    function test_check_pre_internal_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__check(notOwner, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_check_pre_internal() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__check(subject, abi.encode(0), Check.PRE));

        vm.stopPrank();
    }

    function test_check_main_internal_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__check(notOwner, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_check_main_internal() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__check(subject, abi.encode(0), Check.MAIN));

        vm.stopPrank();
    }

    function test_check_post_internal_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checkerHarness.exposed__check(subject, abi.encode(1), Check.POST);

        vm.stopPrank();
    }

    function test_check_post_internal_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__check(notOwner, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_check_post_internal() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__check(subject, abi.encode(0), Check.POST));

        vm.stopPrank();
    }

    function test_checkPre_internal_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checkerHarness.exposed__checkPre(subject, abi.encode(1));

        vm.stopPrank();
    }

    function test_checkPre_internal_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__checkPre(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_checkPre() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__checkPre(subject, abi.encode(0)));

        vm.stopPrank();
    }

    function test_checkMain_internal_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__checkMain(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_checkMain() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__checkMain(subject, abi.encode(0)));

        vm.stopPrank();
    }

    function test_checkPost_internal_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        checkerHarness.exposed__checkPost(subject, abi.encode(1));

        vm.stopPrank();
    }

    function test_checkPost_internal_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__checkPost(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_checkPost() public {
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
        checker = new AdvancedERC721Checker(nft, 1, 0, 10, false, false, true);
        checkerSkipped = new AdvancedERC721Checker(nft, 1, 0, 10, true, true, false);
        policy = new AdvancedERC721Policy(checker);
        policyHarness = new AdvancedERC721PolicyHarness(checker);
        policySkipped = new AdvancedERC721Policy(checkerSkipped);
        policyHarnessSkipped = new AdvancedERC721PolicyHarness(checkerSkipped);

        vm.stopPrank();
    }

    function test_trait() public view {
        assertEq(policy.trait(), "AdvancedERC721");
    }

    function test_setTarget_RevertWhen_OwnableUnauthorizedAccount() public {
        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
        policy.setTarget(target);

        vm.stopPrank();
    }

    function test_setTarget_RevertWhen_ZeroAddress() public {
        vm.startPrank(deployer);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.ZeroAddress.selector));
        policy.setTarget(address(0));

        vm.stopPrank();
    }

    function test_setTarget() public {
        vm.startPrank(deployer);

        vm.expectEmit(true, true, true, true);
        emit IPolicy.TargetSet(target);

        policy.setTarget(target);

        vm.stopPrank();
    }

    function test_setTarget_RevertWhen_TargetAlreadySet() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetAlreadySet.selector));
        policy.setTarget(target);

        vm.stopPrank();
    }

    function test_enforce_pre_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        policy.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre_RevertWhen_PreCheckSkipped() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedChecker.PreCheckSkipped.selector));
        policySkipped.enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre_RevertWhen_UnsuccessfulCheck() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(notOwner, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre() public {
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

    function test_enforce_pre_RevertWhen_AlreadyEnforced() public {
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

    function test_enforce_main_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforce_main_RevertWhen_UnsuccessfulCheck() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforce_main_RevertWhen_PreCheckNotEnforced() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.PreCheckNotEnforced.selector));
        policy.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforce_main() public {
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

    function test_enforce_main_twice() public {
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

    function test_enforce_main_RevertWhen_MainCheckAlreadyEnforced() public {
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

    function test_enforce_post_RevertWhen_PreCheckNotEnforced() public {
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

    function test_enforce_post_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforce_post_RevertWhen_ERC721NonexistentToken() public {
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

    function test_enforce_post_RevertWhen_PreCheckSkipped() public {
        vm.startPrank(deployer);

        policySkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policySkipped.enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedChecker.PostCheckSkipped.selector));
        policySkipped.enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforce_post_RevertWhen_UnsuccessfulCheck() public {
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

    function test_enforce_post() public {
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

    function test_enforce_post_RevertWhen_AlreadyEnforced() public {
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

    function test_enforce_pre_internal_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre_internal_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre_internal_RevertWhen_PreCheckSkipped() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedChecker.PreCheckSkipped.selector));
        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre_internal_RevertWhen_UnsuccessfulCheck() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(notOwner, abi.encode(0x0), Check.PRE);

        vm.stopPrank();
    }

    function test_enforce_pre_internal() public {
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

    function test_enforce_pre_internal_RevertWhen_AlreadyEnforced() public {
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

    function test_enforce_main_internal_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforce_main_internal_RevertWhen_UnsuccessfulCheck() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforce_main_internal_RevertWhen_PreCheckNotEnforced() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedPolicy.PreCheckNotEnforced.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.stopPrank();
    }

    function test_enforce_main_internal() public {
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

    function test_enforce_main_internal_twice() public {
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

    function test_enforce_main_internal_RevertWhen_MainCheckAlreadyEnforced() public {
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

    function test_enforce_post_internal_RevertWhen_PreCheckNotEnforced() public {
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

    function test_enforce_post_internal_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policyHarness.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policyHarness.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforce_post_internal_RevertWhen_ERC721NonexistentToken() public {
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

    function test_enforce_post_internal_RevertWhen_PreCheckSkipped() public {
        vm.startPrank(deployer);

        policyHarnessSkipped.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.MAIN);

        vm.expectRevert(abi.encodeWithSelector(IAdvancedChecker.PostCheckSkipped.selector));
        policyHarnessSkipped.exposed__enforce(subject, abi.encode(0x0), Check.POST);

        vm.stopPrank();
    }

    function test_enforce_post_internal_RevertWhen_UnsuccessfulCheck() public {
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

    function test_enforce_post_internal() public {
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

    function test_enforce_post_internal_RevertWhen_AlreadyEnforced() public {
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
        checker = new AdvancedERC721Checker(nft, 1, 0, 10, false, false, true);
        policy = new AdvancedERC721Policy(checker);
        voting = new AdvancedVoting(policy);

        vm.stopPrank();
    }

    function test_register_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policy.setTarget(deployer);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        voting.register(0);

        vm.stopPrank();
    }

    function test_register_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
        voting.register(1);

        vm.stopPrank();
    }

    function test_register_RevertWhen_UnsuccessfulCheck() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(notOwner);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        voting.register(0);

        vm.stopPrank();
    }

    function test_register() public {
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

    function test_register_RevertWhen_AlreadyEnforced() public {
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

    function test_vote_RevertWhen_NotRegistered() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotRegistered.selector));
        voting.vote(0);

        vm.stopPrank();
    }

    function test_vote_RevertWhen_InvalidOption() public {
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

    function test_vote() public {
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

    function test_vote_twice() public {
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

    function test_reward_RevertWhen_ERC721NonexistentToken() public {
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

    function test_reward_RevertWhen_UnsuccessfulCheck() public {
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

    function test_reward_RevertWhen_NotRegistered() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(AdvancedVoting.NotRegistered.selector));
        voting.reward(0);

        vm.stopPrank();
    }

    function test_reward_RevertWhen_NotVoted() public {
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

    function test_reward() public {
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

    function test_reward_RevertWhen_AlreadyClaimed() public {
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
