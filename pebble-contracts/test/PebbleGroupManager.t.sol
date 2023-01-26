// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {PebbleSetupLibraryTest} from "test/helpers/PebbleSetup.sol";
import {UtilsTest} from "test/helpers/Utils.sol";
import {Pebble} from "src/Pebble.sol";
import {PebbleProxy} from "src/PebbleProxy.sol";

/**
forge test --match-path ./test/PebbleGroupManager.t.sol -vvv
 */
contract PebbleGroupManagerTest is Test {
    Pebble pebbleImplementation;
    PebbleProxy pebbleProxy;

    // Setup
    function setUp() external {
        (pebbleImplementation, pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment();
    }

    // Groups should be correctly created
    /*function testCreateGroup() external {
        // Create penultimate shared key from creator
        uint256 updatedPenultimateSharedKeyFromCreator = 787887878788778787887;

        // Create participants
        address creator = UtilsTest.convertIntToAddress(0);
        address[] memory participantsOtherThanCreator = new address[](29);
        for (uint256 i = 1; i < 29; ++i) {
            participantsOtherThanCreator[i] = (
                UtilsTest.convertIntToAddress(i)
            );
        }

        // Create group
        Pebble(address(pebbleProxy)).createGroup(
            creator,
            participantsOtherThanCreator,
            updatedPenultimateSharedKeyFromCreator
        );
    }*/

    // Participants should be able to accept invite
    function testAcceptInvite() external {
        // Create penultimate shared key from creator
        uint256 updatedPenultimateSharedKeyFromCreator = 787887878788778787887;

        // Create participants
        address creator = UtilsTest.convertIntToAddress(0);
        address[] memory participantsOtherThanCreator = new address[](59);
        for (uint256 i = 0; i < 59; ++i) {
            participantsOtherThanCreator[i] = (
                UtilsTest.convertIntToAddress(i)
            );
        }

        // Create group
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            creator,
            participantsOtherThanCreator,
            updatedPenultimateSharedKeyFromCreator
        );

        // Accept invites
        for (uint256 i = 0; i < 59; ++i) {
            Pebble(address(pebbleProxy)).acceptGroupInvite(
                participantsOtherThanCreator[i],
                groupId,
                i
            );
        }
    }
}
