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

        uint tokenId = avatar.mint(vm.envAddress("USER_ADDRESS"), "AppWorks", "B");
        console2.log(avatar.getAttributeJson(tokenId));
        avatar.startLevelUp(tokenId);

        vm.stopBroadcast();
    }
}

contract MintScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Avatar avatar = Avatar(vm.envAddress("WEB3ONLINE_CONTRACT"));

        uint tokenId = avatar.mint(vm.envAddress("USER_ADDRESS"), "AppWorks", "B");
        console2.log(avatar.getAttributeJson(tokenId));
        avatar.startLevelUp(tokenId);

        vm.stopBroadcast();
    }
}


contract StartLevelUpScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Avatar avatar = Avatar(vm.envAddress("WEB3ONLINE_CONTRACT"));

        avatar.startLevelUp(vm.envUint("TOKEN_ID"));

        vm.stopBroadcast();
    }
}


contract OpenLevelUpResultScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Avatar avatar = Avatar(vm.envAddress("WEB3ONLINE_CONTRACT"));

        avatar.openLevelUpResult(vm.envUint("TOKEN_ID"));

        vm.stopBroadcast();
    }
}
