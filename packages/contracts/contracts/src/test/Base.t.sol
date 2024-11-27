// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/src/Test.sol";
import {NFT} from "./utils/NFT.sol";
import {BaseERC721Checker} from "./base/BaseERC721Checker.sol";
import {BaseERC721Policy} from "./base/BaseERC721Policy.sol";
import {BaseVoting} from "./base/BaseVoting.sol";
import {BaseERC721CheckerHarness} from "./wrappers/BaseERC721CheckerHarness.sol";
import {BaseERC721PolicyHarness} from "./wrappers/BaseERC721PolicyHarness.sol";
import {IPolicy} from "../interfaces/IPolicy.sol";
import {IBasePolicy} from "../interfaces/IBasePolicy.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BaseChecker is Test {
    NFT internal nft;
    BaseERC721Checker internal checker;
    BaseERC721CheckerHarness internal checkerHarness;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        checker = new BaseERC721Checker(nft);
        checkerHarness = new BaseERC721CheckerHarness(nft);

        vm.stopPrank();
    }

    function test_check_internal_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        checkerHarness.exposed__check(subject, abi.encode(0));

        vm.stopPrank();
    }

    function test_check_internal_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checkerHarness.exposed__check(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_check_Internal() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checkerHarness.exposed__check(subject, abi.encode(0)));

        vm.stopPrank();
    }

    function test_check_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        checker.check(subject, abi.encode(0));

        vm.stopPrank();
    }

    function test_check_return_False() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(!checker.check(notOwner, abi.encode(0)));

        vm.stopPrank();
    }

    function test_check() public {
        vm.startPrank(target);

        nft.mint(subject);

        assert(checker.check(subject, abi.encode(0)));

        vm.stopPrank();
    }
}

contract BasePolicy is Test {
    NFT internal nft;
    BaseERC721Checker internal checker;
    BaseERC721Policy internal policy;
    BaseERC721CheckerHarness internal checkerHarness;
    BaseERC721PolicyHarness internal policyHarness;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        checker = new BaseERC721Checker(nft);
        checkerHarness = new BaseERC721CheckerHarness(nft);
        policy = new BaseERC721Policy(checker);
        policyHarness = new BaseERC721PolicyHarness(checker);

        vm.stopPrank();
    }

    function test_trait() public view {
        assertEq(policy.trait(), "BaseERC721");
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

    function test_enforce_RevertWhen_TargetOnly() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(subject);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
        policy.enforce(subject, abi.encode(0x0));

        vm.stopPrank();
    }

    function test_enforce_RevertWhen_ERC721NonexistentToken() public {
        vm.startPrank(deployer);

        policy.setTarget(target);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
        policy.enforce(subject, abi.encode(0x0));

        vm.stopPrank();
    }

    function test_enforce_RevertWhen_UnsuccessfulCheck() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
        policy.enforce(notOwner, abi.encode(0x0));

        vm.stopPrank();
    }

    function test_enforce() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        vm.expectEmit(true, true, true, true);
        emit IBasePolicy.Enforced(subject, target, abi.encode(0x0));

        policy.enforce(subject, abi.encode(0x0));

        vm.stopPrank();
    }

    function test_enforce_RevertWhen_AlreadyEnforced() public {
        vm.startPrank(deployer);

        policy.setTarget(target);
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(target);

        policy.enforce(subject, abi.encode(0x0));

        vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
        policy.enforce(subject, abi.encode(0x0));

        vm.stopPrank();
    }
}

contract Voting is Test {
    NFT internal nft;
    BaseERC721Checker internal checker;
    BaseERC721Policy internal policy;
    BaseVoting internal voting;
    BaseERC721CheckerHarness internal checkerHarness;
    BaseERC721PolicyHarness internal policyHarness;

    address public deployer = vm.addr(0x1);
    address public subject = vm.addr(0x2);
    address public notOwner = vm.addr(0x3);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        checker = new BaseERC721Checker(nft);
        checkerHarness = new BaseERC721CheckerHarness(nft);
        policy = new BaseERC721Policy(checker);
        policyHarness = new BaseERC721PolicyHarness(checker);
        voting = new BaseVoting(policy);

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
        emit BaseVoting.Registered(subject);

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

        vm.expectRevert(abi.encodeWithSelector(BaseVoting.NotRegistered.selector));
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

        vm.expectRevert(abi.encodeWithSelector(BaseVoting.InvalidOption.selector));
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
        emit BaseVoting.Voted(subject, 0);

        voting.vote(0);

        vm.stopPrank();
    }

    function test_vote_RevertWhen_AlreadyVoted() public {
        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        voting.vote(0);

        vm.expectRevert(abi.encodeWithSelector(BaseVoting.AlreadyVoted.selector));
        voting.vote(0);

        vm.stopPrank();
    }
}
