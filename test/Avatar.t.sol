// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Avatar} from "../src/Avatar.sol";

contract AvatarrTest is Test {
    Avatar public avatar;

    address admin = makeAddr("Admin");
    address user1 = makeAddr("User1");
    address user2 = makeAddr("User2");
    address user3 = makeAddr("User3");

    function setUp() public {
        vm.startPrank(admin);
        avatar = new Avatar();
        vm.label(address(avatar), "Avatar");
        vm.stopPrank();

    }

    function testMint() public {
        vm.startPrank(user1);
        avatar.mint(user1, 1);
        vm.stopPrank();
    }

}
