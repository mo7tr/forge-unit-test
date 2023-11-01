//SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console.sol";

contract SimpleNFT_OpenZeppelin is ERC721, Ownable {
    uint256 public tokenSupply = 0;
    uint256 public constant MAX_SUPPLY = 5;
    uint256 public constant PRICE = 1 ether;
    string public baseURI = "https://coding4fun.com/simple_nft/";

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Ownable(_msgSender()) {}

    function mint() external payable {
        require(msg.value >= 1 ether, "min value is 1 eth");
        require(tokenSupply < MAX_SUPPLY, "max supply minted");
        _safeMint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // kill renounceOwnership function in order not to accidentaly renounce the ownership
    function renounceOwnership() public pure override {
        require(false, "can't renounce ownership");
    }

    // we can do the same as above for transferOwnership if you don't want to transfer the ownership to address(0)
    function transferOwnership(address newOwner) public override onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    receive() external payable {
        console.log("receive function");
    }

    fallback() external payable {
        console.log("fallback function");
    }
}
