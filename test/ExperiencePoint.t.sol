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
        avatar.changeExperiencePointAddress(address(experiencePoint));
        avatar.updateStatusWhiteList(address(experiencePoint), mintingStatus);
        assertEq(avatar.getExperiencePointAddress(), address(experiencePoint));
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

        //normal minting
        for (uint i = 0; i < 1; i++) {
            vm.expectEmit(true, true, true, true);
            emit StartMinting(user1, tokenId, block.number);
            experiencePoint.startMinting(tokenId);
            console2.log(avatar.getAttributeJson(tokenId));
            vm.rollFork(block.number + 87);
            vm.expectEmit(true, true, false, false);
            emit Mint(user1, tokenId, 0);
            console2.log(experiencePoint.mint(tokenId));
            console2.log(experiencePoint.balanceOf(user1));
            console2.log(avatar.getAttributeJson(tokenId));
            vm.rollFork(block.number + 7201);
        }

        for (uint i = 0; i < 4; i++) {
            avatar.startLevelUp(tokenId);
            vm.rollFork(block.number + 87);
            avatar.openLevelUpResult(tokenId);
        }
        console2.log(avatar.getAttributeJson(tokenId));

        for (uint i = 0; i < 3; i++) {
            vm.expectEmit(true, true, true, true);
            emit StartMinting(user1, tokenId, block.number);
            experiencePoint.startMinting(tokenId);
            vm.rollFork(block.number + 87);
            vm.expectEmit(true, true, false, false);
            emit Mint(user1, tokenId, 0);
            console2.log(experiencePoint.mint(tokenId));
            console2.log(experiencePoint.balanceOf(user1));
            console2.log(avatar.getAttributeJson(tokenId));
            vm.rollFork(block.number + 7201);
        }

        vm.rollFork(block.number - 7000);
        vm.expectRevert(
            "Avatar ExperiencePoint Error: Every MintPeriod blocks can be minted only once."
        );
        experiencePoint.startMinting(tokenId);

        vm.rollFork(block.number + 7000);
        experiencePoint.startMinting(tokenId);
        vm.expectRevert(
            "Avatar ExperiencePoint Error: MintWaitingBlock is not over"
        );
        experiencePoint.mint(tokenId);

        vm.rollFork(block.number + 7201);

        vm.expectRevert(
            "Avatar ExperiencePoint Error: Avatar status is not idle"
        );
        experiencePoint.startMinting(tokenId);

        vm.expectEmit(true, true, true, true);
        emit MintingOver256(user1, tokenId, 0);
        experiencePoint.mint(tokenId);

        experiencePoint.startMinting(tokenId);
        vm.rollFork(block.number + 87);
        vm.stopPrank();
        vm.startPrank(address(experiencePoint));
        avatar.setAvatarStatus(tokenId, idleStatus);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert(
            "Avatar ExperiencePoint Error: Status is not mintingStatus"
        );
        experiencePoint.mint(tokenId);
        vm.stopPrank();
    }
}
