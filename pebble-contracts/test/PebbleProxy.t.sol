// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {PebbleSetupLibraryTest} from "test/helpers/PebbleSetup.sol";
import {PebbleUtilsTest} from "test/helpers/PebbleUtils.sol";
import {Pebble} from "src/Pebble.sol";
import {PebbleProxy} from "src/PebbleProxy.sol";

/**
forge test --match-path ./test/PebbleProxy.t.sol -vvv --via-ir
 */
contract PebbleProxyTest is Test {
    address[] pebbleAdmins;

    function setUp() external {
        pebbleAdmins.push(
            PebbleUtilsTest.convertStringToAddress("PEBBLE ADMIN")
        );
    }

    // Test Proxy implementation correctness
    function testProxyImplementation() external {
        vm.startPrank(pebbleAdmins[0]);
        (
            Pebble pebbleImplementation,
            PebbleProxy pebbleProxy
        ) = PebbleSetupLibraryTest.setupNewPebbleEnvironment(
                pebbleAdmins,
                new address[](0)
            );
        require(
            pebbleProxy.getImplementation() == address(pebbleImplementation),
            "PROXY: INCORRECT IMPLEMENTATION"
        );
        vm.stopPrank();
    }

    // Test Proxy access controls - for Pebble admin
    function testUpgradeAccessControl() external {
        vm.startPrank(pebbleAdmins[0]);
        (, PebbleProxy pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment(pebbleAdmins, new address[](0));
        Pebble pebbleImplementationNew = new Pebble();
        Pebble(address(pebbleProxy)).upgradeTo(
            address(pebbleImplementationNew)
        );

        require(
            pebbleProxy.getImplementation() == address(pebbleImplementationNew),
            "PROXY: INCORRECT NEW IMPLEMENTATION"
        );
        vm.stopPrank();
    }

    // Test Proxy access controls - for others
    function testFailUpgradeAccessControl() external {
        vm.startPrank(pebbleAdmins[0]);
        (, PebbleProxy pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment(pebbleAdmins, new address[](0));
        vm.stopPrank();

        address unauthorisedAddr = PebbleUtilsTest.convertStringToAddress(
            "UNAUTHORISED_ADDRESS"
        );
        vm.startPrank(unauthorisedAddr);

        Pebble pebbleImplementationNew = new Pebble();
        Pebble(address(pebbleProxy)).upgradeTo(
            address(pebbleImplementationNew)
        );

        vm.stopPrank();
    }

    // Test Proxy multiple initialization by calling `initialize()` multiple times
    function testFailProxyMultipleInitialization() external {
        vm.startPrank(pebbleAdmins[0]);
        (, PebbleProxy pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment(pebbleAdmins, new address[](0));
        Pebble(address(pebbleProxy)).initialize(
            "1.0.1",
            pebbleAdmins,
            new address[](0)
        );
        vm.stopPrank();
    }

    // Test Proxy re-initialization by Pebble admins
    function testProxyReInitializationByPebbleAdmin() external {
        vm.startPrank(pebbleAdmins[0]);
        (, PebbleProxy pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment(pebbleAdmins, new address[](0));

        Pebble(address(pebbleProxy)).reinitialize(
            "1.0.1",
            pebbleAdmins,
            new address[](0)
        );
        vm.stopPrank();
    }

    // Test Proxy re-initialization by non Pebble admins
    function testFailProxyReInitializationByNonPebbleAdmin() external {
        vm.startPrank(pebbleAdmins[0]);
        (, PebbleProxy pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment(pebbleAdmins, new address[](0));
        vm.stopPrank();

        address unauthorisedAddr = PebbleUtilsTest.convertStringToAddress(
            "UNAUTHORISED_ADDRESS"
        );
        address[] memory pebbleAdminsMalicious = new address[](1);
        pebbleAdminsMalicious[0] = unauthorisedAddr;
        vm.startPrank(unauthorisedAddr);
        Pebble(address(pebbleProxy)).reinitialize(
            "69",
            pebbleAdminsMalicious,
            new address[](0)
        );
        vm.stopPrank();
    }
}
