// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "v2-core/libraries/Currency.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MockBookManager is Ownable2Step {
    using CurrencyLibrary for Currency;

    constructor(address owner_) Ownable(owner_) {}

    function collect(address recipient, Currency currency) external returns (uint256 amount) {
        amount = 1234567654323456763;
        currency.transfer(recipient, amount);
    }

    function whitelist(address provider) external onlyOwner {}

    function delist(address provider) external onlyOwner {}

    function setDefaultProvider(address newDefaultProvider) external onlyOwner {}
}
