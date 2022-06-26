// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MainVerification.sol";
import "./IProofOfHumanity.sol";

contract PoHVerification is MainVerification {
    IProofOfHumanity private _proofOfHumanity;

    constructor(
        address proofOfHumanity_,
        address[] memory _initialApprovers,
        address _admin,
        string memory _tokenURI
    ) MainVerification(_initialApprovers, _admin, _tokenURI) {
        _proofOfHumanity = IProofOfHumanity(proofOfHumanity_);
    }

    function addSubmission(address[] memory approvers, string[] memory cids)
        external
    {
        require(
            _proofOfHumanity.isRegistered(msg.sender),
            "Caller is not registered in PoH"
        );

        _addSubmission(approvers, cids);
    }

    function proofOfHumanity() external view returns (address) {
        return address(_proofOfHumanity);
    }
}
