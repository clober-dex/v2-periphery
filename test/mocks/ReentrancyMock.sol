// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {ReentrancyGuard} from "../../src/libraries/ReentrancyGuard.sol";

contract ReentrancyGuardMock is ReentrancyGuard {
    uint256 public count;

    function increaseCountWithCallback(bytes calldata data) public nonReentrant {
        if (data.length > 0) {
            (bool success, bytes memory reason) = msg.sender.call(data);
            require(success, string(reason));
        }
        count++;
    }

    function decreaseCount() public nonReentrant {
        count--;
    }
}
