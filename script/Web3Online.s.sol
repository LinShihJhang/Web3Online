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

        uint tokenId = avatar.mint(0x7502D29B7ebEBb410d42FB8e4ff62CEd6CFC24d4, "AppWorks", "B");
        console2.log(avatar.getAttributeJson(tokenId));
        console2.log(avatar.ownerOf(tokenId));
        console2.log(address(this));
        avatar.startLevelUp(tokenId);

        uint tokenId2 = avatar.mint(0x7502D29B7ebEBb410d42FB8e4ff62CEd6CFC24d4, "WMWMWMWMWMWMWMWMWMWM", "B");
        console2.log(avatar.getAttributeJson(tokenId2));
        avatar.startLevelUp(tokenId2);

        vm.stopBroadcast();
    }
}

contract StartLevelUpScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Avatar avatar = Avatar(0x71373cE70f9C0c7a3a096E3c78CA02e1Ff26A22d);

        avatar.startLevelUp(1);
        avatar.startLevelUp(2);

        vm.stopBroadcast();
    }
}


contract OpenLevelUpResultScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Avatar avatar = Avatar(0x71373cE70f9C0c7a3a096E3c78CA02e1Ff26A22d);

        avatar.openLevelUpResult(1);
        avatar.openLevelUpResult(2);

        vm.stopBroadcast();
    }
}
