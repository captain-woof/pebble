// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {PebbleRoleManager} from "src/PebbleRoleManager/PebbleRoleManager.sol";
import {DelagateVerificationInternals} from "./DelagateVerificationInternals.sol";

contract PebbleDelagateVerificationManager is
    PebbleRoleManager,
    DelagateVerificationInternals
{
    /**
    @dev Gets a delegator's next allowed nonce
    @dev Delegators must use this to sign anything
    @param _delegator Address of delegator
    @return nonce Delegator's allowed nonce
     */
    function getDelegatorNonce(address _delegator)
        external
        view
        returns (uint256 nonce)
    {
        nonce = _getDelegatorNonce(_delegator);
    }
}
