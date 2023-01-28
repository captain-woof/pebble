// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {EllipticCurve} from "src/Libraries/EllipticCurve.sol";

library PebbleUtilsTest {
    /**
    @dev Converts a string to an address
    @return addressFromString Address calculated from the hash of input string
     */
    function convertStringToAddress(string memory _stringToConvert)
        internal
        pure
        returns (address addressFromString)
    {
        addressFromString = address(
            uint160(uint256(keccak256(abi.encodePacked(_stringToConvert))))
        );
    }

    /**
    @dev Converts an integer to an address
    @return addressFromInt Address calculated from the hash of input integer
     */
    function convertIntToAddress(uint256 _intToConvert)
        internal
        pure
        returns (address addressFromInt)
    {
        addressFromInt = address(
            uint160(uint256(keccak256(abi.encodePacked(_intToConvert))))
        );
    }

    /**
    @dev Multiples a scalar to a point on curve (secp256k1)
    @param _scalar Scalar to multiply
    @param _pointX X coodinate of the point on curve
    @param _pointY Y coodinate of the point on curve
    @return resultPointX X coordinate of the resultant 
    @return resultPointY Y coordinate of the resultant
     */
    function multiplyScalarToPointOnCurve(
        uint256 _scalar,
        uint256 _pointX,
        uint256 _pointY
    ) internal pure returns (uint256, uint256) {
        return
            EllipticCurve.ecMul(
                _scalar,
                _pointX,
                _pointY,
                EllipticCurve.CurveA,
                EllipticCurve.CurveP
            );
    }

    /**
    @dev Gets public key corresponding to private key on curve (secp256k1)
    @param _privateKey Private key
    @return publicKeyX X coordinate of the public key
    @return publicKeyY Y coordinate of the public key
     */
    function getPublicKeyFromPrivateKey(uint256 _privateKey)
        internal
        pure
        returns (uint256, uint256)
    {
        return
            EllipticCurve.ecMul(
                _privateKey,
                EllipticCurve.CurveGx,
                EllipticCurve.CurveGy,
                EllipticCurve.CurveA,
                EllipticCurve.CurveP
            );
    }

    /**
    @dev Creates N number of key pairs
    @param _numOfKeyPairs Number of key pairs to create
    @return privateKeys Array of private keys
    @return publicKeyX Array of X coordinates of public keys
    @return publicKeyY Array of Y coordinates of public keys
     */
    function createNKeyPairs(uint256 _numOfKeyPairs)
        internal
        pure
        returns (
            uint256[] memory privateKeys,
            uint256[] memory publicKeyX,
            uint256[] memory publicKeyY
        )
    {
        // Create array of results
        privateKeys = new uint256[](_numOfKeyPairs);
        publicKeyX = new uint256[](_numOfKeyPairs);
        publicKeyY = new uint256[](_numOfKeyPairs);

        // Fill with results
        for (uint256 i; i < _numOfKeyPairs; ++i) {
            privateKeys[i] = uint256(keccak256(abi.encodePacked(i)));
            (publicKeyX[i], publicKeyY[i]) = getPublicKeyFromPrivateKey(
                privateKeys[i]
            );
        }
    }

    /**
    @dev Creates N number of addresses
    @param _numOfAddresses Number of addresses to create
    @return addresses Array of addresses
     */
    function createNPublicAddresses(uint256 _numOfAddresses)
        internal
        pure
        returns (address[] memory addresses)
    {
        // Create array of results
        addresses = new address[](_numOfAddresses);

        // Fill with results
        for (uint256 i; i < _numOfAddresses; ++i) {
            addresses[i] = convertIntToAddress(i);
        }
    }

    /**
    @dev Creates a pseudo random integer from a seed
     */
    function createRandomInteger(uint256 _seed)
        internal
        pure
        returns (uint256 pseudoRandomInteger)
    {
        pseudoRandomInteger = uint256(keccak256(abi.encodePacked(_seed)));
    }
}
