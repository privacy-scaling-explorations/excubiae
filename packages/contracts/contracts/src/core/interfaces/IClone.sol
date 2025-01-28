// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IClone {
    error AlreadyInitialized();

    function initialize() external;

    function getAppendedBytes() external returns (bytes memory);
}
