// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleMath} from "src/Utils/Math.sol";

contract GroupInternals {
    // Structs
    struct Group {
        address creator;
        address[] participantsOtherThanCreator;
    }

    struct PenultimateSharedKey {
        uint256 penultimateSharedKeyX; // X coordinate of shared key point on curve
        uint256 penultimateSharedKeyY; // Y coordinate of shared key point on curve
    }

    // Constants
    uint256 constant GROUP_NONCE_SLOT =
        uint256(keccak256("PEBBLE:GROUP_NONCE_SLOT"));
    uint256 constant GROUP_NUMBER_TO_GROUP_MAPPING_SLOT =
        uint256(keccak256("PEBBLE:GROUP_NUMBER_TO_GROUP_MAPPING_SLOT"));
    uint256 constant GROUP_ID_TO_GROUP_PARTICIPANT_TO_PENULTIMATE_SHARED_KEY_MAPPING_SLOT =
        uint256(
            keccak256(
                "PEBBLE:GROUP_ID_TO_GROUP_PARTICIPANT_TO_PENULTIMATE_SHARED_KEY_MAPPING_SLOT"
            )
        );
    uint256 constant GROUP_ID_TO_PENULTIMATE_SHARED_KEY_UPDATE_TIMESTAMP_MAPPING_SLOT =
        uint256(
            keccak256(
                "PEBBLE:GROUP_ID_TO_PENULTIMATE_SHARED_KEY_UPDATE_TIMESTAMP_MAPPING_SLOT"
            )
        );
    uint256 constant GROUP_ID_TO_PARTICIPANT_TO_DID_ACCEPT_INVITE_MAPPING_SLOT =
        uint256(
            keccak256(
                "PEBBLE:GROUP_ID_TO_PARTICIPANT_TO_DID_ACCEPT_INVITE_MAPPING_SLOT"
            )
        );

    // Events

    /**
    @dev Fired when a new group is created, and participants have to invited
     */
    event Invite(
        uint256 indexed groupId,
        address indexed creator,
        address indexed participant
    );

    /**
    @dev Fired when all invitees have accepted invitation to a group
     */
    event AllInvitesAccepted(uint256 indexed groupId);

    // Data
    mapping(address => uint256[]) private __groupParticipantToGroupIdsMapping; // Maps a group participant to array of group ids; DON'T USE DIRECTLY; USE SLOT HELPER
    mapping(uint256 => Group) private __groupIdToGroupMapping; // Maps a group id to group data; DON'T USE DIRECTLY; USE SLOT HELPER
    mapping(uint256 => mapping(address => PenultimateSharedKey))
        private __groupIdToGroupParticipantToPenultimateSharedKeyMapping; // Maps a group id to participant to penultimate shared key; DON'T USE DIRECTLY; USE SLOT HELPER
    mapping(uint256 => uint256)
        private __groupIdToPenultimateSharedKeyUpdateTimestampMapping; // Maps a Group ID to the timestamp its penultimate shared keys were last updated; DON'T USE DIRECTLY; USE SLOT HELPER
    mapping(uint256 => mapping(address => uint256)) __groupIdToParticipantToDidAcceptInvite; // Maps a group ID to a participant to whether the participant accepted group invite; 0 = no, 1 = yes

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
    @dev Get rooms a participant is present in
    @param _groupId Group id to setup new Group at
    @param _groupData Corresponding group data to set
     */
    function _setupGroup(uint256 _groupId, Group memory _groupData) internal {
        _getGroupIdToGroupMapping()[_groupId] = _groupData;
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
    ) internal view returns (PenultimateSharedKey memory penultimateSharedKey) {
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
        PenultimateSharedKey memory _newParticipantGroupPenultimateSharedKey
    ) internal {
        _getGroupIdToGroupParticipantToPenultimateSharedKeyMapping()[_groupId][
            _groupParticipant
        ] = _newParticipantGroupPenultimateSharedKey;
    }

    /**
    @dev Gets timestamp when a group's penultimate shared keys were last updated
    @param _groupId Group id of the group
    @return timestamp Timestamp when a group's penultimate shared keys were last updated
     */
    function _getGroupPenultimateSharedKeyLastUpdateTimestamp(uint256 _groupId)
        internal
        view
        returns (uint256 timestamp)
    {
        timestamp = _getGroupIdToPenultimateSharedKeyUpdateTimestampMapping()[
            _groupId
        ];
    }

    /**
    @dev Updates timestamp for a group's penultimate shared keys update
    @param _groupId Group id of the group
     */
    function _updateGroupPenultimateSharedKeyLastUpdateTimestamp(
        uint256 _groupId
    ) internal {
        _getGroupIdToPenultimateSharedKeyUpdateTimestampMapping()[
            _groupId
        ] = block.timestamp;
    }

    /**
    @dev Checks to see if a participant can accept invite to a group
    @param _groupId Group Id of the group the participant wants to join
    @param _groupParticipant Address of participant to check
     */
    function _canParticipantAcceptGroupInvite(
        uint256 _groupId,
        address _groupParticipant
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

    /**
    @dev Checks to see if a participant accepted a group id
    @param _groupId Group id of the group to check in
    @param _participant Participant to check for
    @return didParticipantAcceptGroupInvite True if yes
     */
    function _didParticipantAcceptGroupInvite(
        uint256 _groupId,
        address _participant
    ) internal view returns (bool) {
        return
            _getGroupIdToParticipantToDidAcceptInviteMapping()[_groupId][
                _participant
            ] == 1;
    }

    /**
    @dev Checks to see if a group's invitees have all accepted group invite
    @dev If true, group conversation can begin, else not.
    @param _groupId Group id to use for query
    @return hasAllParticipantsAcceptedInvite True if a group's invitees have all accepted group invite
     */
    function _didAllParticipantsAcceptInvite(uint256 _groupId)
        internal
        view
        returns (bool)
    {
        address[] memory participantsOtherThanCreator = _getGroupFromGroupId(
            _groupId
        ).participantsOtherThanCreator;
        for (uint256 i; i < participantsOtherThanCreator.length; ++i) {
            if (
                !_didParticipantAcceptGroupInvite(
                    _groupId,
                    participantsOtherThanCreator[i]
                )
            ) {
                return false;
            }
        }
        return true;
    }

    /**
    @dev Marks a participant acceptance to group invite
    @param _groupId Group id of the group to use
    @param _participant Participant that accept invite
     */
    function _markParticipantAcceptanceToGroupInvite(
        uint256 _groupId,
        address _participant
    ) internal {
        _getGroupIdToParticipantToDidAcceptInviteMapping()[_groupId][
            _participant
        ] = 1;
    }

    /**
    @dev Creates a new group, and sets it up for accepting (i.e, arriving at the final penultimate shared key)
    @param _groupCreator Address of the group creator
    @param _groupParticipantsOtherThanCreator Array of group participants other than group creator
    @param _initialPenultimateSharedKeyForCreator Initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyFromCreator Initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @return groupId New group's ID
     */
    function _createGroup(
        address _groupCreator,
        address[] memory _groupParticipantsOtherThanCreator,
        PenultimateSharedKey memory _initialPenultimateSharedKeyForCreator,
        PenultimateSharedKey memory _initialPenultimateSharedKeyFromCreator
    ) internal returns (uint256 groupId) {
        // Create new group object
        Group memory group = Group({
            creator: _groupCreator,
            participantsOtherThanCreator: _groupParticipantsOtherThanCreator
        });

        // Store group
        groupId = _getAndIncrementGroupNonce();
        _setupGroup(groupId, group);

        // Update penultimate shared keys + Send invites
        require(
            PebbleMath.isPublicKeyOnCurve(
                _initialPenultimateSharedKeyForCreator.penultimateSharedKeyX,
                _initialPenultimateSharedKeyForCreator.penultimateSharedKeyY
            ),
            "PEBBLE: INITIAL PENULTIMATE SHARED KEY FOR CREATOR NOT ON CURVE"
        );
        require(
            PebbleMath.isPublicKeyOnCurve(
                _initialPenultimateSharedKeyFromCreator.penultimateSharedKeyX,
                _initialPenultimateSharedKeyFromCreator.penultimateSharedKeyY
            ),
            "PEBBLE: INITIAL PENULTIMATE SHARED KEY FROM CREATOR NOT ON CURVE"
        );

        // Update penultimate shared keys for creator
        _updateParticipantGroupPenultimateSharedKey(
            groupId,
            _groupCreator,
            _initialPenultimateSharedKeyForCreator
        );

        // Update penultimate shared keys from creator
        uint256 groupParticipantsOtherThanCreatorNum = _groupParticipantsOtherThanCreator
                .length;
        address groupParticipantOtherThanCreator;
        for (uint256 i; i < groupParticipantsOtherThanCreatorNum; ++i) {
            groupParticipantOtherThanCreator = _groupParticipantsOtherThanCreator[
                i
            ];

            // Update penultimate shared keys from creator
            _updateParticipantGroupPenultimateSharedKey(
                groupId,
                groupParticipantOtherThanCreator,
                _initialPenultimateSharedKeyFromCreator
            );

            // Send invites to participants
            emit Invite(
                groupId,
                _groupCreator,
                groupParticipantOtherThanCreator
            );
        }
    }

    /**
    @dev Accepts invititation to a group
    @param _groupParticipant Group participant who wants to accept group invite
    @param _groupId Group id of the group to accept invite for
    @param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
    @param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
    */
    function _acceptGroupInvite(
        uint256 _groupId,
        address _groupParticipant,
        address[] memory _penultimateKeysFor,
        uint256[] memory _penultimateKeysXUpdated,
        uint256[] memory _penultimateKeysYUpdated,
        uint256 _timestampForWhichUpdatedKeysAreMeant
    ) internal {
        // Check if participant can enter group
        require(
            _canParticipantAcceptGroupInvite(_groupId, _groupParticipant),
            "PEBBLE: NOT INVITED"
        );
        require(
            !_didParticipantAcceptGroupInvite(_groupId, _groupParticipant),
            "PEBBLE: ALREADY ACCEPTED INVITE"
        );

        // Check array lengths
        uint256 penultimateKeysForLength = _penultimateKeysFor.length;
        require(
            penultimateKeysForLength == _penultimateKeysXUpdated.length,
            "PEBBLE: INCORRECT ARRAY LENGTH"
        );
        require(
            penultimateKeysForLength == _penultimateKeysYUpdated.length,
            "PEBBLE: INCORRECT ARRAY LENGTH"
        );
        require(
            penultimateKeysForLength ==
                _getGroupFromGroupId(_groupId)
                    .participantsOtherThanCreator
                    .length,
            "PEBBLE: INCORRECT ARRAY LENGTH"
        );

        // Check and update timestamp
        require(
            _getGroupPenultimateSharedKeyLastUpdateTimestamp(_groupId) ==
                _timestampForWhichUpdatedKeysAreMeant,
            "PEBBLE: KEY UPDATES BASED ON EXPIRED DATA"
        );
        _updateGroupPenultimateSharedKeyLastUpdateTimestamp(_groupId);

        // Update penultimate shared keys for intended participants
        for (uint256 i; i < penultimateKeysForLength; ++i) {
            require(
                PebbleMath.isPublicKeyOnCurve(
                    _penultimateKeysXUpdated[i],
                    _penultimateKeysYUpdated[i]
                ),
                "PEBBLE: UPDATED PENULTIMATE SHARED KEY NOT ON CURVE"
            );

            _updateParticipantGroupPenultimateSharedKey(
                _groupId,
                _penultimateKeysFor[i],
                PenultimateSharedKey(
                    _penultimateKeysXUpdated[i],
                    _penultimateKeysYUpdated[i]
                )
            );
        }

        // Mark participant's acceptance to group invite
        _markParticipantAcceptanceToGroupInvite(_groupId, _groupParticipant);

        // If all invitees have accepted group invite, fire event
        if (_didAllParticipantsAcceptInvite(_groupId)) {
            emit AllInvitesAccepted(_groupId);
        }
    }

    ////////////////
    // SLOT HELPERS
    ////////////////

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
            mapping(uint256 => mapping(address => PenultimateSharedKey))
                storage groupIdToGroupParticipantToPenultimateSharedKeyMapping
        )
    {
        groupIdToGroupParticipantToPenultimateSharedKeyMapping = __groupIdToGroupParticipantToPenultimateSharedKeyMapping;

        uint256 slotNum = GROUP_ID_TO_GROUP_PARTICIPANT_TO_PENULTIMATE_SHARED_KEY_MAPPING_SLOT;

        assembly {
            groupIdToGroupParticipantToPenultimateSharedKeyMapping.slot := slotNum
        }
    }

    /**
    @dev Gets a mapping from group ids to participants to their penultimate shared key at correct slot
     */
    function _getGroupIdToPenultimateSharedKeyUpdateTimestampMapping()
        private
        view
        returns (
            mapping(uint256 => uint256)
                storage groupIdToPenultimateSharedKeyUpdateTimestampMapping
        )
    {
        groupIdToPenultimateSharedKeyUpdateTimestampMapping = __groupIdToPenultimateSharedKeyUpdateTimestampMapping;

        uint256 slotNum = GROUP_ID_TO_PENULTIMATE_SHARED_KEY_UPDATE_TIMESTAMP_MAPPING_SLOT;

        assembly {
            groupIdToPenultimateSharedKeyUpdateTimestampMapping.slot := slotNum
        }
    }

    /**
    @dev Gets a mapping from group ids to participants to whether they accepted group invite, at correct slot
     */
    function _getGroupIdToParticipantToDidAcceptInviteMapping()
        private
        view
        returns (
            mapping(uint256 => mapping(address => uint256))
                storage groupIdToParticipantToDidAcceptInvite
        )
    {
        groupIdToParticipantToDidAcceptInvite = __groupIdToParticipantToDidAcceptInvite;

        uint256 slotNum = GROUP_ID_TO_PARTICIPANT_TO_DID_ACCEPT_INVITE_MAPPING_SLOT;

        assembly {
            groupIdToParticipantToDidAcceptInvite.slot := slotNum
        }
    }
}
