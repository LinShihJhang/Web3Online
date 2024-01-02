// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtils.sol";

contract Avatar is ERC721Enumerable, ERC721Pausable, Ownable, ERC721Burnable {
    using StringUtils for *;

    struct Attribute {
        string text;
        bool completed;
        string NAME;
        string ORG; //Organization 組織
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

    constructor()
        ERC721("Web3Online Avatar", "WOAV")
        Ownable(msg.sender)
    {}

    function checkNameStringLength(
        string calldata text
    ) public pure returns (bool) {
        return text.strlen() <= NameMaxLength;
    }
    
    function changeNameMaxLength(uint maxLength) public onlyOwner{
        NameMaxLength = maxLength;
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        _mint(to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
    //     unchecked {
    //         _balances[account] += value;
    //     }
    // }

    // The following functions are overrides required by Solidity.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}




