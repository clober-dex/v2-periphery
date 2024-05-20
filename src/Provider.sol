// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.20;

import {IBookManager} from "v2-core/interfaces/IBookManager.sol";
import {Currency, CurrencyLibrary} from "v2-core/libraries/Currency.sol";
import {IProvider} from "./interfaces/IProvider.sol";
import {IProviderFactory} from "./interfaces/IProviderFactory.sol";

contract Provider is IProvider {
    using CurrencyLibrary for Currency;

    uint256 public constant RATE_PRECISION = 10 ** 6;

    IBookManager private immutable _bookManager;
    IProviderFactory public immutable factory;
    address public immutable broker;
    uint256 public immutable shareRatio;

    constructor(address broker_, uint256 shareRatio_) {
        factory = IProviderFactory(msg.sender);
        _bookManager = factory.bookManager();
        broker = broker_;
        shareRatio = shareRatio_;
    }

    function claim(Currency[] calldata currencies) external {
        address protocolTreasury = factory.treasury();
        for (uint256 i = 0; i < currencies.length; i++) {
            Currency currency = currencies[i];
            _bookManager.collect(address(this), currency);
            uint256 balance = currency.balanceOfSelf();
            uint256 brokerShare = balance * shareRatio / RATE_PRECISION;
            uint256 protocolShare = balance - brokerShare;
            currency.transfer(broker, brokerShare);
            currency.transfer(protocolTreasury, protocolShare);
            emit Claim(broker, protocolTreasury, brokerShare, protocolShare);
        }
    }

    receive() external payable {}
}
