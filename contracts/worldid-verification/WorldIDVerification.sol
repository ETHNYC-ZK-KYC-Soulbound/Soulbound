// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MainVerification.sol";
import "./WorldIDRegistry.sol";

contract WorldIDVerification is WorldIDRegistry, MainVerification {
    constructor(
        address _worldId,
        address[] memory _initialVerifiers,
        address _admin,
        string memory _tokenURI
    ) MainVerification(_initialVerifiers, _admin, _tokenURI) WorldIDRegistry(_worldId) {}

    function addSubmission(
        address[] memory verifiers,
        string[] memory cids,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external {
        WorldIDRegistry._verify(root, nullifierHash, proof);

        _addSubmission(verifiers, cids);
    }
}
