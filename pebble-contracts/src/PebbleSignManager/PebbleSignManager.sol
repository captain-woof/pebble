// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {SignInternals} from "./SignInternals.sol";

contract PebbleSignManager is EIP712Upgradeable, SignInternals {
    // Init function
    function __PebbleSignMananger_init_unchained(string memory _version)
        internal
        onlyInitializing
    {
        __EIP712_init_unchained("PEBBLE", _version);
        _setVersion(_version);
    }

    // Functions
    /**
    @dev Gets contract version, at correct slot
    @return version Contract version
     */
    function getVersion() external pure returns (string memory) {
        return _getVersion();
    }
}
