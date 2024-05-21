// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "v2-core/libraries/Currency.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MockBookManager is Ownable2Step {
    using CurrencyLibrary for Currency;

    mapping(address provider => bool) public isWhitelisted;
    address public defaultProvider;

    constructor(address owner_) Ownable(owner_) {}

    function collect(address recipient, Currency currency) external returns (uint256 amount) {
        amount = 1234567654323456763;
        currency.transfer(recipient, amount);
    }

    function whitelist(address provider) external onlyOwner {
        isWhitelisted[provider] = true;
    }

    function delist(address provider) external onlyOwner {
        isWhitelisted[provider] = false;
    }

    function setDefaultProvider(address newDefaultProvider) external onlyOwner {
        _setDefaultProvider(newDefaultProvider);
    }

    function _setDefaultProvider(address newDefaultProvider) internal {
        defaultProvider = newDefaultProvider;
    }
}
