// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/src/Test.sol";
import {NFT} from "./utils/NFT.sol";
import {BaseERC721Checker} from "./base/BaseERC721Checker.sol";
import {BaseERC721CheckerFactory} from "./base/BaseERC721CheckerFactory.sol";
import {BaseERC721PolicyFactory} from "./base/BaseERC721PolicyFactory.sol";
import {BaseERC721Policy} from "./base/BaseERC721Policy.sol";
import {BaseVoting} from "./base/BaseVoting.sol";
import {IPolicy} from "../core/interfaces/IPolicy.sol";
import {IChecker} from "../core/interfaces/IChecker.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// @todo add harnesses
// @todo add tests for factories + harnesses
// @todo add edge cases

contract BaseChecker is Test {
    NFT internal nft;
    BaseERC721Checker internal checker;
    BaseERC721CheckerFactory internal factory;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    address[] internal verifiers;
    bytes[] public evidence = new bytes[](1);

    function setUp() public {
        vm.startPrank(deployer);

        nft = new NFT();
        nft.mint(subject);

        factory = new BaseERC721CheckerFactory();
        address clone = factory.createERC721Checker(address(nft));
        checker = BaseERC721Checker(clone);

        evidence[0] = abi.encode(0);

        vm.stopPrank();
    }

    function test_simple() public {
        bool result = checker.check(subject, evidence);
        assertTrue(result, "Expected subject to own token 0");
    }

    /// @todo refactoring
    // function test_getVerifierAtIndex_ReturnsCorrectAddress() public view {
    //     assertEq(checker.getVerifierAtIndex(0), address(nft));
    // }

    // function test_getVerifierAtIndex_RevertWhen_VerifierNotFound() public {
    //     vm.expectRevert(abi.encodeWithSelector(IChecker.VerifierNotFound.selector));
    //     checker.getVerifierAtIndex(1);
    // }

    // function test_getVerifierAtIndex_internal_ReturnsCorrectAddress() public view {
    //     assertEq(checkerHarness.exposed__getVerifierAtIndex(0), address(nft));
    // }

    // function test_getVerifierAtIndex_internal_RevertWhen_VerifierNotFound() public {
    //     vm.expectRevert(abi.encodeWithSelector(IChecker.VerifierNotFound.selector));
    //     checkerHarness.exposed__getVerifierAtIndex(1);
    // }

    // function test_checker_whenTokenDoesNotExist_reverts() public {
    //     vm.startPrank(target);

    //     vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
    //     checkerHarness.exposed__check(subject, evidence);

    //     vm.stopPrank();
    // }

    // function test_checker_whenCallerNotOwner_returnsFalse() public {
    //     vm.startPrank(target);

    //     nft.mint(subject);

    //     assert(!checkerHarness.exposed__check(notOwner, evidence));

    //     vm.stopPrank();
    // }

    // function test_checker_whenCallerIsOwner_succeeds() public {
    //     vm.startPrank(target);

    //     nft.mint(subject);

    //     assert(checkerHarness.exposed__check(subject, evidence));

    //     vm.stopPrank();
    // }

    // function test_checkerExternal_whenTokenDoesNotExist_reverts() public {
    //     vm.startPrank(target);

    //     vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
    //     checker.check(subject, evidence);

    //     vm.stopPrank();
    // }

    // function test_checkerExternal_whenCallerNotOwner_returnsFalse() public {
    //     vm.startPrank(target);

    //     nft.mint(subject);

    //     assert(!checker.check(notOwner, evidence));

    //     vm.stopPrank();
    // }

    // function test_checkerExternal_whenCallerIsOwner_succeeds() public {
    //     vm.startPrank(target);

    //     nft.mint(subject);

    //     assert(checker.check(subject, evidence));

    //     vm.stopPrank();
    // }
}

