// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {GroupDataController} from "./Controllers/GroupDataController.sol";
import {GroupCreatorController} from "./Controllers/GroupCreatorController.sol";

contract PebbleGroupManager is GroupDataController, GroupCreatorController {
    /**
    @dev Initialization method
     */
    function __PebbleGroupManager_init_unchained() internal onlyInitializing {}

    /**
    @dev Creates a new group, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
    @param _groupCreator Address of the group creator
    @param _groupParticipantsOtherThanCreator Array of group participants other than group creator
    @param _updatedPenultimateSharedKeyFromCreator Initial value of penultimate shared key to use for all participants other than creator
    @return groupId New group's ID
     */
    function createGroup(
        address _groupCreator,
        address[] memory _groupParticipantsOtherThanCreator,
        uint256 _updatedPenultimateSharedKeyFromCreator
    ) external returns (uint256 groupId) {
        groupId = _createGroup(
            _groupCreator,
            _groupParticipantsOtherThanCreator,
            _updatedPenultimateSharedKeyFromCreator
        );
    }

    /**
    @dev Accepts invititation to a group
    @param _groupParticipant Group participant who wants to accept group invite
    @param _groupId Group id of the group to accept invite for
    @param _updatedPenultimateSharedKeyFromParticipant Updated value of penultimate shared key to use for all participants other than participant
    */
    function acceptGroupInvite(
        address _groupParticipant,
        uint256 _groupId,
        uint256 _updatedPenultimateSharedKeyFromParticipant
    ) external {
        _acceptGroupInvite(
            _groupParticipant,
            _groupId,
            _updatedPenultimateSharedKeyFromParticipant
        );
    }
}
