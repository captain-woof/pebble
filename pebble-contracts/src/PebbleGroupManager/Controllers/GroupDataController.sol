// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleMath} from "src/Utils/Math.sol";

contract GroupDataController {
    // Structs
    struct Group {
        address creator;
        address[] participantsOtherThanCreator;
    }

    // Constants
    uint256 constant GROUP_NONCE_SLOT =
        uint256(keccak256("PEBBLE:GROUP_NONCE_SLOT"));
    uint256 constant GROUP_PARTICIPANT_TO_GROUP_NUMBERS_MAPPING_SLOT =
        uint256(
            keccak256("PEBBLE:GROUP_PARTICIPANT_TO_GROUP_NUMBERS_MAPPING_SLOT")
        );
    uint256 constant GROUP_NUMBER_TO_GROUP_MAPPING_SLOT =
        uint256(keccak256("PEBBLE:GROUP_NUMBER_TO_GROUP_MAPPING_SLOT"));
    uint256 constant GROUP_ID_TO_GROUP_PARTICIPANT_TO_PENULTIMATE_SHARED_KEY_MAPPING_SLOT =
        uint256(
            keccak256(
                "PEBBLE:GROUP_ID_TO_GROUP_PARTICIPANT_TO_PENULTIMATE_SHARED_KEY_MAPPING_SLOT"
            )
        );

    // Data
    mapping(address => uint256[]) private __groupParticipantToGroupIdsMapping; // Maps a group participant to array of group ids; DON'T USE DIRECTLY; USE SLOT HELPER
    mapping(uint256 => Group) private __groupIdToGroupMapping; // Maps a group id to group data; DON'T USE DIRECTLY; USE SLOT HELPER
    mapping(uint256 => mapping(address => uint256))
        private __groupIdToGroupParticipantToPenultimateSharedKeyMapping; // Maps a group id to participant to penultimate shared key; DON'T USE DIRECTLY; USE SLOT HELPER

    // Functions

    /**
    @dev Gets group nonce mapping at correct slot
    @return groupNonce Current group nonce
     */
    function _getGroupNonce() private view returns (uint256 groupNonce) {
        uint256 slotNum = GROUP_NONCE_SLOT;

        assembly {
            groupNonce := sload(slotNum)
        }
    }

    /**
    @dev Increments previous group nonce and then returns it, all at correct slot
    @return groupNonce Group nonce BEFORE being incremented. Use this returned value directly.
     */
    function _getAndIncrementGroupNonce()
        internal
        returns (uint256 groupNonce)
    {
        uint256 slotNum = GROUP_NONCE_SLOT;

        assembly {
            groupNonce := sload(slotNum)
            sstore(slotNum, add(groupNonce, 1))
        }
    }

    /**
    @dev Gets group from group id
    @param _groupId Group id to query with
    @return group Group corresponding the the group id
     */
    function _getGroupFromGroupId(uint256 _groupId)
        internal
        view
        returns (Group memory)
    {
        return _getGroupIdToGroupMapping()[_groupId];
    }

    /**
    @dev Get groups a participant/creator is present in
    @dev For group creators, this would return both groups they created + groups they are participants in
    @param _groupParticipant Address of participant
    @param _pageNo Page no (zero indexed) of data to fetch
    @param _pageSize Page size to use for data
    @return participantGroups Array of groups a participant is in
     */
    function _getCreatorOrParticipantGroups(
        address _groupParticipant,
        uint256 _pageNo,
        uint256 _pageSize
    ) internal view returns (Group[] memory participantGroups) {
        uint256[]
            memory groupsParticipantIsIn = _getGroupParticipantToGroupIdsMapping()[
                _groupParticipant
            ];
        mapping(uint256 => Group)
            storage groupIdToGroupMapping = _getGroupIdToGroupMapping();

        uint256 startIndex = _pageNo * _pageSize;
        uint256 endIndexOffByOne = PebbleMath.min(
            startIndex + _pageSize,
            groupsParticipantIsIn.length
        );

        for (uint256 i = startIndex; i < endIndexOffByOne; ++i) {
            participantGroups[i - startIndex] = groupIdToGroupMapping[
                groupsParticipantIsIn[i]
            ];
        }
    }

    /**
    @dev Get rooms a participant is present in
    @param _groupId Group id to setup new Group at
    @param _groupData Corresponding group data to set
     */
    function _setupGroup(uint256 _groupId, Group memory _groupData) internal {
        _getGroupIdToGroupMapping()[_groupId] = _groupData;
    }

    /**
    @dev Adds a new group id to the participant to Groups mapping
    @param _groupParticipant Address of participant
    @param _groupId Group id to push
     */
    function _addGroupIdToParticipantToGroupIdsMapping(
        address _groupParticipant,
        uint256 _groupId
    ) internal {
        uint256[]
            storage groupsParticipantIsIn = _getGroupParticipantToGroupIdsMapping()[
                _groupParticipant
            ];
        groupsParticipantIsIn.push(_groupId);
    }

    /**
    @dev Gets a participant's penultimate shared key for a group id
    @param _groupId Group id to use to fetch penultimate shared key
    @param _groupParticipant Group participant for whom to fetch the penultimate shared key
    @return penultimateSharedKey Penultimate shared key of group participant
     */
    function _getParticipantGroupPenultimateSharedKey(
        uint256 _groupId,
        address _groupParticipant
    ) internal view returns (uint256 penultimateSharedKey) {
        penultimateSharedKey = _getGroupIdToGroupParticipantToPenultimateSharedKeyMapping()[
            _groupId
        ][_groupParticipant];
    }

    /**
    @dev Updates a participant's penultimate shared key for a group id
    @param _groupId Group id to use to update key in
    @param _groupParticipant Group participant for whom to set the penultimate shared key
    @param _newParticipantGroupPenultimateSharedKey Updated penultimate shared key to set for participant
     */
    function _updateParticipantGroupPenultimateSharedKey(
        uint256 _groupId,
        address _groupParticipant,
        uint256 _newParticipantGroupPenultimateSharedKey
    ) internal {
        _getGroupIdToGroupParticipantToPenultimateSharedKeyMapping()[_groupId][
            _groupParticipant
        ] = _newParticipantGroupPenultimateSharedKey;
    }

    /**
    @dev Gets number of rooms a participant is present in
    @param _groupParticipant Address of participant
    @return groupsInNum Number of groups a participant is in
     */
    function _getParticipantGroupsNum(address _groupParticipant)
        internal
        view
        returns (uint256)
    {
        return
            _getGroupParticipantToGroupIdsMapping()[_groupParticipant].length;
    }

    /**
    @dev Checks to see if a participant can accept invite to a group
    @param _groupParticipant Address of participant to check
    @param _groupId Group Id of the group the participant wants to join
     */
    function _canParticipantAcceptGroupInvite(
        address _groupParticipant,
        uint256 _groupId
    ) internal view returns (bool) {
        // Get group
        address[]
            memory participantsOtherThanCreator = _getGroupIdToGroupMapping()[
                _groupId
            ].participantsOtherThanCreator;

        // Check to see if participant is present in Group
        uint256 participantsOtherThanCreatorNum = participantsOtherThanCreator
            .length;
        for (uint256 i; i < participantsOtherThanCreatorNum; ++i) {
            if (participantsOtherThanCreator[i] == _groupParticipant) {
                return true;
            }
        }

        return false;
    }

    ////////////////
    // SLOT HELPERS
    ////////////////

    /**
    @dev Gets participant to group ids array mapping at correct slot
     */
    function _getGroupParticipantToGroupIdsMapping()
        private
        view
        returns (
            mapping(address => uint256[])
                storage groupParticipantToGroupIdsMapping
        )
    {
        groupParticipantToGroupIdsMapping = __groupParticipantToGroupIdsMapping;

        uint256 slotNum = GROUP_PARTICIPANT_TO_GROUP_NUMBERS_MAPPING_SLOT;

        assembly {
            groupParticipantToGroupIdsMapping.slot := slotNum
        }
    }

    /**
    @dev Gets group id to Group mapping at correct slot
     */
    function _getGroupIdToGroupMapping()
        private
        view
        returns (mapping(uint256 => Group) storage groupIdToGroupMapping)
    {
        groupIdToGroupMapping = __groupIdToGroupMapping;

        uint256 slotNum = GROUP_NUMBER_TO_GROUP_MAPPING_SLOT;

        assembly {
            groupIdToGroupMapping.slot := slotNum
        }
    }

    /**
    @dev Gets a mapping from group ids to participants to their penultimate shared key at correct slot
     */
    function _getGroupIdToGroupParticipantToPenultimateSharedKeyMapping()
        private
        view
        returns (
            mapping(uint256 => mapping(address => uint256))
                storage groupIdToGroupParticipantToPenultimateSharedKeyMapping
        )
    {
        groupIdToGroupParticipantToPenultimateSharedKeyMapping = __groupIdToGroupParticipantToPenultimateSharedKeyMapping;

        uint256 slotNum = GROUP_ID_TO_GROUP_PARTICIPANT_TO_PENULTIMATE_SHARED_KEY_MAPPING_SLOT;

        assembly {
            groupIdToGroupParticipantToPenultimateSharedKeyMapping.slot := slotNum
        }
    }
}
