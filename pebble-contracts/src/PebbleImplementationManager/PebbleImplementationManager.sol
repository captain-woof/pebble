// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PebbleImplementationManager is
    Initializable,
    OwnableUpgradeable,
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
        __Ownable_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    // Checks to see if an upgrade is authorised, i.e, made by owner
    function _authorizeUpgrade(address) internal override onlyOwner {}
}
