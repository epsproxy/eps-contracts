// SPDX-License-Identifier: MIT
// EPSProxy Contracts v1.0.0 (epsproxy/eps-contracts/contracts/ProxiedERC721Open.sol)

pragma solidity ^0.8.9;

import "./ERC721Proxied.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ProxyNFT is ERC721Proxied, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public mintFee;
    
    event MintFeeSet(uint256 indexed mintFee);
    event Withdrawal(uint256 indexed amount, uint256 timestamp);
    
    constructor(uint256 _mintFee) ERC721("ProxyNFT", "PROXYNFT") {
      mintFee = _mintFee;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "base uri goes here";
    }

    function proxyMint(bool isProxied) external payable {
      // 1) Check the fee has been paid:
      require(msg.value == mintFee, "Insufficient ETH for mint fee");

      // 2) Perform the minting, using the proxy delivery address if isProxied:
      uint256 tokenId = _tokenIdCounter.current();
      _tokenIdCounter.increment();
      _safeMintProxiedSwitch(msg.sender, tokenId, isProxied);
    }

    /**
    * @dev set the fee for minting:
    */
    function setMintFee(uint256 _mintFee) external onlyOwner returns (bool)
    {
      require(_mintFee != mintFee, "No change to mint fee");
      mintFee = _mintFee;
      emit MintFeeSet(mintFee);
      return true;
    }

    /**
    * @dev withdraw eth to the owner:
    */
    function withdraw(uint256 _amount) external onlyOwner returns (bool) {
      (bool success, ) = msg.sender.call{value: _amount}("");
      require(success, "Withdrawal failed.");
      emit Withdrawal(_amount, block.timestamp);
      return true;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}