// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint256 private _tokenIdCounter;

    constructor() ERC721("NFT", "NFT") {}

    function mint(address to) external {
        _safeMint(to, _tokenIdCounter);
        _tokenIdCounter++;
    }
}
