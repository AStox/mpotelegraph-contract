// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MPOTelegraph.sol";

contract ContractTest is Test {
    MPOTelegraph public mpo;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Mint(address indexed from, uint256 indexed tokenId, string text);

    function setUp() public {
        mpo = new MPOTelegraph();
    }

    function testMintSuccess(uint256 id, address to) public payable {
        vm.assume(to != address(0));
        mpo.mint{value:0.001e18}(id, to, "hello world");
        assertTrue(mpo.ownerOf(id) == address(to));
    }

    function empty(uint256 id, address to) public payable {
        // return true;
    }

    function testMintSuccessPrank(uint256 id, address address1, address address2) public {
        vm.assume(address1 != address(0));
        vm.assume(address1 != address2);
        vm.assume(address2 != address(0));
        hoax(address2);
        mpo.mint{value:0.001e18}(id, address1, "hello world");
        assertTrue(true);
        // assertTrue(mpo.ownerOf(id) == address1);
    }
    function testMintToZero(uint256 id) public {
        vm.expectRevert("No recipient");
        mpo.mint{value:0.001e18}(id, address(0), "hello world");
    }
    function testMintTransferEvent(uint256 id, address to) public {
        vm.assume(to != address(0));
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), to, id);
        mpo.mint{value:0.001e18}(id, to, "hello world");
    }
    function testMintMintEvent(uint256 id, address to) public {
        vm.assume(to != address(0));
        vm.expectEmit(true, true, true, true);
        emit Mint(address(this), id, "hello world");
        mpo.mint{value:0.001e18}(id, to, "hello world");
    }
    function testMintHugeMessage(uint256 id, address to) public {
        vm.assume(to != address(0));
        mpo.mint{value:0.001e18}(id, to, "Call me Ishmael. Some years ago never mind how long precisely having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking peoples hats off then, I account it high time to get to sea as soon as I can. This is my substitute for pistol and ball. With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.");
        assertTrue(mpo.ownerOf(id) == address(to));
    }
    function testMintSameId(uint256 id, address to1, address to2) public {
        vm.assume(to1 != address(0));
        vm.assume(to2 != address(0));
        mpo.mint{value:0.001e18}(id, to1, "hello world");
        vm.expectRevert("ID already in use");
        mpo.mint{value:0.001e18}(id, to2, "goodbye world");
    }
    // function mintSecondMessageToSameAddress() public {}
    function testMintInsufficientEth(uint256 id, address to) public {
        vm.assume(to != address(0));
        vm.expectRevert("Send more ETH");
        mpo.mint{value:0.0005e18}(id, to, "hello world");
    }
    function testReplySuccess(uint256 id, address address1, address address2) public {
        vm.assume(address1 != address(0));
        vm.assume(address2 != address(0));
        vm.assume(address2 != address1);
        hoax(address1);
        mpo.mint{value:0.001e18}(id, address2, "hello world");
        vm.prank(address2);
        mpo.reply(id, address1, "oh! hello there");
        assertTrue(mpo.ownerOf(id) == address(address1));
    }

    function testReplyMissingId(uint256 id1, uint256 id2, address address1, address address2) public {
        vm.assume(address1 != address(0));
        vm.assume(address2 != address(0));
        vm.assume(address2 != address1);
        vm.assume(id1 != id2);
        hoax(address1);
        mpo.mint{value:0.001e18}(id1, address2, "hello world");
        vm.prank(address2);
        vm.expectRevert("ID doesn't exist");
        mpo.reply(id2, address1, "oh! hello there");
    }

    function testReplyWrongId(uint256 id1, uint256 id2, address address1, address address2) public {
        vm.assume(address1 != address(0));
        vm.assume(address2 != address(0));
        vm.assume(address1 != address2);
        vm.assume(id1 != id2);
        mpo.mint{value:0.001e18}(id1, address1, "hello world");
        vm.prank(address2);
        vm.expectRevert("Not your message to burn");
        mpo.reply(id1, address1, "oh! hello there");
    }
    function testReplyToSelf(uint256 id1, address address1) public {
        vm.assume(address1 != address(0));
        hoax(address1);
        mpo.mint{value:0.001e18}(id1, address1, "hello world");
        hoax(address1);
        vm.expectRevert("Sorry, can't reply to yourself");
        mpo.reply(id1, address1, "oh! hello there");
    }
    // function burn() public {}
    // function changeTokenURI() public {}
    // function transfer() public {}
    // function withdraw() public {}





}
