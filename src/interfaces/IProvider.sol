// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Currency, CurrencyLibrary} from "v2-core/libraries/Currency.sol";
import {IProviderFactory} from "./IProviderFactory.sol";

interface IProvider {
    event Claim(
        address indexed broker,
        address indexed protocolTreasury,
        Currency indexed currency,
        uint256 brokerShare,
        uint256 protocolShare
    );

    function factory() external returns (IProviderFactory);

    function broker() external returns (address);

    function shareRatio() external returns (uint256);

    function claim(Currency[] calldata currencies) external;
}
