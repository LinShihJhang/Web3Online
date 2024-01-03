// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/Avatar.sol";

contract Web3OnlineScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Avatar avatar = new Avatar();
        
        uint tokenId = avatar.mint(address(this), "AppWorks", "B");
        console2.log(avatar.getAttributeJson(tokenId));

        vm.stopBroadcast();
    }
}
