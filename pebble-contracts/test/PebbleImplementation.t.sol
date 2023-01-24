// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {PebbleSetupLibraryTest} from "test/helpers/PebbleSetup.sol";
import {Pebble} from "src/Pebble.sol";

/**
forge test --match-path ./test/PebbleImplementation.t.sol -vvv
 */
contract PebbleImplementationTest is Test {
    Pebble pebbleImplementation;

    // Setup
    function setUp() external {
        (pebbleImplementation, ) = PebbleSetupLibraryTest.setupNewPebbleEnvironment();
    }

    // Implementation itself must not be upgradeable
    function testFailUpgrade() external {
        // Implementation itself must not be upgradeable
        Pebble implementationNew = new Pebble();
        pebbleImplementation.upgradeTo(address(implementationNew));
    }
}
