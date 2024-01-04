// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Avatar} from "../src/Avatar.sol";
import "../src/Web3OnlineStorage.sol";

contract AvatarrTest is Test, Web3OnlineStorage {
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
        
        mint();

    }

    function mint() public {
        vm.startPrank(user1);

        uint tokenId2 = avatar.mint(user1, "AppWorks", "B");
        assertEq(avatar.ownerOf(tokenId2), user1);
        console2.log(avatar.getAttributeJson(tokenId2));

        vm.stopPrank();
    }

    function testMint() public {
        vm.startPrank(user1);

        uint tokenId = avatar.mint(user1, "WMWMWMWMWMWMWMWMWMWM", "B");
        assertEq(avatar.ownerOf(tokenId), user1);
        console2.log(avatar.getAttributeJson(tokenId));

        vm.expectRevert("Avatar Error: Name is too long");
        avatar.mint(user1, "AppWorksAppWorksAppWorksAppWorksAppWorks", "B");

        vm.expectRevert("Avatar Error: Org is not in B, E, S, N");
        avatar.mint(user1, "AppWorks", "K");

        vm.stopPrank();
    }

    function testEditName() public {
        vm.startPrank(user1);

        Attribute memory attribute = abi.decode(avatar.getAttributeBytes(1), (Attribute));
        assertEq(attribute.NAME, "AppWorks");

        avatar.editName(1, "AppWorks2");

        attribute = abi.decode(avatar.getAttributeBytes(1), (Attribute));
        assertEq(attribute.NAME, "AppWorks2");

        vm.expectRevert("Avatar Error: Name is too long");
        avatar.editName(1, "AppWorksAppWorksAppWorksAppWorksAppWorks");
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("Avatar Error: Only Owner can edit name");
        avatar.editName(1, "AppWorks2");
        vm.stopPrank();
    }

}
