// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ProofToken.sol";
// import "./GroupManager.sol";

enum Status {
    NULL,
    PENDING,
    REJECTED,
    APPROVED
}

struct Submission {
    Status status; // The current status of the submission.
    uint64 verificationDate; // The time when the submission was accepted to the list.
    uint64 index; // Index of a submission.
}

abstract contract MainVerification is Ownable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant APPROVER = keccak256("APPROVER");
    bytes32 public constant APPROVERS_ADMIN = keccak256("APPROVERS_ADMIN");

    IProofToken private _proofToken;
    address public groupManager;

    Counters.Counter private _submissionCounter;

    // Address that has been granted the role of verifier.
    // Could be revoked and they still would be here.
    address[] private _approvers;

    mapping(address => Submission) private _submissions;

    // submitterAddress => verifierAddress => IPFS CID
    mapping(address => mapping(address => string)) private _cids;

    event AddSubmission(address submitter, uint256 index, uint256 date);
    event Approved(
        address submitter,
        uint256 index,
        uint256 date,
        address approver
    );
    event Rejected(
        address submitter,
        uint256 index,
        uint256 date,
        address approver
    );

    constructor(
        address[] memory _initialApprovers,
        address _admin,
        string memory _tokenURI
    ) {
        _grantRole(APPROVERS_ADMIN, _admin);
        _setRoleAdmin(APPROVER, APPROVERS_ADMIN);

        _approvers = _initialApprovers;

        for (uint256 i = 0; i < _initialApprovers.length; i++) {
            _grantRole(APPROVER, _initialApprovers[i]);
        }

        ProofToken _nftContract = new ProofToken(_tokenURI);
        _proofToken = IProofToken(_nftContract);
    }

    function addApprover(address newApprover) public onlyRole(APPROVERS_ADMIN) {
        _approvers.push(newApprover);
        _grantRole(APPROVER, newApprover);
    }

    function _addSubmission(address[] memory approvers, string[] memory cids)
        internal
    {
        require(
            approvers.length == cids.length,
            "Not same amount of approvers and cids"
        );

        for (uint256 i = 0; i < approvers.length; i++) {
            address verifier = approvers[i];
            if (hasRole(APPROVER, verifier))
                _cids[msg.sender][verifier] = cids[i];
        }

        _submissionCounter.increment();

        uint64 index = uint64(_submissionCounter.current());

        _submissions[msg.sender] = Submission(Status.PENDING, 0, index);

        emit AddSubmission(msg.sender, index, block.timestamp);
    }

    function _checkedPendingSubmission(address _submitter)
        private
        view
        returns (Submission storage)
    {
        Submission storage _submission = _submissions[_submitter];
        require(
            _submission.status == Status.PENDING,
            "Submission has been already resolved or does not exist"
        );
        return _submission;
    }

    function approveAndBindProof(address submitter, string memory proof)
        public
        onlyRole(APPROVER)
    {
        Submission storage _submission = _checkedPendingSubmission(submitter);

        _submission.status = Status.APPROVED;
        _submission.verificationDate = uint64(block.timestamp);

        _proofToken.mint(submitter, proof);

        emit Approved(
            submitter,
            _submission.index,
            block.timestamp,
            msg.sender
        );
    }

    function reject(address submitter) public onlyRole(APPROVER) {
        Submission storage _submission = _checkedPendingSubmission(submitter);

        _submission.status = Status.REJECTED;

        emit Rejected(
            submitter,
            _submission.index,
            block.timestamp,
            msg.sender
        );
    }

    function getCID(address submitter)
        public
        view
        onlyRole(APPROVER)
        returns (string memory)
    {
        string memory cid = _cids[submitter][msg.sender];
        require(
            bytes(cid).length > 0,
            "No cid for this submitter and verifier"
        );
        return cid;
    }

    function activeVerifiersAmount() public view returns (uint256 amount) {
        for (uint256 i = 0; i < _approvers.length; i++) {
            if (hasRole(APPROVER, _approvers[i])) amount++;
        }
    }

    function activeVerifiers() public view returns (address[] memory) {
        uint256 length = activeVerifiersAmount();

        address[] memory addrs = new address[](length);

        uint256 j;

        for (uint256 i = 0; i < _approvers.length; i++) {
            if (hasRole(APPROVER, _approvers[i])) {
                addrs[j] = _approvers[i];
                j++;
            }
        }

        return addrs;
    }
}
