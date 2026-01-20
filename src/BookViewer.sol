// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.20;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol"; // To generate artifacts
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IBookManager} from "v2-core/interfaces/IBookManager.sol";
import {SignificantBit} from "v2-core/libraries/SignificantBit.sol";
import {Math} from "v2-core/libraries/Math.sol";
import {Lockers} from "v2-core/libraries/Lockers.sol";
import {BookId} from "v2-core/libraries/BookId.sol";
import {Tick, TickLibrary} from "v2-core/libraries/Tick.sol";
import {FeePolicy, FeePolicyLibrary} from "v2-core/libraries/FeePolicy.sol";

import {IBookViewer} from "./interfaces/IBookViewer.sol";
import {IController} from "./interfaces/IController.sol";

contract BookViewer is IBookViewer, UUPSUpgradeable, Ownable2Step, Initializable {
    using SafeCast for *;
    using TickLibrary for *;
    using Math for uint256;
    using SignificantBit for uint256;
    using FeePolicyLibrary for FeePolicy;

    IBookManager public immutable bookManager;

    constructor(IBookManager bookManager_) Ownable(msg.sender) {
        bookManager = bookManager_;
        _disableInitializers();
    }

    function __BookViewer_init(address owner) external initializer {
        _transferOwnership(owner);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function getLiquidity(BookId id, Tick tick, uint256 n) external view returns (Liquidity[] memory liquidity) {
        liquidity = new Liquidity[](n);
        if (bookManager.getDepth(id, tick) == 0) tick = bookManager.maxLessThan(id, tick);
        uint256 i;
        while (i < n) {
            if (Tick.unwrap(tick) == type(int24).min) break;
            liquidity[i] = Liquidity({tick: tick, depth: bookManager.getDepth(id, tick)});
            tick = bookManager.maxLessThan(id, tick);
            unchecked {
                ++i;
            }
        }
        assembly {
            mstore(liquidity, i)
        }
    }

    function getExpectedInput(IController.TakeOrderParams memory params)
        external
        view
        returns (uint256 takenQuoteAmount, uint256 spentBaseAmount)
    {
        IBookManager.BookKey memory key = bookManager.getBookKey(params.id);

        if (bookManager.isEmpty(params.id)) return (0, 0);

        Tick tick = bookManager.getHighest(params.id);

        while (Tick.unwrap(tick) > type(int24).min) {
            unchecked {
                if (params.limitPrice > tick.toPrice()) break;
                uint256 maxAmount;
                if (key.takerPolicy.usesQuote()) {
                    maxAmount = key.takerPolicy.calculateOriginalAmount(params.quoteAmount - takenQuoteAmount, true);
                } else {
                    maxAmount = params.quoteAmount - takenQuoteAmount;
                }
                maxAmount = maxAmount.divide(key.unitSize, true);

                if (maxAmount == 0) break;
                uint256 currentDepth = bookManager.getDepth(params.id, tick);
                uint256 quoteAmount = (currentDepth > maxAmount ? maxAmount : currentDepth) * key.unitSize;
                uint256 baseAmount = tick.quoteToBase(quoteAmount, true);
                if (key.takerPolicy.usesQuote()) {
                    quoteAmount = uint256(int256(quoteAmount) - key.takerPolicy.calculateFee(quoteAmount, false));
                } else {
                    baseAmount = uint256(baseAmount.toInt256() + key.takerPolicy.calculateFee(baseAmount, false));
                }
                if (quoteAmount == 0) break;

                takenQuoteAmount += quoteAmount;
                spentBaseAmount += baseAmount;
                if (params.quoteAmount <= takenQuoteAmount) break;
                tick = bookManager.maxLessThan(params.id, tick);
            }
        }
    }

    function getExpectedOutput(IController.SpendOrderParams memory params)
        external
        view
        returns (uint256 takenQuoteAmount, uint256 spentBaseAmount)
    {
        IBookManager.BookKey memory key = bookManager.getBookKey(params.id);

        if (bookManager.isEmpty(params.id)) return (0, 0);

        Tick tick = bookManager.getHighest(params.id);

        unchecked {
            while (spentBaseAmount <= params.baseAmount && Tick.unwrap(tick) > type(int24).min) {
                if (params.limitPrice > tick.toPrice()) break;
                uint256 maxAmount;
                if (key.takerPolicy.usesQuote()) {
                    maxAmount = params.baseAmount - spentBaseAmount;
                } else {
                    maxAmount = key.takerPolicy.calculateOriginalAmount(params.baseAmount - spentBaseAmount, false);
                }
                maxAmount = tick.baseToQuote(maxAmount, false) / key.unitSize;

                if (maxAmount == 0) break;
                uint256 currentDepth = bookManager.getDepth(params.id, tick);
                uint256 quoteAmount = (currentDepth > maxAmount ? maxAmount : currentDepth) * key.unitSize;
                uint256 baseAmount = tick.quoteToBase(quoteAmount, true);
                if (key.takerPolicy.usesQuote()) {
                    quoteAmount = uint256(int256(quoteAmount) - key.takerPolicy.calculateFee(quoteAmount, false));
                } else {
                    baseAmount = uint256(baseAmount.toInt256() + key.takerPolicy.calculateFee(baseAmount, false));
                }
                if (baseAmount == 0) break;

                takenQuoteAmount += quoteAmount;
                spentBaseAmount += baseAmount;
                tick = bookManager.maxLessThan(params.id, tick);
            }
        }
    }
}
