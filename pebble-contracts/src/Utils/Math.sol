// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {EllipticCurve} from "src/Libraries/EllipticCurve.sol";

library PebbleMath {
    /**
    @dev Returns the minimum of 2 numbers
     */
    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }

    /**
    @dev Checks to see if the input points for a Public key are on secp256k1 curve
    @param _publicKeyX X coodinate of Public key
    @param _publicKeyY Y coodinate of Public key
    @return isPublicKeyOnGraph True, if the public key is on curve, else False.
     */
    function isPublicKeyOnCurve(uint256 _publicKeyX, uint256 _publicKeyY)
        internal
        pure
        returns (bool)
    {
        return
            EllipticCurve.isOnCurve(
                _publicKeyX,
                _publicKeyY,
                EllipticCurve.CurveA,
                EllipticCurve.CurveB,
                EllipticCurve.CurveP
            );
    }
}
