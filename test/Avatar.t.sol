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

    event Mint(address indexed to, uint indexed tokenId, string indexed name);
    event EditName(
        address indexed owner,
        uint indexed tokenId,
        string indexed name
    );
    event StartLevelUp(
        address indexed owner,
        uint indexed tokenId,
        uint indexed levelUpStartBlock
    );
    event OpenLevelUpResult(
        address indexed owner,
        uint indexed tokenId,
        uint indexed level,
        uint HP,
        uint MP,
        uint STR,
        uint DEF,
        uint DEX,
        uint LUK
    );

    event OpenLevelUpResultOver256(
        address indexed owner,
        uint indexed tokenId,
        uint indexed level,
        uint HP,
        uint MP,
        uint STR,
        uint DEF,
        uint DEX,
        uint LUK
    );

    function setUp() public {
        // fork block
        vm.createSelectFork(vm.envString("MAIN_RPC"));
        console2.log(block.number);
        vm.rollFork(block.number - 500000);
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
        //console2.log(block.number);
        vm.rollFork(block.number + 1);
        //console2.log(block.number);

        vm.stopPrank();

        return tokenId;
    }

    function testMint() public {
        vm.startPrank(user1);

        vm.expectEmit(true, true, true, true);
        emit Mint(user1, 1, "WMWMWMWMWMWMWMWMWMWM");
        uint tokenId = avatar.mint(user1, "WMWMWMWMWMWMWMWMWMWM", "B");
        assertEq(avatar.ownerOf(tokenId), user1);
        console2.log(avatar.getAttributeJson(tokenId));
        vm.rollFork(block.number + 1);

        vm.expectRevert("Avatar Error: Name is too long");
        avatar.mint(user1, "AppWorksAppWorksAppWorksAppWorksAppWorks", "B");

        vm.expectRevert("Avatar Error: Org is not in B, E, S, N");
        avatar.mint(user1, "AppWorks", "K");

        avatar.mint(user1, "AppWorks", "B");
        vm.expectRevert("Avatar Error: You have already minted in this block.");
        avatar.mint(user1, "AppWorks2", "B");

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

        vm.expectEmit(true, true, true, true);
        emit EditName(user1, tokenId, "AppWorks2");
        avatar.editName(tokenId, "AppWorks2");
        attribute = abi.decode(avatar.getAttributeBytes(tokenId), (Attribute));
        assertEq(attribute.NAME, "AppWorks2");

        vm.expectRevert("Avatar Error: Name is too long");
        avatar.editName(tokenId, "AppWorksAppWorksAppWorksAppWorksAppWorks");

        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("Avatar Error: You are not owner !");
        avatar.editName(tokenId, "AppWorks2");
        vm.stopPrank();
    }

    function testLevelUp() public {
        vm.startPrank(user1);
        uint tokenId = avatar.mint(user1, "LevelUpTester", "B");
        assertEq(avatar.ownerOf(tokenId), user1);
        console2.log(avatar.getAttributeJson(tokenId));

        //normal level up
        for (uint i = 0; i < 10; i++) {
            vm.expectEmit(true, true, true, true);
            emit StartLevelUp(user1, tokenId, block.number);
            avatar.startLevelUp(tokenId);
            vm.rollFork(block.number + 87);

            Attribute memory attribute = abi.decode(
                avatar.getAttributeBytes(tokenId),
                (Attribute)
            );
            vm.expectEmit(true, true, true, false);
            emit OpenLevelUpResult(
                user1,
                tokenId,
                attribute.LV + 1,
                attribute.HP,
                attribute.MP,
                attribute.STR,
                attribute.DEF,
                attribute.DEX,
                attribute.LUK
            );
            avatar.openLevelUpResult(tokenId);
            console2.log(avatar.getAttributeJson(tokenId));
        }

        //Status is not 2 level-up waiting
        vm.expectRevert("Avatar Error: Status is not level-up waiting");
        vm.rollFork(block.number + 87);
        avatar.openLevelUpResult(tokenId);

        //LevelUpWaitingBlock is not over
        vm.expectEmit(true, true, true, true);
        emit StartLevelUp(user1, tokenId, block.number);
        avatar.startLevelUp(tokenId);
        vm.rollFork(block.number + 8);
        vm.expectRevert("Avatar Error: LevelUpWaitingBlock is not over");
        avatar.openLevelUpResult(tokenId);

        vm.rollFork(block.number + 888);
        Attribute memory attribute2 = abi.decode(
            avatar.getAttributeBytes(tokenId),
            (Attribute)
        );
        vm.expectEmit(true, true, true, false);
        emit OpenLevelUpResultOver256(
            user1,
            tokenId,
            attribute2.LV + 1,
            attribute2.HP,
            attribute2.MP,
            attribute2.STR,
            attribute2.DEF,
            attribute2.DEX,
            attribute2.LUK
        );
        avatar.openLevelUpResult(tokenId);

        vm.stopPrank();
    }
}
