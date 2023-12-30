// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract Enum { 

    enum AttributeIndex {
        LV, //Level 等級
        HP, //Health Point 血量 
        STR, //Strength 力量 攻擊
        DEX, //Dexterity 敏捷 閃避
        LUK //Luck 幸運 爆擊
    }

    mapping(uint => mapping(uint => uint16)) private attribute;
    mapping(uint => mapping(AttributeIndex => uint16)) private attribute2;

    function mint(uint id) public {
        attribute[id][uint(AttributeIndex.LV)] = 1;
        attribute[id][uint(AttributeIndex.HP)] = 10;
        attribute[id][uint(AttributeIndex.STR)] = 1;
        attribute[id][uint(AttributeIndex.DEX)] = 1;
        attribute[id][uint(AttributeIndex.LUK)] = 1;
    }

    function mint2(uint id) public {
        attribute2[id][AttributeIndex.LV] = 1;
        attribute2[id][AttributeIndex.HP] = 10;
        attribute2[id][AttributeIndex.STR] = 1;
        attribute2[id][AttributeIndex.DEX] = 1;
        attribute2[id][AttributeIndex.LUK] = 1;
    }

    function mint3(uint id) public {
        attribute[id][0] = 1;
        attribute[id][1] = 10;
        attribute[id][2] = 1;
        attribute[id][3] = 1;
        attribute[id][4] = 1;
    }

    function getEnum() public pure  returns (uint){
        return uint(AttributeIndex.DEX);
    }
    
}