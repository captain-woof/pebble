// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleImplementationManager} from "./PebbleImplementationManager/PebbleImplementationManager.sol";
import {PebbleSignManager} from "./PebbleSignManager/PebbleSignManager.sol";
import {PebbleGroupManager} from "./PebbleGroupManager/PebbleGroupManager.sol";

contract Pebble is
    PebbleImplementationManager,
    PebbleSignManager,
    PebbleGroupManager
{
    // Data
    uint8 reinitializerVersion; // Stores version used for current Reinitializer

    // Constructor
    constructor() PebbleImplementationManager() {}

    // Initializer
    function initialize(string calldata _pebbleVersion)
        external
        reinitializer(_getReinitializerVersion())
    {
        __PebbleImplementatationManager_init_unchained();
        __PebbleSignMananger_init_unchained(_pebbleVersion);
        __PebbleGroupManager_init_unchained();
    }

    //////////
    // HELPERS
    //////////

    function _getReinitializerVersion() internal returns (uint8) {
        return ++reinitializerVersion;
    }
}
