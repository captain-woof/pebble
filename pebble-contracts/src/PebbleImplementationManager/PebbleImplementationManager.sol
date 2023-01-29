// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {PebbleRoleManager} from "src/PebbleRoleManager/PebbleRoleManager.sol";

contract PebbleImplementationManager is
    Initializable,
    PebbleRoleManager,
    UUPSUpgradeable
{
    // Constructor
    constructor() {
        _disableInitializers();
    }

    // Initializer
    function __PebbleImplementatationManager_init_unchained()
        internal
        onlyInitializing
    {
        __UUPSUpgradeable_init_unchained();
    }

    // Checks to see if an upgrade is authorised, i.e, made by Pebble admin
    function _authorizeUpgrade(address) internal override onlyPebbleAdmin {}
}
