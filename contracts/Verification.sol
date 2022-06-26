// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

enum Status {
    NULL,
    PENDING,
    REJECTED,
    VERIFIED
}

struct Submission {
    Status status; // The current status of the submission.
    uint64 verificationDate; // The time when the submission was accepted to the list.
    uint64 index; // Index of a submission.
}

// struct Verifier {
//     address addr;
//     string publicKey;
// }

contract Verification is AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant VERIFIER = keccak256("VERIFIER");
    bytes32 public constant VERIFIERS_ADMIN = keccak256("VERIFIERS_ADMIN");

    Counters.Counter private _submissionCounter;

    // Address that has been granted the role of verifier.
    // Could be revoked and they still would be here.
    address[] private _verifiers;

    mapping(address => Submission) private _submissions;

    // submitterAddress => verifierAddress => IPFS CID
    mapping(address => mapping(address => string)) private _cids;

    event AddSubmission(address submitter, uint256 index, uint256 date);
    event Verified(
        address submitter,
        uint256 index,
        uint256 date,
        address verifier
    );
    event Rejected(
        address submitter,
        uint256 index,
        uint256 date,
        address verifier
    );

    constructor(address[] memory _initialVerifiers, address _admin) {
        _grantRole(VERIFIERS_ADMIN, _admin);
        _setRoleAdmin(VERIFIER, VERIFIERS_ADMIN);

        _verifiers = _initialVerifiers;

        for (uint256 i = 0; i < _initialVerifiers.length; i++) {
            _grantRole(VERIFIER, _initialVerifiers[i]);
        }
    }

    function addVerifier(address newVerifier) public onlyRole(VERIFIERS_ADMIN) {
        _verifiers.push(newVerifier);
        _grantRole(VERIFIER, newVerifier);
    }

    function addSubmission(address[] memory verifiers, string[] memory cids)
        public
    {
        // already checked worldcoin
        // should be called only by worldcoin registry?

        require(
            verifiers.length == cids.length,
            "Not same amount of verifiers and cids"
        );

        for (uint256 i = 0; i < verifiers.length; i++) {
            address verifier = verifiers[i];
            if (hasRole(VERIFIER, verifier))
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

    function verify(address submitter, string memory proof)
        public
        onlyRole(VERIFIER)
    {
        Submission storage _submission = _checkedPendingSubmission(submitter);

        _submission.status = Status.VERIFIED;
        _submission.verificationDate = uint64(block.timestamp);

        // do sth with the proof

        // mint nft

        emit Verified(
            submitter,
            _submission.index,
            block.timestamp,
            msg.sender
        );
    }

    function reject(address submitter) public onlyRole(VERIFIER) {
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
        onlyRole(VERIFIER)
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
        for (uint256 i = 0; i < _verifiers.length; i++) {
            if (hasRole(VERIFIER, _verifiers[i])) amount++;
        }
    }

    function activeVerifiers() public view returns (address[] memory) {
        uint256 length = activeVerifiersAmount();

        address[] memory addrs = new address[](length);

        uint256 j;

        for (uint256 i = 0; i < _verifiers.length; i++) {
            if (hasRole(VERIFIER, _verifiers[i])) {
                addrs[j] = _verifiers[i];
                j++;
            }
        }

        return addrs;
    }
}
