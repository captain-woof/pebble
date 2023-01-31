// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleRoleManager} from "src/PebbleRoleManager/PebbleRoleManager.sol";
import {PebbleSignManager} from "src/PebbleSignManager/PebbleSignManager.sol";
import {PebbleDelagateVerificationManager} from "src/PebbleDelagateVerificationManager/PebbleDelagateVerificationManager.sol";
import {GroupInternals} from "./GroupInternals.sol";
import {PebbleMath} from "src/Utils/Math.sol";
import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

contract PebbleGroupManager is
    PebbleRoleManager,
    PebbleSignManager,
    PebbleDelagateVerificationManager,
    GroupInternals
{
    // CONSTANTS
    bytes32 constant CREATE_GROUP_FOR_DELEGATOR_TYPEHASH =
        keccak256(
            "createGroupForDelegator(address _groupCreator,address[] _groupParticipantsOtherThanCreator,uint256 _initialPenultimateSharedKeyForCreatorX,uint256 _initialPenultimateSharedKeyForCreatorY,uint256 _initialPenultimateSharedKeyFromCreatorX,uint256 _initialPenultimateSharedKeyFromCreatorY,uint256 _groupCreatorDelegatorNonce)"
        );
    bytes32 constant ACCEPT_GROUP_INVITE_FOR_DELEGATOR_TYPEHASH =
        keccak256(
            "acceptGroupInviteForDelegator(uint256 _groupId,address _groupParticipant,address[] _penultimateKeysFor,uint256[] _penultimateKeysXUpdated,uint256[] _penultimateKeysYUpdated,uint256 _timestampForWhichUpdatedKeysAreMeant,uint256 _groupParticipantDelegatorNonce)"
        );
    bytes32 constant SEND_MESSAGE_IN_GROUP_FOR_DELEGATOR_TYPEHASH =
        keccak256(
            "uint256 _groupId,address _sender,bytes _encryptedMessage,uint256 _senderDelegatorNonce"
        );

    /**
    @dev Initialization method
     */
    function __PebbleGroupManager_init_unchained() internal onlyInitializing {}

    // Functions

    /**
    @dev Creates a new group, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
    @param _groupParticipantsOtherThanCreator Array of group participants other than group creator
    @param _initialPenultimateSharedKeyForCreatorX X coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyForCreatorY Y coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @return groupId New group's ID
     */
    function createGroup(
        address[] calldata _groupParticipantsOtherThanCreator,
        uint256 _initialPenultimateSharedKeyForCreatorX,
        uint256 _initialPenultimateSharedKeyForCreatorY,
        uint256 _initialPenultimateSharedKeyFromCreatorX,
        uint256 _initialPenultimateSharedKeyFromCreatorY
    ) external returns (uint256 groupId) {
        groupId = _createGroup(
            msg.sender,
            _groupParticipantsOtherThanCreator,
            PenultimateSharedKey(
                _initialPenultimateSharedKeyForCreatorX,
                _initialPenultimateSharedKeyForCreatorY
            ),
            PenultimateSharedKey(
                _initialPenultimateSharedKeyFromCreatorX,
                _initialPenultimateSharedKeyFromCreatorY
            )
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
    )
        external
        onlyPebbleDelegatee
        delegatorNonceCorrect(_groupCreator, _groupCreatorDelegatorNonce)
        returns (uint256 groupId)
    {
        // Verify signature
        bytes32 paramsDigest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    CREATE_GROUP_FOR_DELEGATOR_TYPEHASH,
                    _groupCreator,
                    keccak256(abi.encode(_groupParticipantsOtherThanCreator)),
                    keccak256(
                        abi.encode(_initialPenultimateSharedKeyForCreatorX)
                    ),
                    keccak256(
                        abi.encode(_initialPenultimateSharedKeyForCreatorY)
                    ),
                    keccak256(
                        abi.encode(_initialPenultimateSharedKeyFromCreatorX)
                    ),
                    keccak256(
                        abi.encode(_initialPenultimateSharedKeyFromCreatorY)
                    ),
                    _groupCreatorDelegatorNonce
                )
            )
        );
        require(
            _groupCreator ==
                ECDSAUpgradeable.recover(paramsDigest, _signatureFromDelegator),
            "PEBBLE: INCORRECT SIGNATURE"
        );

        // Create group
        groupId = _createGroup(
            _groupCreator,
            _groupParticipantsOtherThanCreator,
            PenultimateSharedKey(
                _initialPenultimateSharedKeyForCreatorX,
                _initialPenultimateSharedKeyForCreatorY
            ),
            PenultimateSharedKey(
                _initialPenultimateSharedKeyFromCreatorX,
                _initialPenultimateSharedKeyFromCreatorY
            )
        );
    }

    /**
    @dev Accepts invititation to a group
    @param _groupId Group id of the group to accept invite for
    @param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
    @param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
    */
    function acceptGroupInvite(
        uint256 _groupId,
        address[] calldata _penultimateKeysFor,
        uint256[] calldata _penultimateKeysXUpdated,
        uint256[] calldata _penultimateKeysYUpdated,
        uint256 _timestampForWhichUpdatedKeysAreMeant
    ) external {
        _acceptGroupInvite(
            _groupId,
            msg.sender,
            _penultimateKeysFor,
            _penultimateKeysXUpdated,
            _penultimateKeysYUpdated,
            _timestampForWhichUpdatedKeysAreMeant
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
    )
        external
        onlyPebbleDelegatee
        delegatorNonceCorrect(
            _groupParticipant,
            _groupParticipantDelegatorNonce
        )
    {
        // Verify signature
        bytes32 paramsDigest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    ACCEPT_GROUP_INVITE_FOR_DELEGATOR_TYPEHASH,
                    _groupId,
                    _groupParticipant,
                    abi.encode(_penultimateKeysFor),
                    abi.encode(_penultimateKeysXUpdated),
                    abi.encode(_penultimateKeysYUpdated),
                    _timestampForWhichUpdatedKeysAreMeant,
                    _groupParticipantDelegatorNonce
                )
            )
        );
        require(
            _groupParticipant ==
                ECDSAUpgradeable.recover(
                    paramsDigest,
                    _signatureFromGroupParticipant
                ),
            "PEBBLE: INCORRECT SIGNATURE"
        );

        // Accept invite
        _acceptGroupInvite(
            _groupId,
            _groupParticipant,
            _penultimateKeysFor,
            _penultimateKeysXUpdated,
            _penultimateKeysYUpdated,
            _timestampForWhichUpdatedKeysAreMeant
        );
    }

    /**
    @dev Searches through group and finds all other group participants (excluding the participant who's invoking this)
    @param _groupId Group id of the group
    @return otherParticipants Array of other group participants
     */
    function getOtherGroupParticipants(uint256 _groupId)
        external
        view
        returns (address[] memory otherParticipants)
    {
        otherParticipants = _getOtherGroupParticipants(_groupId, msg.sender);
    }

    /**
    @dev Gets timestamp when a group's penultimate shared keys were last updated
    @param _groupId Group id of the group
    @return timestamp Timestamp when a group's penultimate shared keys were last updated
     */
    function getGroupPenultimateSharedKeyLastUpdateTimestamp(uint256 _groupId)
        external
        view
        returns (uint256 timestamp)
    {
        timestamp = _getGroupPenultimateSharedKeyLastUpdateTimestamp(_groupId);
    }

    /**
    @dev Gets a participant's penultimate shared key for a group id
    @param _groupId Group id to use to fetch penultimate shared key
    @param _groupParticipant Group participant for whom to fetch the penultimate shared key
    @return penultimateSharedKeyX X coordinate of penultimate shared key of group participant; Participant 1 * Participant 2 ... * RANDOM * G
    @return penultimateSharedKeyY Y coordinate of penultimate shared key of group participant; Participant 1 * Participant 2 ... * RANDOM * G
     */
    function getParticipantGroupPenultimateSharedKey(
        uint256 _groupId,
        address _groupParticipant
    )
        external
        view
        returns (uint256 penultimateSharedKeyX, uint256 penultimateSharedKeyY)
    {
        PenultimateSharedKey
            memory penultimateSharedKey = _getParticipantGroupPenultimateSharedKey(
                _groupId,
                _groupParticipant
            );
        (penultimateSharedKeyX, penultimateSharedKeyY) = (
            penultimateSharedKey.penultimateSharedKeyX,
            penultimateSharedKey.penultimateSharedKeyY
        );
    }

    /**
    @dev Gets a participant's penultimate shared key for a group id
    @param _groupId Group id to use to fetch penultimate shared key
    @param _groupParticipants Array of group participants for whom to fetch the penultimate shared keys
    @return penultimateSharedKeysX Array of X coordinate of penultimate shared keys of group participants; Participant 1 * Participant 2 ... * RANDOM * G
    @return penultimateSharedKeysY Array of Y coordinate of penultimate shared keys of group participants; Participant 1 * Participant 2 ... * RANDOM * G
     */
    function getParticipantsGroupPenultimateSharedKey(
        uint256 _groupId,
        address[] memory _groupParticipants
    )
        external
        view
        returns (
            uint256[] memory penultimateSharedKeysX,
            uint256[] memory penultimateSharedKeysY
        )
    {
        uint256 groupParticipantsNum = _groupParticipants.length;
        (penultimateSharedKeysX, penultimateSharedKeysY) = (
            new uint256[](groupParticipantsNum),
            new uint256[](groupParticipantsNum)
        );
        PenultimateSharedKey memory penultimateSharedKey;
        for (uint256 i; i < groupParticipantsNum; ++i) {
            penultimateSharedKey = _getParticipantGroupPenultimateSharedKey(
                _groupId,
                _groupParticipants[i]
            );
            (penultimateSharedKeysX[i], penultimateSharedKeysY[i]) = (
                penultimateSharedKey.penultimateSharedKeyX,
                penultimateSharedKey.penultimateSharedKeyY
            );
        }
    }

    /**
    @dev Sends a message from Sender in a group
    @param _groupId Group id of the group to send message in
    @param _encryptedMessage Encrypted message to send (MUST BE ENCRYPTED BY SHARED KEY, NOT PENULTIMATE SHARED KEY; SHARED KEY = SENDER PRIVATE KEY * SENDER PENULTIMATE SHARED KEY; THIS MUST BE CALCULATED LOCALLY)
     */
    function sendMessageInGroup(
        uint256 _groupId,
        bytes calldata _encryptedMessage
    ) external {
        _sendMessageInGroup(_groupId, msg.sender, _encryptedMessage);
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
    )
        external
        onlyPebbleDelegatee
        delegatorNonceCorrect(_sender, _senderDelegatorNonce)
    {
        // Verify signature
        bytes32 paramsDigest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    SEND_MESSAGE_IN_GROUP_FOR_DELEGATOR_TYPEHASH,
                    _groupId,
                    _sender,
                    _encryptedMessage,
                    _senderDelegatorNonce
                )
            )
        );
        require(
            _sender ==
                ECDSAUpgradeable.recover(paramsDigest, _signatureFromSender),
            "PEBBLE: INCORRECT SIGNATURE"
        );

        // Send message
        _sendMessageInGroup(_groupId, _sender, _encryptedMessage);
    }
}
