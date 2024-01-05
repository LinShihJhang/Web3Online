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
        // fork block
        vm.createSelectFork(vm.envString("MAIN_RPC"));
        console2.log(block.number);
        vm.rollFork(block.number -50000);
        // console2.log(uint(blockhash(block.number-255)));
        // console2.log(uint(blockhash(block.number-256)));
        // console2.log(uint(blockhash(block.number-257))); //0
        console2.log(block.number);

        vm.startPrank(admin);
        avatar = new Avatar();
        vm.label(address(avatar), "Avatar");
        vm.stopPrank();
    }

    function mint() public returns (uint) {
        vm.startPrank(user1);

        uint tokenId = avatar.mint(user1, "AppWorks", "B");
        assertEq(avatar.ownerOf(tokenId), user1);
        console2.log(avatar.getAttributeJson(tokenId));

        vm.stopPrank();

        return tokenId;
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
        uint tokenId = mint();
        vm.startPrank(user1);
        Attribute memory attribute = abi.decode(
            avatar.getAttributeBytes(tokenId),
            (Attribute)
        );
        assertEq(attribute.NAME, "AppWorks");

        avatar.editName(tokenId, "AppWorks2");
        attribute = abi.decode(avatar.getAttributeBytes(tokenId), (Attribute));
        assertEq(attribute.NAME, "AppWorks2");

        vm.expectRevert("Avatar Error: Name is too long");
        avatar.editName(tokenId, "AppWorksAppWorksAppWorksAppWorksAppWorks");
        
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("Avatar Error: Only Owner can edit name");
        avatar.editName(tokenId, "AppWorks2");
        vm.stopPrank();
    }

    function testLevelUp() public {
        vm.startPrank(user1);

        uint tokenId = avatar.mint(user1, "LevelUpTester", "B");
        assertEq(avatar.ownerOf(tokenId), user1);
        console2.log(avatar.getAttributeJson(tokenId));

        for (uint i = 0; i < 50; i++) {
            avatar.startLevelUp(tokenId);
            vm.rollFork(block.number + 87);
            avatar.openLevelUpResult(tokenId);
            console2.log(avatar.getAttributeJson(tokenId));
        }

        vm.stopPrank();
    }
}
