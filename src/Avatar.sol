// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./StringUtils.sol";
import "./Web3OnlineStorage.sol";

contract Avatar is
    ERC721Enumerable,
    Web3OnlineStorage,
    Ownable,
    ReentrancyGuard
{
    using StringUtils for *;

    mapping(uint => Attribute) public attributes;
    mapping(string => bool) public orgs;
    mapping(uint => uint) public levelUpStartBlocks;
    uint public NameMaxLength = 20;
    uint public LevelUpWaitingBlock = 3600; //12h

    constructor() ERC721("Web3Online Avatar", "WOAV") Ownable(msg.sender) {
        // Initialize orgs
        orgs["B"] = true;
        orgs["E"] = true;
        orgs["S"] = true;
        orgs["N"] = true;
    }

    modifier checkAvatarOwner(uint tokenId) {
        require(
            ownerOf(tokenId) == msg.sender,
            "Avatar Error: Only Owner can edit name"
        );
        _;
    }

    function mint(
        address to,
        string calldata name,
        string calldata org
    ) public returns (uint) {
        require(checkNameStringLength(name), "Avatar Error: Name is too long");
        require(checkOrg(org), "Avatar Error: Org is not in B, E, S, N");

        uint tokenId = totalSupply() + 1;
        _mint(to, tokenId);
        attributes[tokenId] = Attribute({
            NAME: name,
            ORG: org,
            LV: 1,
            HP: 10,
            MP: 10,
            STR: 1,
            DEF: 1,
            DEX: 1,
            LUK: 1,
            STATUS: 1
        });

        return tokenId;
    }

    function editName(
        uint tokenId,
        string calldata name
    ) public checkAvatarOwner(tokenId) {
        require(checkNameStringLength(name), "Avatar Error: Name is too long");
        Attribute storage attribute = attributes[tokenId];
        attribute.NAME = name;
    }

    function startLevelUp(uint tokenId) public checkAvatarOwner(tokenId) {
        Attribute storage attribute = attributes[tokenId];
        require(attribute.STATUS == 1, "Avatar Error: Status is not idle");
        attribute.STATUS = 2;

        //burn token
        //require

        levelUpStartBlocks[tokenId] = block.number;
    }

    function openLevelUpResult(uint tokenId) public checkAvatarOwner(tokenId) {
        uint levelUpStartBlock = levelUpStartBlocks[tokenId];
        require(
            block.number > levelUpStartBlock + LevelUpWaitingBlock,
            "Avatar Error: LevelUpWaitingBlock is not over"
        );

        Attribute storage attribute = attributes[tokenId];
        uint memory LV = attribute.LV;
        uint memory HP = attribute.HP;
        uint memory MP = attribute.MP;
        uint memory STR = attribute.STR;
        uint memory DEF = attribute.DEF;
        uint memory DEX = attribute.DEX;
        uint memory LUK = attribute.LUK;

        require(
            attribute.STATUS == 2,
            "Avatar Error: Status is not level-up waiting"
        );
        attribute.STATUS = 1;

        attribute.LV = LV + 1;

        uint halfLevelUpWaitingBlock = LevelUpWaitingBlock / 2;
        uint pushForwardBlock = getBlockHashUint(levelUpStartBlock + halfLevelUpWaitingBlock) % halfLevelUpWaitingBlock;
        uint randomBlockNumber = levelUpStartBlock + pushForwardBlock;

        //HP
        if(getBlockHashUint(randomBlockNumber) % LV =< (LV-HP+9)){
            attribute.HP = HP + 1;
        }
        uint randomBlockNumber += HP;
        //MP
        if(getBlockHashUint(randomBlockNumber) % LV =< (LV-MP+9)){
            attribute.MP = MP + 1;
        }
        uint randomBlockNumber += MP;
        //STR
        if(getBlockHashUint(randomBlockNumber) % LV =< (LV-STR)){
            attribute.STR = STR + 1;
        }
        uint randomBlockNumber += STR;
        //DEF
        if(getBlockHashUint(randomBlockNumber) % LV =< (LV-DEF)){
            attribute.DEF = DEF + 1;
        }
        uint randomBlockNumber += DEF;
        //DEX
        if(getBlockHashUint(randomBlockNumber) % LV =< (LV-DEX)){
            attribute.DEX = DEX + 1;
        }
        uint randomBlockNumber += DEX;
        //LUK
        if(getBlockHashUint(randomBlockNumber) % LV =< (LV-LUK)){
            attribute.LUK = LUK + 1;
        }
    }

    function checkNameStringLength(
        string calldata name
    ) public view returns (bool) {
        return name.strlen() <= NameMaxLength;
    }

    function checkOrg(string calldata org) public view returns (bool) {
        return orgs[org];
    }

    function changeNameMaxLength(uint maxLength) public onlyOwner {
        NameMaxLength = maxLength;
    }

    function changeLevelUpWaitingBlock(uint waitingBlock) public onlyOwner {
        LevelUpWaitingBlock = waitingBlock;
    }

    function getBlockHashUint(uint blocknumber) external view returns (uint) {
        return uint(blockhash(blocknumber));
    }

    function getAttributeBytes(
        uint tokenId
    ) public view returns (bytes memory) {
        return abi.encode(attributes[tokenId]);
    }

    // function getAttributeFromBytes(
    //     bytes calldata data
    // ) public pure returns (uint) {
    //     Attribute memory attribute = abi.decode(data, (Attribute));
    //     return attribute.HP;
    // }

    //getAtrribute
    function getAttributeJson(
        uint tokenId
    ) public view returns (string memory) {
        Attribute memory attribute = attributes[tokenId];

        string memory front = string.concat(
            '{"TOKENID":',
            Strings.toString(tokenId),
            ',"NAME":"',
            attribute.NAME,
            '","ORG":"',
            attribute.ORG,
            '","LV":',
            Strings.toString(attribute.LV),
            ',"HP":',
            Strings.toString(attribute.HP)
        );

        string memory backend = string.concat(
            ',"MP":',
            Strings.toString(attribute.MP),
            ',"STR":',
            Strings.toString(attribute.STR),
            ',"DEF":',
            Strings.toString(attribute.DEF),
            ',"DEX":',
            Strings.toString(attribute.DEX),
            ',"LUK":',
            Strings.toString(attribute.LUK),
            ',"STATUS":',
            Strings.toString(attribute.STATUS),
            "}"
        );

        return string.concat(front, backend);
    }

    // metadata
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        Attribute memory attribute = attributes[tokenId];
        uint textXPosition;
        uint curlyBracketsXPosition;

        if (attribute.NAME.strlen() > 13) {
            curlyBracketsXPosition = 10;
            textXPosition = 20;
        } else {
            curlyBracketsXPosition = 80;
            textXPosition = 110;
        }
        bytes memory data;

        data = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"> <style>.base { fill: green; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="',
            bytes(Strings.toString(curlyBracketsXPosition)),
            '" y="25" class="base">{</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="50" class="base">"TOKENID": ',
            bytes(Strings.toString(tokenId)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="75" class="base">"NAME": "',
            bytes(attribute.NAME)
        );
        data = abi.encodePacked(
            data,
            '",</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="100" class="base">"ORG": "',
            bytes(attribute.ORG),
            '",</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="125" class="base">"LV": ',
            bytes(Strings.toString(attribute.LV))
        );
        data = abi.encodePacked(
            data,
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="150" class="base">"HP": ',
            bytes(Strings.toString(attribute.HP)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="175" class="base">"MP": ',
            bytes(Strings.toString(attribute.MP))
        );
        data = abi.encodePacked(
            data,
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="200" class="base">"STR": ',
            bytes(Strings.toString(attribute.STR)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="225" class="base">"DEF": ',
            bytes(Strings.toString(attribute.DEF))
        );
        data = abi.encodePacked(
            data,
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="250" class="base">"DEX": ',
            bytes(Strings.toString(attribute.DEX)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="275" class="base">"LUK": ',
            bytes(Strings.toString(attribute.LUK)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="300" class="base">"STATUS": ',
            bytes(Strings.toString(attribute.STATUS)),
            '</text><text x="',
            bytes(Strings.toString(curlyBracketsXPosition)),
            '" y="325" class="base">}</text></svg>'
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"description": "Web3 Online Avatar", "image": "data:image/svg+xml;base64,',
                        Base64.encode(data),
                        '", "name": "',
                        bytes(Strings.toString(tokenId)),
                        "-",
                        bytes(attribute.NAME),
                        '"}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
        //return Base64.encode(data);
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        _update(address(0), tokenId, _msgSender());
    }
}
