// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IBookManager} from "v2-core/interfaces/IBookManager.sol";
import {ILocker} from "v2-core/interfaces/ILocker.sol";
import {IHooks} from "v2-core/interfaces/IHooks.sol";
import {BookId, BookIdLibrary} from "v2-core/libraries/BookId.sol";
import {Currency, CurrencyLibrary} from "v2-core/libraries/Currency.sol";
import {FeePolicy, FeePolicyLibrary} from "v2-core/libraries/FeePolicy.sol";
import {Tick, TickLibrary} from "v2-core/libraries/Tick.sol";
import {ReentrancyGuard} from "./libraries/ReentrancyGuard.sol";
import {IArbitrage} from "./interfaces/IArbitrage.sol";

contract Arbitrage is IArbitrage, Ownable2Step, ILocker, ReentrancyGuard {
    using TickLibrary for Tick;
    using SafeCast for uint256;
    using CurrencyLibrary for Currency;
    using FeePolicyLibrary for FeePolicy;

    IBookManager public immutable bookManager;

    mapping(address => bool) public isOperator;

    modifier onlyOperator() {
        if (!isOperator[msg.sender]) revert NotOperator();
        _;
    }

    constructor(address bookManager_, address initialOwner_) Ownable(initialOwner_) {
        bookManager = IBookManager(bookManager_);
    }

    function setOperator(address operator, bool status) external onlyOwner {
        isOperator[operator] = status;
        emit SetOperator(operator, status);
    }

    function lockAcquired(address sender, bytes memory data) external nonReentrant returns (bytes memory) {
        if (msg.sender != address(bookManager) || sender != address(this)) revert InvalidAccess();
        address user;
        BookId id;
        address router;
        (user, id, router, data) = abi.decode(data, (address, BookId, address, bytes));

        IBookManager.BookKey memory key = bookManager.getBookKey(id);
        uint256 max;
        bool success;
        bytes memory returnData;
        if (key.quote.isNative()) {
            max = address(bookManager).balance;
            bookManager.withdraw(key.quote, address(this), max);
            (success, returnData) = router.call{value: max}(data);
        } else {
            IERC20 quote = IERC20(Currency.unwrap(key.quote));
            max = quote.balanceOf(address(bookManager));
            bookManager.withdraw(key.quote, address(this), max);
            quote.approve(router, max);
            (success, returnData) = router.call(data);
            quote.approve(router, 0);
        }
        if (!success) revert();

        uint256 quoteAmount = max - key.quote.balanceOfSelf();
        uint256 baseAmount = key.base.balanceOfSelf();
        uint256 spentBaseAmount;
        uint256 price;
        if (key.takerPolicy.usesQuote()) {
            quoteAmount = uint256(quoteAmount.toInt256() + key.takerPolicy.calculateFee(quoteAmount, false));
            price = (quoteAmount << 96) / baseAmount;
        } else {
            price = (quoteAmount << 96) / key.takerPolicy.calculateOriginalAmount(baseAmount, false);
        }

        while (spentBaseAmount < baseAmount && !bookManager.isEmpty(id)) {
            Tick tick = bookManager.getHighest(id);
            if (price >= tick.toPrice()) break; // Did not consider fees.
            uint256 maxAmount;
            unchecked {
                if (key.takerPolicy.usesQuote()) {
                    maxAmount = baseAmount - spentBaseAmount;
                } else {
                    maxAmount = key.takerPolicy.calculateOriginalAmount(baseAmount - spentBaseAmount, false);
                }
            }
            maxAmount = tick.baseToQuote(maxAmount, false) / key.unitSize;
            if (maxAmount == 0) break;
            (, uint256 amount) =
                bookManager.take(IBookManager.TakeParams({key: key, tick: tick, maxUnit: maxAmount.toUint64()}), "");
            if (amount == 0) break;
            spentBaseAmount += amount;
        }

        _settleCurrency(user, key.quote);
        _settleCurrency(user, key.base);

        return "";
    }

    function arbitrage(BookId id, address router, bytes calldata data) external onlyOperator {
        bookManager.lock(address(this), abi.encode(msg.sender, id, router, data));
    }

    function _settleCurrency(address user, Currency currency) internal {
        int256 currencyDelta = -bookManager.getCurrencyDelta(address(this), currency);
        if (currencyDelta > 0) {
            currency.transfer(address(bookManager), uint256(currencyDelta));
        }
        bookManager.settle(currency);
        uint256 balance = currency.balanceOfSelf();
        if (balance > 0) {
            currency.transfer(user, balance);
        }
    }

    function withdrawToken(Currency currency, uint256 amount, address recipient) external onlyOwner {
        currency.transfer(recipient, amount);
    }

    receive() external payable {}
}
