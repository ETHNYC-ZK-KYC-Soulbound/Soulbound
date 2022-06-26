// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MainVerification.sol";

interface IProofOfHumanity {
    function isRegistered(address human) external view returns (bool);
}
