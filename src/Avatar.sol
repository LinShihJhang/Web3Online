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

    // struct Attribute {
    //     string NAME;
    //     string ORG; //Organization 組織
    //     uint LV; //Level 等級
    //     uint HP; //Health Point 血量
    //     uint MP; //Magic Point 魔力值
    //     uint STR; //Strength 力量 攻擊
    //     uint DEF; //Defense：物理防禦力
    //     uint DEX; //Dexterity 敏捷 閃避
    //     uint LUK; //Luck 幸運 爆擊
    // }

    mapping(uint => Attribute) private attributes;
    mapping(uint => uint) private avatarStatus;

    mapping(string => bool) private orgs;

    uint public NameMaxLength = 20;

    constructor() ERC721("Web3Online Avatar", "WOAV") Ownable(msg.sender) {
        // Initialize orgs
        orgs["B"] = true;
        orgs["E"] = true;
        orgs["S"] = true;
        orgs["N"] = true;
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
            MP: 11,
            STR: 2,
            DEF: 3,
            DEX: 4,
            LUK: 5
        });

        return tokenId;
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

    function getAttribute(uint tokenId) public view returns (bytes memory) {
        return abi.encode(attributes[tokenId]);
    }

    function getAttributeFromBytes(
        bytes calldata data
    ) public pure returns (uint) {
        Attribute memory attribute = abi.decode(data, (Attribute));
        return attribute.HP;
    }

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
            curlyBracketsXPosition=10;
            textXPosition = 20;
        }else{
            curlyBracketsXPosition=80;
            textXPosition = 110;
        }
        bytes memory data;

        data = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"> <style>.base { fill: green; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="',
            bytes(Strings.toString(curlyBracketsXPosition)),
            '" y="50" class="base">{</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="75" class="base">"TOKENID": ',
            bytes(Strings.toString(tokenId)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="100" class="base">"NAME": "',
            bytes(attribute.NAME)
        );
        data = abi.encodePacked(
            data,
            '",</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="125" class="base">"ORG": "',
            bytes(attribute.ORG),
            '",</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="150" class="base">"LV": ',
            bytes(Strings.toString(attribute.LV))
        );
        data = abi.encodePacked(
            data,
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="175" class="base">"HP": ',
            bytes(Strings.toString(attribute.HP)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="200" class="base">"MP": ',
            bytes(Strings.toString(attribute.MP))
        );
        data = abi.encodePacked(
            data,
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="225" class="base">"STR": ',
            bytes(Strings.toString(attribute.STR)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="250" class="base">"DEF": ',
            bytes(Strings.toString(attribute.DEF))
        );
        data = abi.encodePacked(
            data,
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="275" class="base">"DEX": ',
            bytes(Strings.toString(attribute.DEX)),
            ',</text><text x="',
            bytes(Strings.toString(textXPosition)),
            '" y="300" class="base">"LUK": ',
            bytes(Strings.toString(attribute.LUK)),
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
