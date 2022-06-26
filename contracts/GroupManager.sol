// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import "@semaphore-protocol/contracts/base/SemaphoreCore.sol";
import "@semaphore-protocol/contracts/base/SemaphoreGroups.sol";

/// @dev Modified custom contract of Semaphore
/// @dev From https://github.com/semaphore-protocol/semaphore/blob/main/contracts/Semaphore.sol
contract GroupManager is ISemaphore, SemaphoreCore, SemaphoreGroups {
    /// @dev Gets a tree depth and returns its verifier address.
    mapping(uint8 => IVerifier) public verifiers;

    /// @dev Gets a group id and returns the group admin address.
    mapping(uint256 => address) public groupAdmins;

    /// @dev Checks if the group admin is the transaction sender.
    /// @param groupId: Id of the group.
    modifier onlyGroupAdmin(uint256 groupId) {
        require(groupAdmins[groupId] == _msgSender(), "Semaphore: caller is not the group admin");
        _;
    }

    /// @dev Checks if there is a verifier for the given tree depth.
    /// @param depth: Depth of the tree.
    modifier onlySupportedDepth(uint8 depth) {
        require(address(verifiers[depth]) != address(0), "Semaphore: tree depth is not supported");
        _;
    }

    /// @dev Initializes the Semaphore verifiers used to verify the user's ZK proofs.
    /// @param _verifiers: List of Semaphore verifiers (address and related Merkle tree depth).
    constructor(Verifier[] memory _verifiers) {
        for (uint8 i = 0; i < _verifiers.length; i++) {
            verifiers[_verifiers[i].merkleTreeDepth] = IVerifier(_verifiers[i].contractAddress);
        }
    }
    
    /// @dev Creates a new group. Only the admin will be able to add or remove members.
    /// @dev Common (default) parameters: treeDepth = 20, zeroValue = BigInt(0).
    /// @param groupId: Id of the group.
    /// @param depth: Depth of the tree.
    /// @param zeroValue: Zero value of the tree.
    /// @param admin: Admin of the group.
    function createGroup(
        uint256 groupId,
        uint8 depth,
        uint256 zeroValue,
        address admin
    ) external override onlySupportedDepth(depth) {
        _createGroup(groupId, depth, zeroValue);

        groupAdmins[groupId] = admin;

        emit GroupAdminUpdated(groupId, address(0), admin);
    }

    /// @dev See {ISemaphore-updateGroupAdmin}.
    function updateGroupAdmin(uint256 groupId, address newAdmin) external override onlyGroupAdmin(groupId) {
        groupAdmins[groupId] = newAdmin;

        emit GroupAdminUpdated(groupId, _msgSender(), newAdmin);
    }

    /// @dev Adds a new member to an existing group.
    /// @param groupId: Id of the group.
    /// @param identityCommitment: New identity commitment.
    function addMember(
        uint256 groupId,
        uint256 identityCommitment
    ) external override onlyGroupAdmin(groupId) {
        _addMember(groupId, identityCommitment);
    }

    /// @dev Removes a member from an existing group. A proof of membership is
    /// needed to check if the node to be removed is part of the tree.
    /// @param groupId: Id of the group.
    /// @param identityCommitment: Identity commitment to be deleted.
    /// @param proofSiblings: Array of the sibling nodes of the proof of membership.
    /// @param proofPathIndices: Path of the proof of membership.
    function removeMember(
        uint256 groupId,
        uint256 identityCommitment,
        uint256[] calldata proofSiblings,
        uint8[] calldata proofPathIndices
    ) external override onlyGroupAdmin(groupId) {
        _removeMember(groupId, identityCommitment, proofSiblings, proofPathIndices);
    }

    /// @dev See {ISemaphore-verifyProof}.
    function verifyProof(
        uint256 groupId,
        bytes32 signal,
        uint256 nullifierHash,
        uint256 externalNullifier,
        uint256[8] calldata proof
    ) external override {
        uint256 root = getRoot(groupId);
        uint8 depth = getDepth(groupId);

        require(depth != 0, "Semaphore: group does not exist");

        IVerifier verifier = verifiers[depth];

        _verifyProof(signal, root, nullifierHash, externalNullifier, proof, verifier);

        _saveNullifierHash(nullifierHash);

        emit ProofVerified(groupId, signal);
    }
}