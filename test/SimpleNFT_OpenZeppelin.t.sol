//SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "../src/SimpleNFT_OpenZeppelin.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "forge-std/console.sol";

// https://www.rareskills.io/post/foundry-testing-solidity

contract SimpleNFT_OpenZeppelinTest is Test, IERC721Receiver {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    SimpleNFT_OpenZeppelin public simpleNFT;
    InternalFunctionHarness public internalFunctionHarness;
    error OwnableUnauthorizedAccount(address);
    error OwnableInvalidOwner(address);

    // vitalik's addresss
    address public user1 = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;

    function setUp() public {
        simpleNFT = new SimpleNFT_OpenZeppelin("name", "symbol");
        internalFunctionHarness = new InternalFunctionHarness("name", "symbol");
    }

    function testNameAndSymbol() external {
        assertEq(simpleNFT.name(), "name", "wrong name");
        assertEq(simpleNFT.symbol(), "symbol", "wrong symbol");
    }

    function testConstant() external {
        assertEq(simpleNFT.MAX_SUPPLY(), 5, "wrong max supply");
        assertEq(simpleNFT.PRICE(), 1 ether, "wrong minting price");
    }

    function testIsTheOwnerTheOwner() external {
        // for console.log use forge test -vv
        console.log("address(this)", address(this));
        console.log("simpleNFT.owner()", simpleNFT.owner());
        assertEq(
            address(this),
            simpleNFT.owner(),
            "Not the expected owner of the contract"
        );
    }

    function testCantTransferOwnershipToAddress0() external {
        vm.expectRevert(
            abi.encodeWithSelector(OwnableInvalidOwner.selector, address(0))
        );
        simpleNFT.transferOwnership(address(0));
    }

    function testTransferOwnershipToNewAddress() external {
        simpleNFT.transferOwnership(user1);
        assertEq(
            simpleNFT.owner(),
            user1,
            "Not the expected owner of the contract"
        );
    }

    function testCantRenounceOwnership() external {
        vm.expectRevert("can't renounce ownership");
        simpleNFT.renounceOwnership();
    }

    function testIsTheMinterTheOwner() external {
        vm.deal(address(this), 1 ether);
        simpleNFT.mint{value: 1 ether}();
        assertEq(
            simpleNFT.ownerOf(0),
            address(this),
            "wrong owner of Minted NFT"
        );
        assertEq(simpleNFT.balanceOf(address(this)), 1, "wrong balance");
    }

    function testCantMintMoreThanMaxSupply() external {
        vm.deal(address(this), 6 ether);
        simpleNFT.mint{value: 1 ether}();
        simpleNFT.mint{value: 1 ether}();
        simpleNFT.mint{value: 1 ether}();
        simpleNFT.mint{value: 1 ether}();
        simpleNFT.mint{value: 1 ether}();
        assertEq(simpleNFT.tokenSupply(), 5, "wrong supply");

        vm.expectRevert("max supply minted");
        simpleNFT.mint{value: 1 ether}();
    }

    function testIsMaxSupplyUpdatedAfterMint() external {
        vm.deal(address(this), 1 ether);
        assertEq(simpleNFT.tokenSupply(), 0, "wrong supply");
        simpleNFT.mint{value: 1 ether}();
        assertEq(simpleNFT.tokenSupply(), 1, "wrong supply");
    }

    function testCantMintIfValueNotEnough() external {
        vm.expectRevert("min value is 1 eth");
        simpleNFT.mint{value: 0.1 ether}();
    }

    function testMintIfValueSuperior() external {
        assertEq(simpleNFT.balanceOf(address(this)), 0, "wrong start balance");
        vm.deal(address(this), 2 ether);
        simpleNFT.mint{value: 2 ether}();
        assertEq(simpleNFT.balanceOf(address(this)), 1, "wrong end balance");
    }

    function testIsBalanceOfUpdatedAfterMint() external {
        vm.deal(address(this), 1 ether);
        simpleNFT.mint{value: 1 ether}();
        assertEq(simpleNFT.balanceOf(address(this)), 1, "wrong NFT balance");
    }

    function testETHBalancesAfterMint() external {
        vm.deal(address(this), 1 ether);
        simpleNFT.mint{value: 1 ether}();
        assertEq(
            address(this).balance,
            0 ether,
            "expected balance of minter to be 0"
        );
        assertEq(
            address(simpleNFT).balance,
            1 ether,
            "expected balance of NFT contract to be 1 ether after mint"
        );
    }

    function testWithdrawFromOwnerUpdateETHBalances() external {
        vm.deal(address(this), 1 ether);
        vm.deal(user1, 1 ether);

        simpleNFT.mint{value: 1 ether}();

        vm.prank(user1);
        simpleNFT.mint{value: 1 ether}();

        simpleNFT.withdraw();

        assertEq(
            address(this).balance,
            2 ether,
            "expected balance of NFT contract owner to be 2 ether after withdraw"
        );
        assertEq(
            address(simpleNFT).balance,
            0 ether,
            "expected balance of NFT contract to be 0 ether after withdraw"
        );
    }

    function testWithdrawFailedIfNotCallByOwner() external {
        vm.deal(address(this), 1 ether);
        vm.deal(user1, 1 ether);
        simpleNFT.mint{value: 1 ether}();

        vm.startPrank(user1);
        simpleNFT.mint{value: 1 ether}();

        vm.expectRevert(
            abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, user1)
        );
        simpleNFT.withdraw();

        vm.stopPrank();
    }

    function testBaseURI() external {
        assertEq(
            simpleNFT.baseURI(),
            "https://coding4fun.com/simple_nft/",
            "wrong URI detected"
        );

        simpleNFT.setBaseURI("https//bettertogoonIPFS.com/simple_nft/");
        assertEq(
            simpleNFT.baseURI(),
            "https//bettertogoonIPFS.com/simple_nft/",
            "wrong URI detected"
        );
    }

    function testContractReceiveEther() external {
        vm.deal(address(this), 1 ether);
        (bool success, ) = address(simpleNFT).call{value: 1 ether}("");
        assertEq(success, true, "transfer failed");
        assertEq(address(simpleNFT).balance, 1 ether, "wrong balance");
    }

    function testContractFallbackEther() external {
        vm.deal(address(this), 1 ether);
        (bool success, ) = address(simpleNFT).call{value: 1 ether}("blablabla");
        assertEq(success, true, "transfer failed");
        assertEq(address(simpleNFT).balance, 1 ether, "wrong balance");
    }

    function testMintEmitEvent() external {
        vm.deal(address(this), 1 ether);

        assertEq(
            internalFunctionHarness.balanceOf(address(this)),
            0,
            "wrong supply"
        );

        internalFunctionHarness._safeMint_HARNESS(
            address(this),
            simpleNFT.tokenSupply()
        );

        assertEq(
            internalFunctionHarness.balanceOf(address(this)),
            1,
            "wrong supply"
        );
    }

    receive() external payable {}

    fallback() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

// To test internal function

contract InternalFunctionHarness is ERC721 {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function _safeMint_HARNESS(address to, uint256 tokenId) external {
        return super._safeMint(to, tokenId);
    }
}
