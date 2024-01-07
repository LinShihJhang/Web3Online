// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./Avatar.sol";
import "./Web3OnlineStorage.sol";

contract ExperiencePoint is ERC20, ERC20Permit, Web3OnlineStorage, Ownable {
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

    address public AvatarAddress;
    uint public MintPeriod;
    mapping(uint => uint) public mintStartBlocks;

    constructor(
        address _avatarAddress,
        uint _mintPeriod
    )
        ERC20("Web3Online Avatar Experience Point", "WOXP")
        ERC20Permit("Web3Online Avatar Experience Point")
        Ownable(msg.sender)
    {
        AvatarAddress = _avatarAddress;
        MintPeriod = _mintPeriod;
    }

    modifier checkAvatarOwner(uint tokenId) {
        require(
            Avatar(AvatarAddress).ownerOf(tokenId) == msg.sender,
            "Avatar ExperiencePoint Error: You are not owner !"
        );
        _;
    }

    function startMinting(uint tokenId) public checkAvatarOwner(tokenId){
        require(
            block.number >= mintStartBlocks[tokenId] + MintPeriod,
            "Avatar ExperiencePoint Error: Every MintPeriod blocks can be minted only once."
        );
        mintStartBlocks[tokenId] = block.number;

        uint avatarStatus = Avatar(AvatarAddress).getAvatarStatus(tokenId);
        require(
            avatarStatus == idleStatus,
            "Avatar ExperiencePoint Error: Avatar status is not idle"
        );
        Avatar(AvatarAddress).setAvatarStatus(tokenId, mintingStatus);

        emit StartMinting(msg.sender, tokenId, block.number);
    }

    function mint(uint tokenId) public checkAvatarOwner(tokenId) {
        uint mintStartBlock = mintStartBlocks[tokenId];
        require(
            block.number > mintStartBlock + randomWaitingBlock,
            "Avatar ExperiencePoint Error: MintWaitingBlock is not over"
        );

        Attribute memory attribute = abi.decode(
            Avatar(AvatarAddress).getAttributeBytes(tokenId),
            (Attribute)
        );
        uint LV = attribute.LV;

        require(
            attribute.STATUS == mintingStatus,
            "Avatar ExperiencePoint Error: Status is not mintingStatus"
        );
        Avatar(AvatarAddress).setAvatarStatus(tokenId, idleStatus);

        //check over 256 blocks
        if (
            uint(blockhash(mintStartBlock)) == 0 &&
            uint(blockhash(mintStartBlock - 1)) == 0 &&
            uint(blockhash(mintStartBlock - 2)) == 0
        ) {
            emit MintingOver256(msg.sender, tokenId, 0);
        } else {
            uint pushForwardBlock = getBlockHashUint(
                mintStartBlock + randomWaitingBlock / 2
            ) % (randomWaitingBlock / 2);
            uint randomBlockNumber = mintStartBlock + pushForwardBlock;
            uint amount = 1 +
                ((getBlockHashUint(randomBlockNumber) +
                    tokenId +
                    LV +
                    attribute.HP +
                    attribute.MP +
                    attribute.STR +
                    attribute.DEF +
                    attribute.DEX +
                    attribute.LUK) % LV);
            _mint(msg.sender, amount);
            emit Mint(msg.sender, tokenId, amount);
        }
    }

    function getBlockHashUint(uint blocknumber) internal view returns (uint) {
        uint totalHash = 0;
        for (uint i = 0; i < 5; i++) {
            totalHash = totalHash + (uint(blockhash(blocknumber + i)) % 10e10);
        }
        return totalHash;
    }

    function getAvatarAddress() public view returns (address) {
        return AvatarAddress;
    }

    function getMintPeriod() public view returns (uint) {
        return MintPeriod;
    }



}
