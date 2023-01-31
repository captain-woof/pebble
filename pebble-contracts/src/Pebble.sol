// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleImplementationManager} from "src/PebbleImplementationManager/PebbleImplementationManager.sol";
import {PebbleSignManager} from "src/PebbleSignManager/PebbleSignManager.sol";
import {PebbleGroupManager} from "src/PebbleGroupManager/PebbleGroupManager.sol";
import {PebbleRoleManager} from "src/PebbleRoleManager/PebbleRoleManager.sol";
import {PebbleDelegatee} from "src/PebbleDelegatee.sol";

contract Pebble is
    PebbleRoleManager,
    PebbleImplementationManager,
    PebbleSignManager,
    PebbleGroupManager
{
    // Constructor
    constructor() PebbleImplementationManager() {}

    /**
    @dev Initializer function
    @param _pebbleVersion Version of this implementation contract
    @param _pebbleAdmins Array of Pebble admins
    @param _delegatees Array of delegatees trusted for subscriptions
     */
    function initialize(
        string calldata _pebbleVersion,
        address[] calldata _pebbleAdmins,
        address[] calldata _delegatees
    ) external initializer {
        __PebbleRoleManager_init_unchained(_pebbleAdmins, _delegatees);
        __PebbleImplementatationManager_init_unchained();
        __PebbleSignMananger_init_unchained(_pebbleVersion);
        __PebbleGroupManager_init_unchained();
    }

    /**
    @dev Re-Initializer function; only Pebble admins can re-initialize proxy
    @param _pebbleVersion New version of this implementation contract; OLD ROLES NEED TO BE MANUALLY REVOKED
    @param _pebbleAdmins New array of Pebble admins; OLD ROLES NEED TO BE MANUALLY REVOKED
    @param _delegatees New array of delegatees trusted for subscriptions
     */
    function reinitialize(
        string calldata _pebbleVersion,
        address[] calldata _pebbleAdmins,
        address[] calldata _delegatees
    ) external onlyPebbleAdmin reinitializer(_getInitializedVersion() + 1) {
        __PebbleRoleManager_init_unchained(_pebbleAdmins, _delegatees);
        __PebbleImplementatationManager_init_unchained();
        __PebbleSignMananger_init_unchained(_pebbleVersion);
        __PebbleGroupManager_init_unchained();
    }

    /**
    @dev Deploys and assigns Delegatee role to a new Delegatee contract
    @param _delegateFeesBasis Delegate fees (in basis) to use
    @return pebbleDelegatee New pebble delegatee contract deployed
     */
    function deployAndAssignDelegateeContract(uint256 _delegateFeesBasis)
        external
        returns (PebbleDelegatee pebbleDelegatee)
    {
        pebbleDelegatee = new PebbleDelegatee(_delegateFeesBasis);
        grantPebbleDelegateeRole(address(pebbleDelegatee));
    }
}