contract BasePolicy is Test {
    event TargetSet(address indexed target);
    event Enforced(address indexed subject, address indexed target, bytes[] evidence);

    NFT internal nft;
    BaseERC721Checker internal checker;
    BaseERC721CheckerFactory internal checkerFactory;
    BaseERC721Policy internal policy;
    BaseERC721PolicyFactory internal policyFactory;

    address public deployer = vm.addr(0x1);
    address public target = vm.addr(0x2);
    address public subject = vm.addr(0x3);
    address public notOwner = vm.addr(0x4);

    bytes[] public evidence = new bytes[](1);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        nft.mint(subject);

        checkerFactory = new BaseERC721CheckerFactory();
        address checkerClone = checkerFactory.createERC721Checker(address(nft));
        checker = BaseERC721Checker(checkerClone);

        policyFactory = new BaseERC721PolicyFactory();
        address policyClone = policyFactory.createERC721Policy(address(checker));
        policy = BaseERC721Policy(policyClone);

        evidence[0] = abi.encode(0);

        vm.stopPrank();
    }

    function test_simple() public {
        assertEq(policy.owner(), address(deployer));
        assertEq(policy.trait(), "BaseERC721");
    }
    // @todo refactoring
    //     function test_trait_returnsCorrectValue() public view {
    //         assertEq(policy.trait(), "BaseERC721");
    //     }

    //     function test_getTarget_returnsExpectedAddress() public {
    //         vm.startPrank(deployer);

    //         policy.setTarget(target);

    //         assertEq(policy.getTarget(), target);

    //         vm.stopPrank();
    //     }

    //     function test_setTarget_whenCallerNotOwner_reverts() public {
    //         vm.startPrank(notOwner);

    //         vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
    //         policy.setTarget(target);

    //         vm.stopPrank();
    //     }

    //     function test_setTarget_whenZeroAddress_reverts() public {
    //         vm.startPrank(deployer);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.ZeroAddress.selector));
    //         policy.setTarget(address(0));

    //         vm.stopPrank();
    //     }

    //     function test_setTarget_whenValidAddress_succeeds() public {
    //         vm.startPrank(deployer);

    //         vm.expectEmit(true, true, true, true);
    //         emit TargetSet(target);

    //         policy.setTarget(target);

    //         vm.stopPrank();
    //     }

    //     function test_setTarget_whenAlreadySet_reverts() public {
    //         vm.startPrank(deployer);

    //         policy.setTarget(target);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetAlreadySet.selector));
    //         policy.setTarget(target);

    //         vm.stopPrank();
    //     }

    //     function test_enforce_whenCallerNotTarget_reverts() public {
    //         vm.startPrank(deployer);

    //         policy.setTarget(target);

    //         vm.stopPrank();

    //         vm.startPrank(subject);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
    //         policy.enforce(subject, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforce_whenTokenDoesNotExist_reverts() public {
    //         vm.startPrank(deployer);

    //         policy.setTarget(target);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
    //         policy.enforce(subject, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforce_whenCheckFails_reverts() public {
    //         vm.startPrank(deployer);

    //         policy.setTarget(target);
    //         nft.mint(subject);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
    //         policy.enforce(notOwner, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforce_whenValid_succeeds() public {
    //         vm.startPrank(deployer);

    //         policy.setTarget(target);
    //         nft.mint(subject);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         vm.expectEmit(true, true, true, true);
    //         emit Enforced(subject, target, evidence);

    //         policy.enforce(subject, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforce_whenAlreadyEnforced_reverts() public {
    //         vm.startPrank(deployer);

    //         policy.setTarget(target);
    //         nft.mint(subject);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         policy.enforce(subject, evidence);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
    //         policy.enforce(subject, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforceInternal_whenCallerNotTarget_reverts() public {
    //         vm.startPrank(deployer);

    //         policyHarness.setTarget(target);

    //         vm.stopPrank();

    //         vm.startPrank(subject);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
    //         policyHarness.exposed__enforce(subject, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforceInternal_whenTokenDoesNotExist_reverts() public {
    //         vm.startPrank(deployer);

    //         policyHarness.setTarget(target);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(0)));
    //         policyHarness.exposed__enforce(subject, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforceInternal_whenCheckFails_reverts() public {
    //         vm.startPrank(deployer);

    //         policyHarness.setTarget(target);
    //         nft.mint(subject);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
    //         policyHarness.exposed__enforce(notOwner, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforceInternal_whenValid_succeeds() public {
    //         vm.startPrank(deployer);

    //         policyHarness.setTarget(target);
    //         nft.mint(subject);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         vm.expectEmit(true, true, true, true);
    //         emit Enforced(subject, target, evidence);

    //         policyHarness.exposed__enforce(subject, evidence);

    //         vm.stopPrank();
    //     }

    //     function test_enforceInternal_whenAlreadyEnforced_reverts() public {
    //         vm.startPrank(deployer);

    //         policyHarness.setTarget(target);
    //         nft.mint(subject);

    //         vm.stopPrank();

    //         vm.startPrank(target);

    //         policyHarness.exposed__enforce(subject, evidence);

    //         vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
    //         policyHarness.exposed__enforce(subject, evidence);

    //         vm.stopPrank();
    //     }
}

