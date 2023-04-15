// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "src/Pebble.sol";
import "src/PebbleProxy.sol";

/**
 RUN SCRIPT
 forge script ./script/Deploy.s.sol --broadcast --rpc-url mumbai --via-ir -vv --with-gas-price 100000000000 -g 110 --optimize --optimizer-runs 200 --build-info --build-info-path out/build_info --slow --force

 VERIFY
 1. Generate Standard JSON input files
 forge verify-contract PEBBLE_IMPLEMENTATION_ADDR ./src/Pebble.sol:Pebble POLYGONCAN_API_KEY --chain mumbai --optimizer-runs=200 --show-standard-json-input > out/build_info/Pebble.json

 forge verify-contract PEBBLE_PROXY_ADDR ./src/PebbleProxy.sol:Pebble POLYGONCAN_API_KEY --chain mumbai --optimizer-runs=200 --constructor-args "000000000000000000000000PEBBLE_IMPLEMENTATION_ADDR" --show-standard-json-input > out/build_info/PebbleProxy.json

 2. Manually add this after "optimizer" key:
 ```
 "viaIR":true
 ```

 3. Use Polygonscan to verify
 */

contract DeployPebble is Script {
    function run() public {
        // Start broadcast
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerPublicKey = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Pebble implementation
        Pebble pebbleImplementation = new Pebble();

        // Deploy Pebble proxy
        PebbleProxy pebbleProxy = new PebbleProxy(
            address(pebbleImplementation)
        );

        // Configure Pebble proxy
        address[] memory delegatees = new address[](0);
        address[] memory pebbleAdmins = new address[](1);
        pebbleAdmins[0] = deployerPublicKey;

        Pebble(address(pebbleProxy)).initialize(
            "1.0.0",
            pebbleAdmins,
            delegatees
        );

        // Stop broadcast
        vm.stopBroadcast();

        // Log results
        console.log("[+] CONTRACTS DEPLOYED");
        console.log(
            "> Pebble implementation: %s",
            address(pebbleImplementation)
        );
        console.log("> Pebble proxy: %s", address(pebbleProxy));
    }
}
