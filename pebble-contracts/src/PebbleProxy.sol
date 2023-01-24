// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract PebbleProxy is ERC1967Proxy {
    // Constructor
    constructor(address _implementation) ERC1967Proxy(_implementation, "") {}

    /**
    @dev Returns address of Pebble implementation contract
    @return _implementation Implementation contract address
     */
    function getImplementation() external view returns (address) {
        return _implementation();
    }
}
