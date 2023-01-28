// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {PebbleSetupLibraryTest} from "test/helpers/PebbleSetup.sol";
import {PebbleUtilsTest} from "test/helpers/PebbleUtils.sol";
import {Pebble} from "src/Pebble.sol";
import {PebbleProxy} from "src/PebbleProxy.sol";

/**
forge test --match-path ./test/PebbleGroupManager.t.sol -vvv --via-ir
 */
contract PebbleGroupManagerTest is Test {
    // Data
    Pebble pebbleImplementation;
    PebbleProxy pebbleProxy;

    // Events
    event Invite(
        uint256 indexed groupId,
        address indexed creator,
        address indexed participant
    );
    event AllInvitesAccepted(uint256 indexed groupId);
    event SendMessage(
        uint256 indexed groupId,
        address indexed sender,
        bytes encryptedMessage
    );

    // Setup
    function setUp() external {
        (pebbleImplementation, pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment();
    }

    // Groups should be correctly created
    function testCreateGroup() external {
        // Create participants
        (uint256[] memory privateKeys, , ) = PebbleUtilsTest.createNKeyPairs(3);
        address[] memory addresses = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.expectEmit(false, true, true, false); // Expect correct `Invite` events to be fired
        emit Invite(0, addresses[0], groupParticipantsOtherThanCreator[0]);
        vm.expectEmit(false, true, true, false); // Expect correct `Invite` events to be fired
        emit Invite(0, addresses[0], groupParticipantsOtherThanCreator[1]);
        vm.startPrank(addresses[0]);
        Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key For Creator - X
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyForCreatorX()
        external
    {
        // Create participants
        (uint256[] memory privateKeys, , ) = PebbleUtilsTest.createNKeyPairs(3);
        address[] memory addresses = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX + 1,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key For Creator - Y
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyForCreatorY()
        external
    {
        // Create participants
        (uint256[] memory privateKeys, , ) = PebbleUtilsTest.createNKeyPairs(3);
        address[] memory addresses = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY + 1,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key From Creator - X
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyFromCreatorX()
        external
    {
        // Create participants
        (uint256[] memory privateKeys, , ) = PebbleUtilsTest.createNKeyPairs(3);
        address[] memory addresses = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX + 1,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key From Creator - Y
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyFromCreatorY()
        external
    {
        // Create participants
        (uint256[] memory privateKeys, , ) = PebbleUtilsTest.createNKeyPairs(3);
        address[] memory addresses = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY + 1
        );
        vm.stopPrank();
    }

    // Group ids must not be repeated
    function testGroupIdsUniqueness() external {
        // Create participants for Group 1
        (uint256[] memory privateKeys1, , ) = PebbleUtilsTest.createNKeyPairs(
            3
        );
        address[] memory addresses1 = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer for Group 1
        uint256 random1 = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group for Group 1
        address[] memory groupParticipantsOtherThanCreator1 = new address[](2);
        groupParticipantsOtherThanCreator1[0] = addresses1[1];
        groupParticipantsOtherThanCreator1[1] = addresses1[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX1,
            uint256 initialPenultimateSharedKeyForCreatorY1
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random1);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX1,
            uint256 initialPenultimateSharedKeyFromCreatorY1
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys1[0],
                initialPenultimateSharedKeyForCreatorX1,
                initialPenultimateSharedKeyForCreatorY1
            );

        // Create group for Group 1
        vm.startPrank(addresses1[0]);
        uint256 group1 = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator1,
            initialPenultimateSharedKeyForCreatorX1,
            initialPenultimateSharedKeyForCreatorY1,
            initialPenultimateSharedKeyFromCreatorX1,
            initialPenultimateSharedKeyFromCreatorY1
        );
        vm.stopPrank();

        // Create participants for Group 2
        (uint256[] memory privateKeys2, , ) = PebbleUtilsTest.createNKeyPairs(
            3
        );
        address[] memory addresses2 = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer for Group 2
        uint256 random2 = PebbleUtilsTest.createRandomInteger(60);

        // Prepare arguments for creating group for Group 2
        address[] memory groupParticipantsOtherThanCreator2 = new address[](2);
        groupParticipantsOtherThanCreator2[0] = addresses2[1];
        groupParticipantsOtherThanCreator2[1] = addresses2[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX2,
            uint256 initialPenultimateSharedKeyForCreatorY2
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random2);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX2,
            uint256 initialPenultimateSharedKeyFromCreatorY2
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys2[0],
                initialPenultimateSharedKeyForCreatorX2,
                initialPenultimateSharedKeyForCreatorY2
            );

        // Create group for Group 2
        vm.startPrank(addresses2[0]);
        uint256 group2 = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator2,
            initialPenultimateSharedKeyForCreatorX2,
            initialPenultimateSharedKeyForCreatorY2,
            initialPenultimateSharedKeyFromCreatorX2,
            initialPenultimateSharedKeyFromCreatorY2
        );
        vm.stopPrank();

        require(group2 - group1 == 1, "PEBBLE TEST: GROUP IDs NOT UNIQUE");
    }

    // Invited participants should be able to accept invite
    function testInvitedParticipantsInvitationAcceptance() external {
        // Create participants
        (uint256[] memory privateKeys, , ) = PebbleUtilsTest.createNKeyPairs(3);
        address[] memory addresses = PebbleUtilsTest.createNPublicAddresses(3);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;
        uint256[] memory penultimateKeysXUpdated = new uint256[](
            penultimateKeysForNum
        );
        uint256[] memory penultimateKeysYUpdated = new uint256[](
            penultimateKeysForNum
        );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (penultimateKeysXUpdated[i], penultimateKeysYUpdated[i]) = Pebble(
                address(pebbleProxy)
            ).getParticipantGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor[i]
                );
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Accept invite - Participant 2
        vm.startPrank(groupParticipantsOtherThanCreator[1]);
        penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        timestampForWhichUpdatedKeysAreMeant = Pebble(address(pebbleProxy))
            .getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        penultimateKeysForNum = penultimateKeysFor.length;
        penultimateKeysXUpdated = new uint256[](penultimateKeysForNum);
        penultimateKeysYUpdated = new uint256[](penultimateKeysForNum);

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (penultimateKeysXUpdated[i], penultimateKeysYUpdated[i]) = Pebble(
                address(pebbleProxy)
            ).getParticipantGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor[i]
                );
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[2],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        vm.expectEmit(true, false, false, false);
        emit AllInvitesAccepted(groupId);
        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // All penultimate shared keys must give same shared key
        (
            uint256 participant1PenultimateSharedKeyX,
            uint256 participant1PenultimateSharedKeyY
        ) = Pebble(address(pebbleProxy))
                .getParticipantGroupPenultimateSharedKey(groupId, addresses[0]);
        (
            uint256 participant2PenultimateSharedKeyX,
            uint256 participant2PenultimateSharedKeyY
        ) = Pebble(address(pebbleProxy))
                .getParticipantGroupPenultimateSharedKey(groupId, addresses[1]);
        (
            uint256 participant3PenultimateSharedKeyX,
            uint256 participant3PenultimateSharedKeyY
        ) = Pebble(address(pebbleProxy))
                .getParticipantGroupPenultimateSharedKey(groupId, addresses[2]);

        (uint256 participant1SharedKeyX, ) = PebbleUtilsTest
            .multiplyScalarToPointOnCurve(
                privateKeys[0],
                participant1PenultimateSharedKeyX,
                participant1PenultimateSharedKeyY
            );
        (uint256 participant2SharedKeyX, ) = PebbleUtilsTest
            .multiplyScalarToPointOnCurve(
                privateKeys[1],
                participant2PenultimateSharedKeyX,
                participant2PenultimateSharedKeyY
            );
        (uint256 participant3SharedKeyX, ) = PebbleUtilsTest
            .multiplyScalarToPointOnCurve(
                privateKeys[2],
                participant3PenultimateSharedKeyX,
                participant3PenultimateSharedKeyY
            );

        require(
            participant1SharedKeyX == participant2SharedKeyX,
            "PEBBLE TEST: UNEQUAL SHARED KEY"
        );
        require(
            participant1SharedKeyX == participant3SharedKeyX,
            "PEBBLE TEST: UNEQUAL SHARED KEY"
        );
    }

    // Invitees should not be able to accept invitation twice

    // Invitees should not be able to accept invitation to a non-existent group

    // Non-invitees should not be able to accept invitation
}
