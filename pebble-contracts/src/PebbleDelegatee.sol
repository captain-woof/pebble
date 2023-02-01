// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {Pebble} from "src/Pebble.sol";

contract PebbleDelegatee {
    // DATA
    Pebble public pebbleProxy;
    mapping(address => uint256) public addressToFundsMapping;
    uint256 delegateFeesBasis;

    // MODIFIERS

    /**
    @dev Checks to see if caller is role admin of Delegatee role in Pebble proxy contract
     */
    modifier onlyPebbleDelegateeAdmins() {
        require(
            pebbleProxy.hasRole(
                pebbleProxy.getRoleAdmin(pebbleProxy.PEBBLE_DELEGATEE_ROLE()),
                msg.sender
            ),
            "PEBBLE DELEGATEE: NOT AN ADMIN"
        );
        _;
    }

    /**
    @dev Augments function with delegatee gas spent calculation + compensation
    @param _delegator Delegator on who's behalf delegatee is executing transaction
     */
    modifier delegateFor(address _delegator) {
        // Store gas units sent
        uint256 gasUnitsReceived = gasleft();

        // Perform actual function
        _;

        // Calculate gas spent
        uint256 gasSpent;
        assembly {
            gasSpent := mul(sub(gasUnitsReceived, gas()), gasprice())
        }

        // Move fund from delegator to delegatee to compensate + reward delegatee
        _moveFundsFromDelegatorToDelegatee(_delegator, msg.sender, gasSpent);
    }

    // FUNCTIONS

    /**
    @dev Constructor
    @param _delegateFeesBasis Delegate fees (in basis) to use
     */
    constructor(uint256 _delegateFeesBasis) {
        pebbleProxy = Pebble(msg.sender);
        delegateFeesBasis = _delegateFeesBasis;
    }

    /**
    @dev Sets delegate fees (basis)
    @param _delegateFeesBasisNew New delegate fees (basis) to set
     */
    function setDelegateFeesBasis(uint16 _delegateFeesBasisNew)
        external
        onlyPebbleDelegateeAdmins
    {
        delegateFeesBasis = _delegateFeesBasisNew;
    }

    /**
    @dev Adds funds sent by caller
     */
    function addFunds() external payable {
        _addFunds(msg.sender, msg.value);
    }

    /**
    @dev Withdraws all funds available for caller
     */
    function withdrawFunds() external {
        _withdrawFunds(msg.sender);
    }

    /**
    @dev Withdraws specified funds available for caller
    @param _value Deposited value to withdraw
     */
    function withdrawFunds(uint256 _value) external {
        _withdrawFunds(msg.sender, _value);
    }

    /**
    @dev If funds are directly sent, add them against caller
     */
    fallback() external payable {
        _addFunds(msg.sender, msg.value);
    }

    /**
    @dev If funds are directly sent, add them against caller
     */
    receive() external payable {
        _addFunds(msg.sender, msg.value);
    }

    /**
    @dev Creates a new group on behalf of delegator, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
    @param _groupCreator Address of the group creator (Delegator in this case)
    @param _groupParticipantsOtherThanCreator Array of group participants other than group creator
    @param _initialPenultimateSharedKeyForCreatorX X coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyForCreatorY Y coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @param _groupCreatorDelegatorNonce Group creator's delegator nonce
    @param _signatureFromDelegator Signature from delegator against which to confirm input params against
    @return groupId New group's ID
     */
    function createGroupForDelegator(
        address _groupCreator,
        address[] calldata _groupParticipantsOtherThanCreator,
        uint256 _initialPenultimateSharedKeyForCreatorX,
        uint256 _initialPenultimateSharedKeyForCreatorY,
        uint256 _initialPenultimateSharedKeyFromCreatorX,
        uint256 _initialPenultimateSharedKeyFromCreatorY,
        uint256 _groupCreatorDelegatorNonce,
        bytes calldata _signatureFromDelegator
    ) external delegateFor(_groupCreator) returns (uint256 groupId) {
        return
            pebbleProxy.createGroupForDelegator(
                _groupCreator,
                _groupParticipantsOtherThanCreator,
                _initialPenultimateSharedKeyForCreatorX,
                _initialPenultimateSharedKeyForCreatorY,
                _initialPenultimateSharedKeyFromCreatorX,
                _initialPenultimateSharedKeyFromCreatorY,
                _groupCreatorDelegatorNonce,
                _signatureFromDelegator
            );
    }

    /**
    @dev Creates a new group on behalf of delegator, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
    @param _groupCreator Address of the group creator (Delegator in this case)
    @param _groupParticipantsOtherThanCreator Array of group participants other than group creator
    @param _initialPenultimateSharedKeyForCreatorX X coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyForCreatorY Y coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @param _groupCreatorDelegatorNonce Group creator's delegator nonce
    @param _signatureFromDelegator_v v component of signature from delegator against which to confirm input params against
    @param _signatureFromDelegator_r v component of signature from delegator against which to confirm input params against
    @param _signatureFromDelegator_s v component of signature from delegator against which to confirm input params against
    @return groupId New group's ID
     */
    function createGroupForDelegator(
        address _groupCreator,
        address[] calldata _groupParticipantsOtherThanCreator,
        uint256 _initialPenultimateSharedKeyForCreatorX,
        uint256 _initialPenultimateSharedKeyForCreatorY,
        uint256 _initialPenultimateSharedKeyFromCreatorX,
        uint256 _initialPenultimateSharedKeyFromCreatorY,
        uint256 _groupCreatorDelegatorNonce,
        uint8 _signatureFromDelegator_v,
        bytes32 _signatureFromDelegator_r,
        bytes32 _signatureFromDelegator_s
    ) external delegateFor(_groupCreator) returns (uint256 groupId) {
        return
            pebbleProxy.createGroupForDelegator(
                _groupCreator,
                _groupParticipantsOtherThanCreator,
                _initialPenultimateSharedKeyForCreatorX,
                _initialPenultimateSharedKeyForCreatorY,
                _initialPenultimateSharedKeyFromCreatorX,
                _initialPenultimateSharedKeyFromCreatorY,
                _groupCreatorDelegatorNonce,
                _signatureFromDelegator_v,
                _signatureFromDelegator_r,
                _signatureFromDelegator_s
            );
    }

    /**
    @dev Accepts invititation to a group
    @param _groupId Group id of the group to accept invite for
    @param _groupParticipant Group participant who wants to accept group invite
    @param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
    @param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
    @param _groupParticipantDelegatorNonce Group participant's delegator nonce
    @param _signatureFromGroupParticipant Signature from participant against which to confirm input params against
    */
    function acceptGroupInviteForDelegator(
        uint256 _groupId,
        address _groupParticipant,
        address[] calldata _penultimateKeysFor,
        uint256[] calldata _penultimateKeysXUpdated,
        uint256[] calldata _penultimateKeysYUpdated,
        uint256 _timestampForWhichUpdatedKeysAreMeant,
        uint256 _groupParticipantDelegatorNonce,
        bytes calldata _signatureFromGroupParticipant
    ) external delegateFor(_groupParticipant) {
        pebbleProxy.acceptGroupInviteForDelegator(
            _groupId,
            _groupParticipant,
            _penultimateKeysFor,
            _penultimateKeysXUpdated,
            _penultimateKeysYUpdated,
            _timestampForWhichUpdatedKeysAreMeant,
            _groupParticipantDelegatorNonce,
            _signatureFromGroupParticipant
        );
    }

    /**
    @dev Accepts invititation to a group
    @param _groupId Group id of the group to accept invite for
    @param _groupParticipant Group participant who wants to accept group invite
    @param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
    @param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
    @param _groupParticipantDelegatorNonce Group participant's delegator nonce
    @param _signatureFromGroupParticipant_v v component of signature from participant against which to confirm input params against
    @param _signatureFromGroupParticipant_r r component of signature from participant against which to confirm input params against
    @param _signatureFromGroupParticipant_s s component of signature from participant against which to confirm input params against
    */
    function acceptGroupInviteForDelegator(
        uint256 _groupId,
        address _groupParticipant,
        address[] calldata _penultimateKeysFor,
        uint256[] calldata _penultimateKeysXUpdated,
        uint256[] calldata _penultimateKeysYUpdated,
        uint256 _timestampForWhichUpdatedKeysAreMeant,
        uint256 _groupParticipantDelegatorNonce,
        uint8 _signatureFromGroupParticipant_v,
        bytes32 _signatureFromGroupParticipant_r,
        bytes32 _signatureFromGroupParticipant_s
    ) external delegateFor(_groupParticipant) {
        pebbleProxy.acceptGroupInviteForDelegator(
            _groupId,
            _groupParticipant,
            _penultimateKeysFor,
            _penultimateKeysXUpdated,
            _penultimateKeysYUpdated,
            _timestampForWhichUpdatedKeysAreMeant,
            _groupParticipantDelegatorNonce,
            _signatureFromGroupParticipant_v,
            _signatureFromGroupParticipant_r,
            _signatureFromGroupParticipant_s
        );
    }

    /**
    @dev Sends a message from Sender in a group
    @param _groupId Group id of the group to send message in
    @param _sender Sender who wants to send message
    @param _encryptedMessage Encrypted message to send (MUST BE ENCRYPTED BY SHARED KEY, NOT PENULTIMATE SHARED KEY; SHARED KEY = SENDER PRIVATE KEY * SENDER PENULTIMATE SHARED KEY; THIS MUST BE CALCULATED LOCALLY)
    @param _senderDelegatorNonce Sender's delegator nonce
    @param _signatureFromSender Signature from sender against which to confirm input params against
     */
    function sendMessageInGroupForDelegator(
        uint256 _groupId,
        address _sender,
        bytes calldata _encryptedMessage,
        uint256 _senderDelegatorNonce,
        bytes calldata _signatureFromSender
    ) external delegateFor(_sender) {
        pebbleProxy.sendMessageInGroupForDelegator(
            _groupId,
            _sender,
            _encryptedMessage,
            _senderDelegatorNonce,
            _signatureFromSender
        );
    }

    /**
    @dev Sends a message from Sender in a group
    @param _groupId Group id of the group to send message in
    @param _sender Sender who wants to send message
    @param _encryptedMessage Encrypted message to send (MUST BE ENCRYPTED BY SHARED KEY, NOT PENULTIMATE SHARED KEY; SHARED KEY = SENDER PRIVATE KEY * SENDER PENULTIMATE SHARED KEY; THIS MUST BE CALCULATED LOCALLY)
    @param _senderDelegatorNonce Sender's delegator nonce
    @param _signatureFromSender_v v component of signature from sender against which to confirm input params against
    @param _signatureFromSender_r r component of signature from sender against which to confirm input params against
    @param _signatureFromSender_s s component of signature from sender against which to confirm input params against
     */
    function sendMessageInGroupForDelegator(
        uint256 _groupId,
        address _sender,
        bytes calldata _encryptedMessage,
        uint256 _senderDelegatorNonce,
        uint8 _signatureFromSender_v,
        bytes32 _signatureFromSender_r,
        bytes32 _signatureFromSender_s
    ) external delegateFor(_sender) {
        pebbleProxy.sendMessageInGroupForDelegator(
            _groupId,
            _sender,
            _encryptedMessage,
            _senderDelegatorNonce,
            _signatureFromSender_v,
            _signatureFromSender_r,
            _signatureFromSender_s
        );
    }

    // INTERNALS
    /**
    @dev Adds funds sent by an address
    @param _depositor Address of depositor
    @param _value Deposited value
     */
    function _addFunds(address _depositor, uint256 _value) internal {
        addressToFundsMapping[_depositor] += _value;
    }

    /**
    @dev Withdraws all funds available for an address
    @param _withdrawer Address of withdrawer
     */
    function _withdrawFunds(address _withdrawer) internal {
        uint256 fundsToWithdraw = addressToFundsMapping[_withdrawer];
        require(
            fundsToWithdraw != 0,
            "PEBBLE DELEGATEE: DEPOSITOR HAS NO FUNDS"
        );
        addressToFundsMapping[_withdrawer] = 0;
        (bool success, ) = _withdrawer.call{value: fundsToWithdraw}("");
        require(success, "PEBBLE DELEGATEE: WITHDRAW FAILED");
    }

    /**
    @dev Withdraws specified funds available for an address
    @param _withdrawer Address of withdrawer
    @param _value Deposited value to withdraw
     */
    function _withdrawFunds(address _withdrawer, uint256 _value) internal {
        require(
            _value != 0,
            "PEBBLE DELEGATEE: VALUE MUST BE GREATER THAN ZERO"
        );
        addressToFundsMapping[_withdrawer] -= _value;
        (bool success, ) = _withdrawer.call{value: _value}("");
        require(success, "PEBBLE DELEGATEE: WITHDRAW FAILED");
    }

    /**
    @dev Moves funds from delegator to delegatee; to be used after delegatee has finished delegation task
    @dev This takes delegate fees into account
    @param _delegator Address of delegator
    @param _delegatee Address of delegatee
    @param _valueToMove Value of deposit to move from delegator to delegatee (exclusive of delegator fees)
     */
    function _moveFundsFromDelegatorToDelegatee(
        address _delegator,
        address _delegatee,
        uint256 _valueToMove
    ) internal {
        uint256 valueToMoveWithFees = _valueToMove +
            ((_valueToMove * delegateFeesBasis) / 10000);
        addressToFundsMapping[_delegator] -= valueToMoveWithFees;
        addressToFundsMapping[_delegatee] += valueToMoveWithFees;
    }
}
