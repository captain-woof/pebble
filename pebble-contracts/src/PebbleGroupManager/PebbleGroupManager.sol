// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";

contract PebbleGroupManager is EIP712Upgradeable {
    function __PebbleGroupManager_init_unchained() internal onlyInitializing {}
}
