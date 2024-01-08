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
import "./ExperiencePoint.sol";

contract Avatar is
    ERC721Enumerable,
    Web3OnlineStorage,
    Ownable,
    ReentrancyGuard
{
    using StringUtils for *;

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

    uint public constant LevelUpWaitingBlock = 86;
    uint public NameMaxLength = 20;
    address public ExperiencePointAddress;
    mapping(uint => Attribute) public attributes;
    mapping(string => bool) public orgs;
    mapping(uint => uint) public levelUpStartBlocks;
    mapping(address => uint) public lastMintedBlock;
    mapping(address => uint) public statusWhiteList;

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
            "Avatar Error: You are not owner !"
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
        require(
            lastMintedBlock[msg.sender] != block.number,
            "Avatar Error: You have already minted in this block."
        );

        lastMintedBlock[msg.sender] = block.number;

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

        emit Mint(to, tokenId, name);
        return tokenId;
    }

    function editName(
        uint tokenId,
        string calldata name
    ) public checkAvatarOwner(tokenId) {
        require(checkNameStringLength(name), "Avatar Error: Name is too long");
        Attribute storage attribute = attributes[tokenId];
        attribute.NAME = name;

        emit EditName(msg.sender, tokenId, name);
    }

    /*
    //After executing the 'startLevelUp' function
    //You need to finish the 'openLevelUpResult' function after 86 blocks and before 256 blocks.
    */
    function startLevelUp(uint tokenId) public checkAvatarOwner(tokenId) {
        Attribute storage attribute = attributes[tokenId];
        require(attribute.STATUS == 1, "Avatar Error: Status is not idle");
        attribute.STATUS = 2;

        uint LV = attribute.LV;

        ExperiencePoint(ExperiencePointAddress).transferFrom(
            msg.sender,
            address(this),
            LV * 3 * 10e18
        );
        ExperiencePoint(ExperiencePointAddress).burn(
            (LV * 3 * 10e18 * 999) / 1000
        );

        levelUpStartBlocks[tokenId] = block.number;

        emit StartLevelUp(msg.sender, tokenId, block.number);
    }

    function openLevelUpResult(uint tokenId) public checkAvatarOwner(tokenId) {
        // uint LevelUpWaitingBlock = 86;
        uint levelUpStartBlock = levelUpStartBlocks[tokenId];
        require(
            block.number > levelUpStartBlock + LevelUpWaitingBlock,
            "Avatar Error: LevelUpWaitingBlock is not over"
        );

        Attribute storage attribute = attributes[tokenId];
        uint LV = attribute.LV;
        uint HP = attribute.HP;
        uint MP = attribute.MP;
        uint STR = attribute.STR;
        uint DEF = attribute.DEF;
        uint DEX = attribute.DEX;
        uint LUK = attribute.LUK;

        require(
            attribute.STATUS == 2,
            "Avatar Error: Status is not leveling up"
        );
        attribute.STATUS = 1;

        //level-up
        LV = LV + 1;
        attribute.LV = LV;

        //check over 256 blocks
        if (
            uint(blockhash(levelUpStartBlock)) == 0 &&
            uint(blockhash(levelUpStartBlock - 1)) == 0 &&
            uint(blockhash(levelUpStartBlock - 2)) == 0
        ) {
            emit OpenLevelUpResultOver256(
                msg.sender,
                tokenId,
                LV,
                HP,
                MP,
                STR,
                DEF,
                DEX,
                LUK
            );
        } else {
            uint pushForwardBlock = (getBlockHashUint(
                levelUpStartBlock + LevelUpWaitingBlock / 2
            ) + tokenId) % (LevelUpWaitingBlock / 2);
            uint randomBlockNumber = levelUpStartBlock + pushForwardBlock;

            //HP
            uint threshold = LV > 30
                ? 10 + LV - HP + (LV / uint(10))
                : 10 + LV - HP;
            if (
                (getBlockHashUint(randomBlockNumber) + tokenId) % LV <=
                threshold
            ) {
                HP = HP + 1;
                attribute.HP = HP;
            }
            randomBlockNumber = randomBlockNumber + ((HP % 7) + 1);
            //MP
            threshold = LV > 30 ? 10 + LV - MP + (LV / uint(10)) : 10 + LV - MP;
            if (
                (getBlockHashUint(randomBlockNumber) + tokenId) % LV <=
                threshold
            ) {
                MP = MP + 1;
                attribute.MP = MP;
            }
            randomBlockNumber = randomBlockNumber + ((MP % 7) + 1);
            //STR
            threshold = LV > 30 ? LV - STR + (LV / uint(10)) : LV - STR;
            if (
                (getBlockHashUint(randomBlockNumber) + tokenId) % LV <=
                threshold
            ) {
                STR = STR + 1;
                attribute.STR = STR;
            }
            randomBlockNumber = randomBlockNumber + ((STR % 7) + 1);
            //DEF
            threshold = LV > 30 ? LV - DEF + (LV / uint(10)) : LV - DEF;
            if (
                (getBlockHashUint(randomBlockNumber) + tokenId) % LV <=
                threshold
            ) {
                DEF = DEF + 1;
                attribute.DEF = DEF;
            }
            randomBlockNumber = randomBlockNumber + ((DEF % 7) + 1);
            //DEX
            threshold = LV > 30 ? LV - DEX + (LV / uint(10)) : LV - DEX;
            if (
                (getBlockHashUint(randomBlockNumber) + tokenId) % LV <=
                threshold
            ) {
                DEX = DEX + 1;
                attribute.DEX = DEX;
            }
            randomBlockNumber = randomBlockNumber + ((DEX % 7) + 1);
            //LUK
            threshold = LV > 30 ? LV - LUK + (LV / uint(10)) : LV - LUK;
            if (
                (getBlockHashUint(randomBlockNumber) + tokenId) % LV <=
                threshold
            ) {
                LUK = LUK + 1;
                attribute.LUK = LUK;
            }
        }

        emit OpenLevelUpResult(
            msg.sender,
            tokenId,
            LV,
            HP,
            MP,
            STR,
            DEF,
            DEX,
            LUK
        );
    }

    function getAvatarStatus(uint tokenId) public view returns (uint) {
        return attributes[tokenId].STATUS;
    }

    function setAvatarStatus(uint tokenId, uint status) public {
        uint canSetStatus = statusWhiteList[msg.sender];
        require(canSetStatus > 0, "Avatar Error: Status is not in whitelist");
        require(
            status == canSetStatus || status == idleStatus,
            "Avatar Error: Can not set status"
        );

        Attribute storage attribute = attributes[tokenId];
        attribute.STATUS = status;
    }

    function checkNameStringLength(
        string calldata name
    ) public view returns (bool) {
        return name.strlen() <= NameMaxLength;
    }

    function checkOrg(string calldata org) public view returns (bool) {
        return orgs[org];
    }

    function getNameMaxLength() public view returns (uint) {
        return NameMaxLength;
    }

    function changeNameMaxLength(uint maxLength) public onlyOwner {
        NameMaxLength = maxLength;
    }

    function getExperiencePointAddress() public view returns (address) {
        return ExperiencePointAddress;
    }

    function changeExperiencePointAddress(
        address _experiencePointAddress
    ) public onlyOwner {
        ExperiencePointAddress = _experiencePointAddress;
    }

    function updateStatusWhiteList(
        address whiteListAddress,
        uint status
    ) public onlyOwner {
        statusWhiteList[whiteListAddress] = status;
    }

    function getStatusWhiteList(
        address whiteListAddress
    ) public view returns (uint) {
        return statusWhiteList[whiteListAddress];
    }

    function getBlockHashUint(uint blocknumber) internal view returns (uint) {
        return
            (uint(blockhash(blocknumber)) % 10e10) +
            (uint(blockhash(blocknumber + 1)) % 10e10) +
            (uint(blockhash(blocknumber + 2)) % 10e10) +
            (uint(blockhash(blocknumber + 3)) % 10e10) +
            (uint(blockhash(blocknumber + 4)) % 10e10);
    }

    function getAttributeBytes(
        uint tokenId
    ) public view returns (bytes memory) {
        return abi.encode(attributes[tokenId]);
    }

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
