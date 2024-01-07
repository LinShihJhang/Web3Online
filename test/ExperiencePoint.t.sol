// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Avatar} from "../src/Avatar.sol";
import {ExperiencePoint} from "../src/ExperiencePoint.sol";
import "../src/Web3OnlineStorage.sol";

contract ExperiencePointTest is Test, Web3OnlineStorage {
    event StartMinting(
        address indexed owner,
        uint indexed tokenId,
        uint indexed mintStartBlock
    );

    event Mint(
        address indexed owner,
        uint indexed tokenId,
        uint indexed amount
    );

    event MintingOver256(
        address indexed owner,
        uint indexed tokenId,
        uint indexed amount
    );

    Avatar public avatar;
    ExperiencePoint public experiencePoint;

    address admin = makeAddr("Admin");
    address user1 = makeAddr("User1");
    address user2 = makeAddr("User2");

    function setUp() public {
        // fork block
        vm.createSelectFork(vm.envString("MAIN_RPC"));
        console2.log(block.number);
        vm.rollFork(block.number - 700000);
        console2.log(block.number);

        vm.startPrank(admin);
        avatar = new Avatar();
        experiencePoint = new ExperiencePoint(address(avatar), 7200);
        avatar.updateStatusWhiteList(address(experiencePoint), mintingStatus);
        assertEq(experiencePoint.getAvatarAddress(), address(avatar));
        assertEq(experiencePoint.getMintPeriod(), 7200);
        
        vm.label(address(avatar), "Avatar");
        vm.label(address(experiencePoint), "WOXP");
        vm.stopPrank();
    }

    function mint() public returns (uint) {
        vm.startPrank(user1);

        uint tokenId = avatar.mint(user1, "AppWorks", "B");
        assertEq(avatar.ownerOf(tokenId), user1);
        console2.log(avatar.getAttributeJson(tokenId));
        // vm.rollFork(block.number + 1);

        vm.stopPrank();

        return tokenId;
    }

    function testMinting() public {

        uint tokenId = mint();
        vm.startPrank(user1);
        experiencePoint.startMinting(tokenId);
        console2.log(avatar.getAttributeJson(tokenId));
        vm.rollFork(block.number + 87);
        experiencePoint.mint(tokenId);
        console2.log(avatar.getAttributeJson(tokenId));
        console2.log(experiencePoint.balanceOf(user1));
        vm.stopPrank();
        
        

        vm.startPrank(user1);

        // for (uint i = 0; i < 10; i++) {
        //     vm.rollFork(block.number + 7201);
        //     // vm.expectEmit(true, true, true, true);
        //     // emit StartMinting(user1, tokenId, block.number);
        //     console2.log(avatar.getStatusWhiteList(address(experiencePoint)));
        //     experiencePoint.startMinting(tokenId);
        //     // vm.rollFork(block.number + 87);

        //     // vm.expectEmit(true, true, false, false);
        //     // emit Mint(user1, tokenId, 0);
        //     // experiencePoint.mint(tokenId);
        //     // console2.log(experiencePoint.balanceOf(user1));
        // }

        // //Status is not leveling up
        // vm.expectRevert("Avatar Error: Status is not leveling up");
        // vm.rollFork(block.number + 87);
        // avatar.openLevelUpResult(tokenId);

        // //LevelUpWaitingBlock is not over
        // vm.expectEmit(true, true, true, true);
        // emit StartLevelUp(user1, tokenId, block.number);
        // avatar.startLevelUp(tokenId);
        // vm.rollFork(block.number + 8);
        // vm.expectRevert("Avatar Error: LevelUpWaitingBlock is not over");
        // avatar.openLevelUpResult(tokenId);

        // vm.rollFork(block.number + 888);
        // Attribute memory attribute2 = abi.decode(
        //     avatar.getAttributeBytes(tokenId),
        //     (Attribute)
        // );
        // vm.expectEmit(true, true, true, false);
        // emit OpenLevelUpResultOver256(
        //     user1,
        //     tokenId,
        //     attribute2.LV + 1,
        //     attribute2.HP,
        //     attribute2.MP,
        //     attribute2.STR,
        //     attribute2.DEF,
        //     attribute2.DEX,
        //     attribute2.LUK
        // );
        // avatar.openLevelUpResult(tokenId);

        vm.stopPrank();
    }
}
