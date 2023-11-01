// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Script, console2} from "forge-std/Script.sol";
import "../src/SimpleNFT_OpenZeppelin.sol";

contract SimpleNFT_OpenZeppelinScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        SimpleNFT_OpenZeppelin simpleNFT_OpenZeppelin = new SimpleNFT_OpenZeppelin(
                "NFT_test",
                "NFTt"
            );

        vm.stopBroadcast();
    }
}
