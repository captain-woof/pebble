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
    @param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * G
    @param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * G
    @return groupId New group's ID
     */
    function createGroup(
        address[] calldata _groupParticipantsOtherThanCreator,
        uint256 _initialPenultimateSharedKeyFromCreatorX,
        uint256 _initialPenultimateSharedKeyFromCreatorY
    ) external returns (uint256 groupId) {
        groupId = _createGroup(
            msg.sender,
            _groupParticipantsOtherThanCreator,
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
}
