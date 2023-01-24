// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {PebbleSetupLibraryTest} from "test/helpers/PebbleSetup.sol";
import {UtilsTest} from "test/helpers/Utils.sol";
import {Pebble} from "src/Pebble.sol";
import {PebbleProxy} from "src/PebbleProxy.sol";

/**
forge test --match-path ./test/PebbleProxyTest.t.sol -vvv
 */
contract PebbleProxyTest is Test {
    // Test Proxy implementation correctness
    function testProxyImplementation() external {
        (
            Pebble pebbleImplementation,
            PebbleProxy pebbleProxy
        ) = PebbleSetupLibraryTest.setupNewPebbleEnvironment();
        require(
            pebbleProxy.getImplementation() == address(pebbleImplementation),
            "PROXY: INCORRECT IMPLEMENTATION"
        );
    }

    // Test Proxy access controls - for owner
    function testUpgradeAccessControl() external {
        (, PebbleProxy pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment();
        Pebble pebbleImplementationNew = new Pebble();
        Pebble(address(pebbleProxy)).upgradeTo(
            address(pebbleImplementationNew)
        );

        require(
            pebbleProxy.getImplementation() == address(pebbleImplementationNew),
            "PROXY: INCORRECT NEW IMPLEMENTATION"
        );
    }

    // Test Proxy access controls - for others
    function testFailUpgradeAccessControl() external {
        (, PebbleProxy pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment();

        address unauthorisedAddr = UtilsTest.convertStringToAddress(
            "UNAUTHORISED_ADDRESS"
        );
        vm.startPrank(unauthorisedAddr);

        Pebble pebbleImplementationNew = new Pebble();
        Pebble(address(pebbleProxy)).upgradeTo(
            address(pebbleImplementationNew)
        );

        vm.stopPrank();
    }
}
