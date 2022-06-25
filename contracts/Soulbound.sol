// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract SBT is ERC721 {
    // Non transferable

    // all transfer functions
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal pure override {
        revert("SBT: Token cannot be transfered");
    }

    // approve functions

    function approve(address to, uint256 tokenId) public pure override {
        revert("SBT: Token cannot be transfered");
    }

    function setApprovalForAll(address operator, bool approved)
        public
        pure
        override
    {
        revert("SBT: Token cannot be transfered");
    }
}
