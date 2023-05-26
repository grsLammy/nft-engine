// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/AccessProtected.sol";

contract NFTEngine is ERC721URIStorage, ERC721Enumerable, ERC721Burnable, AccessProtected {
    using Counters for Counters.Counter;
    using Address for address;

    Counters.Counter public _tokenIds;
    mapping(string => bool) public hashes;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
     * Mint + Issue NFT
     *
     * @param recipient - NFT will be issued to recipient
     * @param hash - Artwork Metadata IPFS hash
     */
    function issueToken(address recipient, string memory hash) public onlyAdmin returns (uint256) {
        require(hashes[hash] == false, "NFT for hash already minted");
        hashes[hash] = true;
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(recipient, newTokenId);
        _setTokenURI(newTokenId, hash);
        return newTokenId;
    }

    /**
     * Batch Mint
     *
     * @param recipient - NFT will be issued to recipient
     * @param _hashes - array of Artwork Metadata IPFS hash
     */
    function issueBatch(address recipient, string[] memory _hashes) public onlyAdmin returns (uint256[] memory) {
        uint256 len = _hashes.length;
        uint256[] memory tokenIds = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            uint256 tokenId = issueToken(recipient, _hashes[i]);
            tokenIds[i] = tokenId;
        }
        return tokenIds;
    }

    /**
     * Transfer Multiple NFTs
     *
     * @param _sender - address of the sender to send NFT from
     * @param _receiver - address of the receiver to receive NFT to
     * @param _ids - array of token IDs of the _sender
     */
    function transferMultipleNFTs(
        address _sender,
        address _receiver,
        uint256[] calldata _ids
    ) external onlyAdmin {
        require(_sender != address(0), "sender address cannot be 0x00 address");
        require(_receiver != address(0), "receiver address cannot be 0x00 address");
        uint256 len = _ids.length;
        for (uint256 i = 0; i < len; i++) {
            safeTransferFrom(_sender, _receiver, _ids[i]);
        }
    }

    /**
     * Get Holder Token IDs
     *
     * @param holder - Holder of the Tokens
     */
    function getHolderTokenIds(address holder) public view returns (uint256[] memory) {
        uint256 count = balanceOf(holder);
        uint256[] memory result = new uint256[](count);
        for (uint256 index = 0; index < count; index++) {
            result[index] = tokenOfOwnerByIndex(holder, index);
        }
        return result;
    }

    //
    //  OVERRIDES
    //
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        //check if on lend check to whitelist
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
