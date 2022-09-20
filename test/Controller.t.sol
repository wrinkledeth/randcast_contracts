// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Coordinator} from "src/Coordinator.sol";
import {Controller} from "src/Controller.sol";

import "openzeppelin-contracts/contracts/utils/Strings.sol";

// Suggested usage: forge test --match-contract Controller -vv

contract ControllerTest is Test {
    Controller controller;

    address public owner = address(0xC0FF33);

    // Nodes: To be Registered
    address public node1 = address(0x1);
    address public node2 = address(0x2);
    address public node3 = address(0x3);

    //Unregistered Node
    address public node4 = address(0x4);

    // Node Public Keys
    bytes pubkey1 = "0x5"; //! use more realistic sample key.
    bytes pubkey2 = "0x6";
    bytes pubkey3 = "0x7";

    function setUp() public {
        // deal nodes
        vm.deal(node1, 1 * 10**18);
        vm.deal(node2, 1 * 10**18);
        vm.deal(node3, 1 * 10**18);

        // deal owner and create controller
        vm.deal(owner, 1 * 10**18);
        vm.prank(owner);
        controller = new Controller();
    }

    function testNodeRegister() public {}

    function testEmitGroupEvent() public {
        // * Register Three nodes and see if group struct is well formed

        uint256 groupIndex = 1;
        printGroupInfo(groupIndex);
        printNodeInfo(node1);

        // Register Node 1
        vm.prank(node1);
        controller.nodeRegister(pubkey1);
        printGroupInfo(groupIndex);
        printNodeInfo(node1);

        // Register Node 2
        vm.prank(node2);
        controller.nodeRegister(pubkey2);
        printGroupInfo(groupIndex);

        // Register Node 3
        vm.prank(node3);
        controller.nodeRegister(pubkey3);
        printGroupInfo(groupIndex);

        // check group struct is correct
        Controller.Group memory g = controller.getGroup(groupIndex);
        assertEq(g.index, 1);
        assertEq(g.epoch, 1);
        assertEq(g.size, 3);
        assertEq(g.threshold, 3);
        assertEq(g.members.length, 3);
    }

    // ! Helper function for debugging below
    uint256 registerCount = 0; // track number of registered nodes for print statements

    function printGroupInfo(uint256 groupIndex) public {
        Controller.Group memory g = controller.getGroup(groupIndex);
        emit log(
            string.concat(
                "\nNode ",
                Strings.toString(registerCount++),
                " Registered:"
            )
        );

        uint256 groupCount = controller.groupCount();
        emit log_named_uint("groupCount", groupCount);
        emit log_named_uint("g.index", g.index);
        emit log_named_uint("g.epoch", g.epoch);
        emit log_named_uint("g.size", g.size);
        emit log_named_uint("g.threshold", g.threshold);
        emit log_named_uint("g.members.length", g.members.length);
    }

    function printNodeInfo(address nodeAddress) public {
        Controller.Node memory n = controller.getNode(nodeAddress);
        emit log("----");
        emit log_named_address("n.idAddress", n.idAddress);
        emit log_named_bytes("n.dkgPublicKey", n.dkgPublicKey);
        emit log_named_string("n.state", Bool.toText(n.state));
        emit log_named_uint("n.pending_until_block", n.pending_until_block);
        emit log_named_uint("n.staking", n.staking);
    }
}

// Helper library for logging bool
// EX : emit log_named_string("n.state", Bool.toText(n.state));
library Bool {
    function toUInt256(bool x) internal pure returns (uint256 r) {
        assembly {
            r := x
        }
    }

    function toBool(uint256 x) internal pure returns (string memory r) {
        // x == 0 ? r = "False" : "True";
        if (x == 1) {
            r = "True";
        } else if (x == 0) {
            r = "False";
        } else {}
    }

    function toText(bool x) internal pure returns (string memory r) {
        uint256 inUint = toUInt256(x);
        string memory inString = toBool(inUint);
        r = inString;
    }
}
