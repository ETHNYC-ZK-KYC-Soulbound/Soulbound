// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MainVerification.sol";

contract KYCVerification is MainVerification {
    constructor(
        address[] memory _initialApprovers,
        address _admin,
        string memory _tokenURI
    ) MainVerification(_initialApprovers, _admin, _tokenURI) {
    }

    function addSubmission(address[] memory approvers, string[] memory cids)
        external
    {
        _addSubmission(approvers, cids);
    }
}