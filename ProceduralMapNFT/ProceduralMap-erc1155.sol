// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ProceduralMap is ERC1155, Ownable {
    using Strings for uint256;
    
    bool public publicSaleActive;
    
    uint256 public constant MAX_SUPPLY = 10;
    
    uint public mintPrice = 0.01 ether;
    
    uint256 private _tokenIds;
    
    string[MAX_SUPPLY] private _tokenUris;
    
    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }
    
    constructor() ERC1155("") {}
    
    function addTokenUri(uint256 tokenId, string memory tokenUri) external onlyOwner {
        _tokenUris[tokenId] = tokenUri;
    }
    
    function uri(uint256 _id) public view override returns (string memory) {
        if (bytes(_tokenUris[_id]).length > 0) {
            return _tokenUris[_id];
        }
      
        return string(super.uri(_id));
    }

    
    function startPublicSale()
        external
        onlyOwner
    {
        require(!publicSaleActive, "Public sale has already begun");
        publicSaleActive = true;
    }

    function pausePublicSale() external onlyOwner whenPublicSaleActive {
        publicSaleActive = false;
    }
    
    function mint(uint256 numNfts)
        external
        payable
        whenPublicSaleActive
    {
        require(_tokenIds + numNfts <= MAX_SUPPLY, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint one NFT");
        require(mintPrice * numNfts <= msg.value, "Ether value sent is not correct");

        for (uint i = 0; i < numNfts; i++){
            _mint(msg.sender, _tokenIds, 1, "");
            _tokenIds += 1;
        }
    }
    
    function mintTo(uint256 numNfts, address toAddress)
        external
        onlyOwner
        whenPublicSaleActive
    {
        require(_tokenIds + numNfts <= MAX_SUPPLY, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint one NFT");

        for (uint i = 0; i < numNfts; i++){
             _mint(toAddress, _tokenIds, 1, "");
            _tokenIds += 1;
        }
    }
}