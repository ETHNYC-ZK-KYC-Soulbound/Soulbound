// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Soulbound.sol";

contract ProofToken is SBT {
    constructor() ERC721("Proof Token", "PROOF") {}
}
