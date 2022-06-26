// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IWorldID } from "@worldcoin/world-id-contracts/interfaces/IWorldID.sol";
import { ByteHasher } from "@worldcoin/world-id-contracts/libraries/ByteHasher.sol";

contract WorldIDRegistry {
    using ByteHasher for bytes;

    /// @dev The WorldID instance that will be used for managing groups and verifying proofs
    IWorldID internal immutable worldId;

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
    /// @param worldId The WorldID instance that will manage groups and verify proofs
    /// @param groupId The ID of the Semaphore group World ID is using (`1`)
    constructor(
        IWorldID worldId
    ) {
        worldId = _worldId;
        groupId = _groupId;
    }

    function register(
        address owner,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // Prevent double-signaling
        if (_registry[nullifierHash]) revert InvalidNullifier();

        // Address can only be associated once
        if (_owners[owner] != address(0)) revert AlreadyAssociated();

        worldId.verifyProof(
            root,
            groupId,
            abi.encodePacked(owner).hashToField(),
            nullifierHash,
            abi.encodePacked(address(this)).hashToField(),
            proof
        );

        // Assign nullfierHash to owner (and vice versa)
        _registry[nullifierHash] = owner;
        _owners[owner] = nullifierHash;
    }

    function isAddressAssociated(address owner) public view returns (bool) {
        return _owners[owner] != address(0);
    }
}
