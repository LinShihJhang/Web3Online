// SPDX-License-Identifier: MIT
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

        uint tokenId = avatar.mint(user1, "AppWorks", "B");
        //uint tokenId = avatar.mint(user1, "WWWWWWWWWWWWW", "B");
        assertEq(avatar.ownerOf(tokenId), user1);
        console2.log(avatar.getAttributeJson(tokenId));
        // console2.log(avatar.getAttributeFromBytes(avatar.getAttribute(tokenId)));
        console2.log(avatar.tokenURI(tokenId));

        vm.expectRevert("Avatar Error: Name is too long");
        avatar.mint(user1, "AppWorksAppWorksAppWorksAppWorksAppWorks", "B");

        vm.expectRevert("Avatar Error: Org is not in B, E, S, N");
        avatar.mint(user1, "AppWorks", "K");

        vm.stopPrank();
    }

}
