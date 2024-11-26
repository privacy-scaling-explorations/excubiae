// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/src/Test.sol";
import {NFT} from "../src/test/NFT.sol";
import {BaseERC721Checker} from "../src/test/BaseERC721Checker.sol";
import {BaseERC721CheckerHarness} from "./wrappers/BaseERC721CheckerHarness.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

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
