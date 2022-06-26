// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IWorldID.sol";
import "./libraries/ByteHasher.sol";

contract WorldIDRegistry {
    using ByteHasher for bytes;

    /// @dev The WorldID instance that will be used for managing groups and verifying proofs
    IWorldID internal immutable worldId;

    /// @dev The ID of the Semaphore group "World ID" (always 1)
    uint256 internal immutable groupId = 1;

    /// @notice Thrown when trying to update the airdrop amount without being the manager
    error Unauthorized();

    /// @notice Thrown when attempting to reuse a nullifier
    error InvalidNullifier();

    /// @notice Thrown when attempting to associate an address again
    error AlreadyAssociated();

    /// @dev Maps from nullitiferHash to address. Used to prevent double-signaling
    mapping(uint256 => address) internal _registry;

    /// @dev Reverse lookup of _registry
    mapping(address => uint256) internal _owners;

    /// @notice Deploys a WorldIDAirdrop instance
    /// @param _worldId The WorldID instance that will manage groups and verify proofs
    /// @dev worldId is take from `https://developer.worldcoin.org/api/v1/contracts`
    constructor(IWorldID _worldId) {
        worldId = _worldId;
    }

    function register(
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // Prevent double-signaling
        if (_registry[nullifierHash] != address(0)) revert InvalidNullifier();

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

        // Assign nullfierHash to owner (and vice versa)
        _registry[nullifierHash] = msg.sender;
        _owners[msg.sender] = nullifierHash;
    }

    function isAddressAssociated(address owner) public view returns (bool) {
        return _owners[owner] != 0;
    }
}
