// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MainVerification.sol";

contract L2Verification is MainVerification {
    constructor(
        address[] memory _initialApprovers,
        address _admin,
        string memory _tokenURI
    ) MainVerification(_initialApprovers, _admin, _tokenURI) {
        _proofOfHumanity = IProofOfHumanity(proofOfHumanity_);
    }

    function addSubmission(address[] memory approvers, string[] memory cids)
        external
    {   
        // message security layer
        _addSubmission(approvers, cids);
    }
}
