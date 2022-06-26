// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWorldID.sol";
import "../libraries/ByteHasher.sol";

contract WorldIDRegistry {
    using ByteHasher for bytes;

    /// @dev The WorldID instance that will be used for managing groups and verifying proofs
    IWorldID internal immutable _worldId;

    /// @dev The ID of the Semaphore group "World ID" (always 1)
    uint256 internal immutable _groupId = 1;

    /// @notice Thrown when trying to update the airdrop amount without being the manager
    error Unauthorized();

    /// @notice Thrown when attempting to reuse a nullifier
    error InvalidNullifier();

    /// @notice Thrown when attempting to associate an address again
    error AlreadyAssociated();

    /// @dev Maps from nullitiferHash to address. Used to prevent double-signaling
    mapping(uint256 => address) internal _hashToAddress;

    /// @dev Reverse lookup of _hashToAddress
    mapping(address => uint256) internal _addressToHash;

    /// @notice Deploys a WorldIDAirdrop instance
    /// @param _worldId_ The WorldID instance that will manage groups and verify proofs
    /// @dev worldId is take from `https://developer.worldcoin.org/api/v1/contracts`
    constructor(address _worldId_) {
        _worldId = IWorldID(_worldId_);
    }

    function _verify(
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) internal {
        address _hashOwner = _hashToAddress[nullifierHash];

        // Prevent double-signaling
        if (_hashOwner != address(0) && _hashOwner != msg.sender)
            revert InvalidNullifier();

        uint256 _callerHash = _addressToHash[msg.sender];

        // Address can only be associated once
        if (_callerHash != 0 && _callerHash != nullifierHash)
            revert AlreadyAssociated();

        _worldId.verifyProof(
            root,
            _groupId,
            abi.encodePacked(msg.sender).hashToField(),
            nullifierHash,
            abi.encodePacked(address(this)).hashToField(),
            proof
        );

        if (_callerHash == 0) {
            // Assign nullfierHash to owner (and vice versa)
            _hashToAddress[nullifierHash] = msg.sender;
            _addressToHash[msg.sender] = nullifierHash;
        }
    }

    function isAddressAssociated(address owner) public view returns (bool) {
        return _addressToHash[owner] != 0;
    }
}
