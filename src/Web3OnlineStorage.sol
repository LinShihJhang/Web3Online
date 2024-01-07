// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./StringUtils.sol";

contract Web3OnlineStorage {
    struct Attribute {
        string NAME;
        string ORG; //Organization 組織
        uint LV; //Level 等級
        uint HP; //Health Point 血量
        uint MP; //Magic Point 魔力值
        uint STR; //Strength 力量 攻擊
        uint DEF; //Defense：物理防禦力
        uint DEX; //Dexterity 敏捷 閃避
        uint LUK; //Luck 幸運 爆擊
        uint STATUS; //目前狀態 1:idle 2:leveling up 3:minting
    }

    uint public constant randomWaitingBlock = 86;
    uint public constant idleStatus = 1;
    uint public constant levelingUpStatus = 2;
    uint public constant mintingStatus = 3;

}