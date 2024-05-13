// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IProvider} from "./interfaces/IProvider.sol";
import {Currency, CurrencyLibrary} from "v2-core/libraries/Currency.sol";
import {IProviderFactory} from "./interfaces/IProviderFactory.sol";

contract Provider is IProvider {
    using CurrencyLibrary for Currency;

    uint256 public constant RATE_PRECISION = 10 ** 6;

    IProviderFactory public immutable factory;
    address public immutable broker;
    uint256 public immutable shareRatio;

    constructor(address broker_, uint256 shareRatio_) {
        factory = IProviderFactory(msg.sender);
        broker = broker_;
        shareRatio = shareRatio_;
    }

    function claim(Currency[] calldata currencies) external {
        address protocolTreasury = factory.treasury();
        for (uint256 i = 0; i < currencies.length; i++) {
            Currency currency = currencies[i];
            uint256 balance = currency.balanceOfSelf();
            uint256 brokerShare = balance * shareRatio / RATE_PRECISION;
            uint256 protocolShare = balance - brokerShare;
            currency.transfer(broker, brokerShare);
            currency.transfer(protocolTreasury, protocolShare);
            emit Claim(broker, protocolTreasury, brokerShare, protocolShare);
        }
    }
}
