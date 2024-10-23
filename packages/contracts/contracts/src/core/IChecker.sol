// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

interface IChecker {
    function checkPre(address passerby, bytes memory data) external view;
    function checkMain(address passerby, bytes memory data) external view;
    function checkPost(address passerby, bytes memory data) external view;
}
