// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

library PebbleMath {
    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
}
