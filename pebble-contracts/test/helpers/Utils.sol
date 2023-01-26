// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

library UtilsTest {
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
}
