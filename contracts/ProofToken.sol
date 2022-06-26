// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Soulbound.sol";

interface IProofToken {
    function mint(address to, string memory proof) external;
}

contract ProofToken is SBT, IProofToken, Ownable {
    using Counters for Counters.Counter;

    address public mainContract;

    mapping(uint256 => string) public proofs;

    Counters.Counter private _tokenCounter;

    string private _uri;

    modifier onlyMainContract() {
        require(msg.sender == mainContract, "Caller is not main contract");
        _;
    }

    constructor(string memory uri_) ERC721("Proof Token", "PROOF") {
        // save contract deployer (main contract)
        mainContract = msg.sender;
        _uri = uri_;
    }

    function mint(address to, string memory proof) external onlyMainContract {
        _tokenCounter.increment();
        uint256 tokenId = _tokenCounter.current();

        _safeMint(to, tokenId);
        proofs[tokenId] = proof;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenCounter.current();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _uri;
    }
}
