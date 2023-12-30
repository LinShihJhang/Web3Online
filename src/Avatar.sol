// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtils.sol";

contract Avatar is Ownable {
    using StringUtils for *;

    struct Attribute {
        string text;
        bool completed;
        string NAME;
        uint LV; //Level 等級
        uint HP; //Health Point 血量
        uint MP; //Magic Point 魔力值
        uint STR; //Strength 力量 攻擊
        uint DEF; //Defense：物理防禦力
        uint DEX; //Dexterity 敏捷 閃避
        uint LUK; //Luck 幸運 爆擊
    }

    mapping(uint => Attribute) public attributes;

    uint public NameMaxLength = 20;

    constructor() Ownable(msg.sender) {}

    function checkNameStringLength(
        string calldata text
    ) public pure returns (bool) {
        return text.strlen() <= NameMaxLength;
    }
    
    //change NameMaxLength
    function changeNameMaxLength(uint maxLength) public onlyOwner{
        NameMaxLength = maxLength;
    }
}
