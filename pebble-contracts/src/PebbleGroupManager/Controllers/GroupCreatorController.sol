// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleSignManager} from "src/PebbleSignManager/PebbleSignManager.sol";
import {GroupDataController} from "./GroupDataController.sol";

contract GroupCreatorController is PebbleSignManager, GroupDataController {
    // Functions

    /**
    @dev Creates a new group, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
    @param _groupCreator Address of the group creator
    @param _groupParticipantsOtherThanCreator Array of group participants other than group creator
    @param _updatedPenultimateSharedKeyFromCreator Initial value of penultimate shared key to use for all participants other than creator
    @return groupId New group's ID
     */
    function _createGroup(
        address _groupCreator,
        address[] memory _groupParticipantsOtherThanCreator,
        uint256 _updatedPenultimateSharedKeyFromCreator
    ) internal returns (uint256 groupId) {
        // Create new group object
        Group memory group = Group({
            creator: _groupCreator,
            participantsOtherThanCreator: _groupParticipantsOtherThanCreator
        });

        // Store group
        groupId = _getAndIncrementGroupNonce();
        _setupGroup(groupId, group);
        _addGroupIdToParticipantToGroupIdsMapping(_groupCreator, groupId);

        // Update penultimate shared keys
        uint256 groupParticipantsOtherThanCreatorNum = _groupParticipantsOtherThanCreator
                .length;
        for (uint256 i; i < groupParticipantsOtherThanCreatorNum; ++i) {
            _updateParticipantGroupPenultimateSharedKey(
                groupId,
                _groupParticipantsOtherThanCreator[i],
                _updatedPenultimateSharedKeyFromCreator
            );
        }
    }

    /**
    @dev Accepts invititation to a group
    @param _groupParticipant Group participant who wants to accept group invite
    @param _groupId Group id of the group to accept invite for
    @param _updatedPenultimateSharedKeyFromParticipant Updated value of penultimate shared key to use for all participants other than participant
    */
    function _acceptGroupInvite(
        address _groupParticipant,
        uint256 _groupId,
        uint256 _updatedPenultimateSharedKeyFromParticipant
    ) internal {
        // Check if participant can enter group
        require(
            _canParticipantAcceptGroupInvite(_groupParticipant, _groupId),
            "PEBBLE: NOT INVITED"
        );

        // Update participant to group id mapping
        _addGroupIdToParticipantToGroupIdsMapping(_groupParticipant, _groupId);

        // Update penultimate shared keys for creator and other participants
        Group memory group = _getGroupFromGroupId(_groupId);
        address[] memory participantsOtherThanCreator = group
            .participantsOtherThanCreator;
        uint256 participantsOtherThanCreatorNum = participantsOtherThanCreator
            .length;

        _updateParticipantGroupPenultimateSharedKey(
            _groupId,
            group.creator,
            _updatedPenultimateSharedKeyFromParticipant
        );
        for (uint256 i; i < participantsOtherThanCreatorNum; ++i) {
            if (participantsOtherThanCreator[i] != _groupParticipant) {
                _updateParticipantGroupPenultimateSharedKey(
                    _groupId,
                    participantsOtherThanCreator[i],
                    _updatedPenultimateSharedKeyFromParticipant
                );
            }
        }
    }
}
