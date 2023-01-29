// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleSignManager} from "src/PebbleSignManager/PebbleSignManager.sol";
import {GroupInternals} from "./GroupInternals.sol";
import {PebbleMath} from "src/Utils/Math.sol";

contract PebbleGroupManager is PebbleSignManager, GroupInternals {
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
}
