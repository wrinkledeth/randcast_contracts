// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Coordinator} from "src/Coordinator.sol";
import {Controller} from "src/Controller.sol";

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
    bytes pubkey1 = "0x123"; //! use more realistic sample key.
    bytes pubkey2 = "0x456";
    bytes pubkey3 = "0x789";

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

    function testEmitGroupEvent() public {
        vm.prank(node1);
        controller.nodeRegister(pubkey1);
        vm.prank(node2);
        controller.nodeRegister(pubkey2);
        vm.prank(node3);
        controller.nodeRegister(pubkey3);

        (address a, bytes memory key) = controller.getNode(node1);
        emit log_address(a);
        emit log_bytes(key);

        // uint256 size = controller.getGroupSize(0);
        // emit log_uint(size);

        Controller.Group memory g = controller.getGroup(0);
        emit log_uint(g.index);
        emit log_uint(g.epoch);
        emit log_uint(g.size);
        emit log_uint(g.threshold);
    }
}
