// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleDelegatee} from "src/PebbleDelegatee.sol";
import {Pebble} from "src/Pebble.sol";
import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import {Vm} from "forge-std/Vm.sol";

library PebbleDelegateHelpersTest {
    // CONSTANTS
    bytes32 constant TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
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
            "function sendMessageInGroupForDelegator(uint256 _groupId,address _sender,bytes _encryptedMessage,uint256 _senderDelegatorNonce)"
        );

    /**
    @dev Builds domain seperator for Pebble proxy
    @param _pebbleProxy Pebble proxy for which to get domain seperator
     */
    function getDomainSeparator(Pebble _pebbleProxy)
        internal
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    TYPE_HASH,
                    keccak256(bytes("PEBBLE")),
                    keccak256(bytes(_pebbleProxy.getVersion())),
                    block.chainid,
                    address(_pebbleProxy)
                )
            );
    }

    /**
    @dev Gets params needed to creates a new group via delegation
    @param _groupCreator Address of the group creator (Delegator in this case)
    @param _groupParticipantsOtherThanCreator Array of group participants other than group creator
    @param _initialPenultimateSharedKeyForCreatorX X coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyForCreatorY Y coordinate of initial value of penultimate shared key to use for creator, i.e, RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorX X coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @param _initialPenultimateSharedKeyFromCreatorY Y coordinate of initial value of penultimate shared key to use for all participants other than creator, i.e, Creator private key * RANDOM * G
    @param _pebbleProxy Pebble proxy
    @param _groupCreatorPrivateKey Group creator's private key for signing
    @param _vm Vm instance from forge
    @return groupCreatorDelegatorNonce Group creator delegate nonce needed for verification
    @return v v component of signature needed to delegate 
    @return r r component of signature needed to delegate
    @return s s component of signature needed to delegate
     */
    function getCreateGroupForDelegatorParams(
        address _groupCreator,
        address[] memory _groupParticipantsOtherThanCreator,
        uint256 _initialPenultimateSharedKeyForCreatorX,
        uint256 _initialPenultimateSharedKeyForCreatorY,
        uint256 _initialPenultimateSharedKeyFromCreatorX,
        uint256 _initialPenultimateSharedKeyFromCreatorY,
        Pebble _pebbleProxy,
        uint256 _groupCreatorPrivateKey,
        Vm _vm
    )
        internal
        view
        returns (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        // Get group creator nonce
        groupCreatorDelegatorNonce = _pebbleProxy.getDelegatorNonce(
            _groupCreator
        );

        // Get signing params
        bytes32 inputParamsHash = ECDSAUpgradeable.toTypedDataHash(
            getDomainSeparator(_pebbleProxy),
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
                    groupCreatorDelegatorNonce
                )
            )
        );

        // Sign data
        (v, r, s) = _vm.sign(_groupCreatorPrivateKey, inputParamsHash);
    }

    /**
    @dev Gets params for accepting invititation to a group via delegation
    @param _groupId Group id of the group to accept invite for
    @param _groupParticipant Group participant who wants to accept group invite
    @param _penultimateKeysFor Addresses for which updated penultimate shared keys are meant for
    @param _penultimateKeysXUpdated Array of X coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _penultimateKeysYUpdated Array of Y coordinates of updated penultimate shared key corresponding to `_penultimateKeysFor`
    @param _timestampForWhichUpdatedKeysAreMeant Timestamp at which the invitee checked the last updated penultimate keys
    @param _pebbleProxy Pebble proxy
    @param _groupParticipantPrivateKey Group participant's private key for signing
    @param _vm Vm instance from forge
    @return groupParticipantDelegatorNonce Group participant delegate nonce needed for verification
    @return v v component of signature needed to delegate 
    @return r r component of signature needed to delegate
    @return s s component of signature needed to delegate
    */
    function getAcceptGroupInviteForDelegatorParams(
        uint256 _groupId,
        address _groupParticipant,
        address[] memory _penultimateKeysFor,
        uint256[] memory _penultimateKeysXUpdated,
        uint256[] memory _penultimateKeysYUpdated,
        uint256 _timestampForWhichUpdatedKeysAreMeant,
        Pebble _pebbleProxy,
        uint256 _groupParticipantPrivateKey,
        Vm _vm
    )
        internal
        view
        returns (
            uint256 groupParticipantDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        // Get group participant nonce
        groupParticipantDelegatorNonce = _pebbleProxy.getDelegatorNonce(
            _groupParticipant
        );

        // Get signing params
        bytes32 inputParamsHash = ECDSAUpgradeable.toTypedDataHash(
            getDomainSeparator(_pebbleProxy),
            keccak256(
                abi.encode(
                    ACCEPT_GROUP_INVITE_FOR_DELEGATOR_TYPEHASH,
                    _groupId,
                    _groupParticipant,
                    abi.encode(_penultimateKeysFor),
                    abi.encode(_penultimateKeysXUpdated),
                    abi.encode(_penultimateKeysYUpdated),
                    _timestampForWhichUpdatedKeysAreMeant,
                    groupParticipantDelegatorNonce
                )
            )
        );

        // Sign data
        (v, r, s) = _vm.sign(_groupParticipantPrivateKey, inputParamsHash);
    }

    /**
    @dev Gets params needed to sends a message from Sender in a group via delegation
    @param _groupId Group id of the group to send message in
    @param _sender Sender who wants to send message
    @param _encryptedMessage Encrypted message to send (MUST BE ENCRYPTED BY SHARED KEY, NOT PENULTIMATE SHARED KEY; SHARED KEY = SENDER PRIVATE KEY * SENDER PENULTIMATE SHARED KEY; THIS MUST BE CALCULATED LOCALLY)
    @param _pebbleProxy Pebble proxy
    @param _senderPrivateKey Sender's private key for signing
    @param _vm Vm instance from forge
    @return senderDelegatorNonce Sender's delegate nonce needed for verification
    @return v v component of signature needed to delegate 
    @return r r component of signature needed to delegate
    @return s s component of signature needed to delegate
     */
    function getSendMessageInGroupForDelegatorParams(
        uint256 _groupId,
        address _sender,
        bytes memory _encryptedMessage,
        Pebble _pebbleProxy,
        uint256 _senderPrivateKey,
        Vm _vm
    )
        internal
        view
        returns (
            uint256 senderDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        // Get sender nonce
        senderDelegatorNonce = _pebbleProxy.getDelegatorNonce(_sender);

        // Get signing params
        bytes32 inputParamsHash = ECDSAUpgradeable.toTypedDataHash(
            getDomainSeparator(_pebbleProxy),
            keccak256(
                abi.encode(
                    SEND_MESSAGE_IN_GROUP_FOR_DELEGATOR_TYPEHASH,
                    _groupId,
                    _sender,
                    keccak256(_encryptedMessage),
                    senderDelegatorNonce
                )
            )
        );

        // Sign data
        (v, r, s) = _vm.sign(_senderPrivateKey, inputParamsHash);
    }
}
