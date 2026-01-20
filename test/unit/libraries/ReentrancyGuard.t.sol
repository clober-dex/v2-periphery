// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";

import "../../mocks/ReentrancyMock.sol";

contract ReentrancyGuardTest is Test {
    ReentrancyGuardMock public reentrancyGuard;

    function setUp() public {
        reentrancyGuard = new ReentrancyGuardMock();
        reentrancyGuard.increaseCountWithCallback("");
    }

    function testReentrancyFailed() public {
        vm.expectRevert(abi.encodeWithSelector(ReentrancyGuardTransient.ReentrancyGuardReentrantCall.selector));
        reentrancyGuard.increaseCountWithCallback(abi.encodeWithSelector(this.callbackIncreaseCount.selector));
        assertEq(reentrancyGuard.count(), 1);
    }

    function testReentrancyFailedToAnotherFunction() public {
        vm.expectRevert(abi.encodeWithSelector(ReentrancyGuardTransient.ReentrancyGuardReentrantCall.selector));
        reentrancyGuard.increaseCountWithCallback(abi.encodeWithSelector(this.callbackDecreaseCount.selector));
        assertEq(reentrancyGuard.count(), 1);
    }

    function callbackDecreaseCount() public {
        reentrancyGuard.decreaseCount();
    }

    function callbackIncreaseCount() public {
        reentrancyGuard.increaseCountWithCallback("");
    }
}
