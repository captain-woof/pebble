// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {PebbleSetupLibraryTest} from "test/helpers/PebbleSetup.sol";
import {PebbleUtilsTest} from "test/helpers/PebbleUtils.sol";
import {Pebble} from "src/Pebble.sol";

/**
forge test --match-path ./test/PebbleImplementation.t.sol -vvv --via-ir
 */
contract PebbleImplementationTest is Test {
    Pebble pebbleImplementation;
    address[] pebbleAdmins;

    // Setup
    function setUp() external {
        pebbleAdmins.push(
            PebbleUtilsTest.convertStringToAddress("PEBBLE ADMIN")
        );

        (pebbleImplementation, ) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment(pebbleAdmins, new address[](0));
    }

    // Implementation itself must not be upgradeable
    function testFailUpgrade() external {
        // Implementation itself must not be upgradeable
        vm.startPrank(pebbleAdmins[0]);
        Pebble implementationNew = new Pebble();
        pebbleImplementation.upgradeTo(address(implementationNew));
        vm.stopPrank();
    }
}
