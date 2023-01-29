// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract PebbleRoleManager is AccessControlUpgradeable {
    // ROLES
    bytes32 private constant PEBBLE_ADMIN_ROLE =
        keccak256(abi.encodePacked("PEBBLE:PEBBLE_ADMIN_ROLE"));
    bytes32 private constant DELAGATEE_ROLE =
        keccak256(abi.encodePacked("PEBBLE:DELAGATEE_ROLE"));

    // Modifiers

    /**
    @dev Check if sender is a Pebble admin
     */
    modifier onlyPebbleAdmin() {
        _checkRole(PEBBLE_ADMIN_ROLE);
        _;
    }

    /**
    @dev Check if caller is a delagatee
     */
    modifier onlyDelagatee() {
        _checkRole(DELAGATEE_ROLE);
        _;
    }

    /**
    @dev Initializer
    @param _pebbleAdmins Array of Pebble admins
    @param _delagatees Array of delegatees
     */
    function __PebbleRoleManager_init_unchained(
        address[] memory _pebbleAdmins,
        address[] memory _delagatees
    ) internal onlyInitializing {
        __AccessControl_init_unchained();

        // Set role admins
        _setRoleAdmin(PEBBLE_ADMIN_ROLE, PEBBLE_ADMIN_ROLE);
        _setRoleAdmin(DELAGATEE_ROLE, PEBBLE_ADMIN_ROLE);

        // Assign roles
        uint256 pebbleAdminNum = _pebbleAdmins.length;
        uint256 delagateesNum = _delagatees.length;

        for (uint256 i; i < pebbleAdminNum; ++i) {
            _grantRole(PEBBLE_ADMIN_ROLE, _pebbleAdmins[i]);
        }

        for (uint256 i; i < delagateesNum; ++i) {
            _grantRole(DELAGATEE_ROLE, _delagatees[i]);
        }
    }
}
