// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Coordinator} from "src/Coordinator.sol";

// import {Cotroller} from "src/Controller.sol";

contract CoordinatorTest is Test {
    Coordinator coordinator;

    address public controller = address(0xBEEF);

    function setUp() public {
        uint256 PHASE_DURATION = 30;
        uint256 THRESHOLD = 3;

        vm.deal(controller, 1 * 10**18);
        vm.startPrank(controller);
        coordinator = new Coordinator(THRESHOLD, PHASE_DURATION);
        vm.stopPrank();
    }

    function testExample() public {
        assertTrue(true);
    }
}
