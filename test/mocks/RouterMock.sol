// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Currency, CurrencyLibrary } from "v2-core/libraries/Currency.sol";

contract RouterMock {
    using CurrencyLibrary for Currency;

    function swap(address inToken, uint256 inAmount, address outToken, uint256 outAmount) payable external {
        if (inToken != address (0)) {
            IERC20(inToken).transferFrom(msg.sender, address (this), inAmount);
        } else {
            msg.sender.call{value: msg.value - inAmount}("");
            address(0).call{value: inAmount}("");
        }
        Currency.wrap(outToken).transfer(msg.sender, outAmount);
    }

    receive() external payable {}
}
