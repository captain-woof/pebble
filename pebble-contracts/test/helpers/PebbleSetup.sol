// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "src/Pebble.sol";
import "src/PebbleProxy.sol";

library PebbleSetupLibraryTest {
    /**
     */
    function setupNewPebbleEnvironment()
        internal
        returns (Pebble pebbleImplementation, PebbleProxy pebbleProxy)
    {
        // Deploy Pebble implementation
        pebbleImplementation = new Pebble();

        // Deploy Pebble proxy
        pebbleProxy = new PebbleProxy(
            address(pebbleImplementation)
        );

        // Configure Pebble proxy
        Pebble(address(pebbleProxy)).initialize("1.0.0");
    }
}
