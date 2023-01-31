// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract PebbleRoleManager is AccessControlUpgradeable {
    // ROLES
    bytes32 public constant PEBBLE_ADMIN_ROLE =
        keccak256(abi.encodePacked("PEBBLE:PEBBLE_ADMIN_ROLE"));
    bytes32 public constant PEBBLE_DELEGATEE_ROLE =
        keccak256(abi.encodePacked("PEBBLE:PEBBLE_DELEGATEE_ROLE"));

    // Modifiers

    /**
    @dev Check if sender is a Pebble admin
     */
    modifier onlyPebbleAdmin() {
        _checkRole(PEBBLE_ADMIN_ROLE);
        _;
    }

    /**
    @dev Check if caller is a Pebble delegatee
     */
    modifier onlyPebbleDelegatee() {
        _checkRole(PEBBLE_DELEGATEE_ROLE);
        _;
    }

    // Functions

    /**
    @dev Initializer
    @param _pebbleAdmins Array of Pebble admins
    @param _delegatees Array of delegatees
     */
    function __PebbleRoleManager_init_unchained(
        address[] memory _pebbleAdmins,
        address[] memory _delegatees
    ) internal onlyInitializing {
        __AccessControl_init_unchained();

        // Set role admins
        _setRoleAdmin(PEBBLE_ADMIN_ROLE, PEBBLE_ADMIN_ROLE);
        _setRoleAdmin(PEBBLE_DELEGATEE_ROLE, PEBBLE_ADMIN_ROLE);

        // Assign roles
        uint256 pebbleAdminNum = _pebbleAdmins.length;
        uint256 delegateesNum = _delegatees.length;

        for (uint256 i; i < pebbleAdminNum; ++i) {
            _grantRole(PEBBLE_ADMIN_ROLE, _pebbleAdmins[i]);
        }

        for (uint256 i; i < delegateesNum; ++i) {
            _grantRole(PEBBLE_DELEGATEE_ROLE, _delegatees[i]);
        }
    }

    /**
    @dev Grants Pebble admin role to an address
    @dev Can only be called by Role admin of Pebble admin role, for obvious reasons
    @param _pebbleAdminNew New address to be granted Pebble admin role
     */
    function grantPebbleAdminRole(address _pebbleAdminNew) public {
        grantRole(PEBBLE_ADMIN_ROLE, _pebbleAdminNew);
    }

    /**
    @dev Grants Pebble Delegatee role to an address
    @dev Can only be called by Role admin of Delegatee role, for obvious reasons
    @param _delegateeNew New address to be granted Delegatee role
     */
    function grantPebbleDelegateeRole(address _delegateeNew) public {
        grantRole(PEBBLE_DELEGATEE_ROLE, _delegateeNew);
    }

    /**
    @dev Revokes Pebble admin role from an address
    @dev Can only be called by Role admin of Pebble admin role, for obvious reasons
    @param _pebbleAdminToRevoke Pebble admin role holder to revoke
     */
    function revokePebbleAdminRole(address _pebbleAdminToRevoke) public {
        revokeRole(PEBBLE_ADMIN_ROLE, _pebbleAdminToRevoke);
    }

    /**
    @dev Revokes Delegatee role from an address
    @dev Can only be called by Role admin of Delegatee role, for obvious reasons
    @param _delegateeToRevoke Delegatee role to revoke
     */
    function revokePebbleDelegateeRole(address _delegateeToRevoke) public {
        revokeRole(PEBBLE_DELEGATEE_ROLE, _delegateeToRevoke);
    }

    // Internals
    /**
    @dev Grants Delegatee role to an address
    @dev DOES NO CHECK FOR ROLE ADMIN
    @param _delegateeNew New address to be granted Delegatee role
     */
    function _grantPebbleDelegateeRole(address _delegateeNew) internal {
        _grantRole(PEBBLE_DELEGATEE_ROLE, _delegateeNew);
    }
}
