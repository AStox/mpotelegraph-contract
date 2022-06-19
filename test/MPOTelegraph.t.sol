// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// import "forge-std/Vm.sol";
import "../src/MPOTelegraph.sol";

contract ContractTest is Test {
    MPOTelegraph public mpo;

    function setUp() public {
        mpo = new MPOTelegraph();
    }

    function testMintSuccess(uint256 id, address to) public {
        mpo.mint{value:0.001e18}(id, to, "hello world");
        assertTrue(mpo.ownerOf(id) == address(to));
    }
    function testMintHugeMessage(uint256 id, address to) public {
        mpo.mint{value:0.001e18}(id, to, "Call me Ishmael. Some years ago never mind how long precisely having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking peoples hats off then, I account it high time to get to sea as soon as I can. This is my substitute for pistol and ball. With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.");
        assertTrue(mpo.ownerOf(id) == address(to));
    }
    function testMintSameId(uint256 id, address to1, address to2) public {
        mpo.mint{value:0.001e18}(id, 0x0000000000000000000000000000000000000001, "hello world");
        vm.expectRevert("ID already in use");
        mpo.mint{value:0.001e18}(id, to2, "goodbye world");
    }
    // function mintSecondMessageToSameAddress() public {}
    function testMintInsufficientEth(uint256 id, address to) public {
        vm.expectRevert("Send more ETH");
        mpo.mint{value:0.0005e18}(id, to, "hello world");
    }
    // function replySuccess(uint256 id, address to) public {

    // }
    // function replyWrongId() public {}
    // function burn() public {}
    // function changeTokenURI() public {}
    // function transfer() public {}
    // function withdraw() public {}





}