contract Voting is Test {
    event Registered(address voter);
    event Voted(address voter, uint8 option);

    NFT internal nft;
    BaseERC721Checker internal checker;
    BaseERC721CheckerFactory internal checkerFactory;
    BaseERC721Policy internal policy;
    BaseERC721PolicyFactory internal policyFactory;
    BaseVoting internal voting;

    address public deployer = vm.addr(0x1);
    address public subject = vm.addr(0x2);
    address public notOwner = vm.addr(0x3);

    function setUp() public virtual {
        vm.startPrank(deployer);

        nft = new NFT();
        nft.mint(subject);

        checkerFactory = new BaseERC721CheckerFactory();
        address checkerClone = checkerFactory.createERC721Checker(address(nft));
        checker = BaseERC721Checker(checkerClone);

        policyFactory = new BaseERC721PolicyFactory();
        address policyClone = policyFactory.createERC721Policy(address(checker));
        policy = BaseERC721Policy(policyClone);

        voting = new BaseVoting(policy);

        vm.stopPrank();
    }

    function test_simple() public {
        assertEq(address(voting.POLICY()), address(policy));

        vm.startPrank(deployer);

        policy.setTarget(address(voting));
        nft.mint(subject);

        vm.stopPrank();

        vm.startPrank(subject);

        voting.register(0);
        vm.stopPrank();
    }

    // @todo refactoring

    // function test_register_whenCallerNotTarget_reverts() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(deployer);
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(notOwner);

    //     vm.expectRevert(abi.encodeWithSelector(IPolicy.TargetOnly.selector));
    //     voting.register(0);

    //     vm.stopPrank();
    // }

    // function test_register_whenTokenDoesNotExist_reverts() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(subject);

    //     vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(1)));
    //     voting.register(1);

    //     vm.stopPrank();
    // }

    // function test_register_whenCheckFails_reverts() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(notOwner);

    //     vm.expectRevert(abi.encodeWithSelector(IPolicy.UnsuccessfulCheck.selector));
    //     voting.register(0);

    //     vm.stopPrank();
    // }

    // function test_register_whenValid_succeeds() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(subject);

    //     vm.expectEmit(true, true, true, true);
    //     emit Registered(subject);

    //     voting.register(0);

    //     vm.stopPrank();
    // }

    // function test_register_whenAlreadyRegistered_reverts() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(subject);

    //     voting.register(0);

    //     vm.expectRevert(abi.encodeWithSelector(IPolicy.AlreadyEnforced.selector));
    //     voting.register(0);

    //     vm.stopPrank();
    // }

    // function test_vote_whenNotRegistered_reverts() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(subject);

    //     vm.expectRevert(abi.encodeWithSelector(BaseVoting.NotRegistered.selector));
    //     voting.vote(0);

    //     vm.stopPrank();
    // }

    // function test_vote_whenInvalidOption_reverts() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(subject);
    //     voting.register(0);

    //     vm.expectRevert(abi.encodeWithSelector(BaseVoting.InvalidOption.selector));
    //     voting.vote(3);

    //     vm.stopPrank();
    // }

    // function test_vote_whenValid_succeeds() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(subject);
    //     voting.register(0);

    //     vm.expectEmit(true, true, true, true);
    //     emit Voted(subject, 0);

    //     voting.vote(0);

    //     vm.stopPrank();
    // }

    // function test_vote_whenAlreadyVoted_reverts() public {
    //     vm.startPrank(deployer);

    //     policy.setTarget(address(voting));
    //     nft.mint(subject);

    //     vm.stopPrank();

    //     vm.startPrank(subject);

    //     voting.register(0);
    //     voting.vote(0);

    //     vm.expectRevert(abi.encodeWithSelector(BaseVoting.AlreadyVoted.selector));
    //     voting.vote(0);

    //     vm.stopPrank();
    // }
}
