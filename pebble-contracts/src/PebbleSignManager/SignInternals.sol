// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

contract SignInternals {
    // Constants
    uint256 constant VERSION_SLOT = uint256(keccak256("PEBBLE:VERSION_SLOT"));

    // Internals

    /**
    @dev Gets contract version, at correct slot
    @return version Contract version
     */
    function _getVersion() internal pure returns (string storage version) {
        uint256 slotNum = VERSION_SLOT;
        assembly {
            version.slot := slotNum
        }
    }

    /**
    @dev Changes contract version, at correct slot
    @param _versionNew New version to store
     */
    function _setVersion(string memory _versionNew) internal {
        uint256 slotNum = VERSION_SLOT;
        assembly {
            sstore(
                slotNum,
                or(mload(add(_versionNew, 0x20)), mul(2, mload(_versionNew)))
            )
        }
    }
}
