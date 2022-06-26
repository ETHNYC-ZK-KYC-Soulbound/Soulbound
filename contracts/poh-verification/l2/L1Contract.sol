// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

// And pretend this is on L1
contract MyOtherContract {
    address public l2VerificationAddress;
    address public crossDomainMessengerAddr;

    IProofOfHumanity private _proofOfHumanity;

    constructor(address proofOfHumanity_, address crossDomainMessengerAddr_) {
        _proofOfHumanity = IProofOfHumanity(proofOfHumanity_);
        crossDomainMessengerAddr = crossDomainMessengerAddr_;
    }

    function submit(address[] memory approvers, string[] memory cids, uint256 gasLimit) public {
        require(
            _proofOfHumanity.isRegistered(msg.sender),
            "Caller is not registered in PoH"
        );

        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            l2VerificationAddress,
            abi.encodeWithSignature(
                "addSubmission(address[] memory, string[] memory)",
                approvers,
                cids
            ),
            gasLimit // use whatever gas limit you want
        );
    }
}
