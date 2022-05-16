// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CollectibleItem is ERC721URIStorage {
    // create collectible id for each picasso (bicasso) collection
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Bicasso", "CASSO") {}

    function createCollection(string memory tokenURI) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }
}