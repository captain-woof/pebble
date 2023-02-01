// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {EllipticCurve} from "src/Libraries/EllipticCurve.sol";
import {Vm} from "forge-std/Vm.sol";

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
    @dev Creates users for testing, i.e, their private keys, public keys
    @param _numOfUsers Number of users to create
    @param _vm vm instance for forge test
    @return privateKeys Array of private keys
    @return publicKeysX Array of X coordinates of public keys
    @return publicKeysY Array of Y coordinates of public keys
    @return addresses Array of addresses corresponding to publicKeyX and publicKeyY
     */
    function createUsers(uint256 _numOfUsers, Vm _vm)
        internal
        pure
        returns (
            uint256[] memory privateKeys,
            uint256[] memory publicKeysX,
            uint256[] memory publicKeysY,
            address[] memory addresses
        )
    {
        // Create array of results
        privateKeys = new uint256[](_numOfUsers);
        publicKeysX = new uint256[](_numOfUsers);
        publicKeysY = new uint256[](_numOfUsers);
        addresses = new address[](_numOfUsers);

        // Fill with results
        for (uint256 i; i < _numOfUsers; ++i) {
            privateKeys[i] = uint256(keccak256(abi.encodePacked(i)));
            (publicKeysX[i], publicKeysY[i]) = getPublicKeyFromPrivateKey(
                privateKeys[i]
            );
            addresses[i] = _vm.addr(privateKeys[i]);
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
