// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "v2-core/libraries/BookId.sol";
import "v2-core/libraries/Hooks.sol";
import "v2-core/BookManager.sol";
import "v2-core/mocks/MockERC20.sol";

import "./controller/ControllerTest.sol";
import "../Constants.sol";
import "../../src/Controller.sol";
import "../../src/Arbitrage.sol";
import "../mocks/RouterMock.sol";

contract ControllerTakeOrderTest is ControllerTest {
    using BookIdLibrary for IBookManager.BookKey;
    using FeePolicyLibrary for FeePolicy;
    using TickLibrary for Tick;
    using OrderIdLibrary for OrderId;
    using Hooks for IHooks;

    Arbitrage public arbitrage;
    RouterMock public routerMock;

    function setUp() public {
        mockErc20 = new MockERC20("Mock", "MOCK", 18);

        key = IBookManager.BookKey({
            base: Currency.wrap(address(mockErc20)),
            unitSize: 1e12,
            quote: CurrencyLibrary.NATIVE,
            makerPolicy: FeePolicyLibrary.encode(true, 100),
            takerPolicy: FeePolicyLibrary.encode(true, 100),
            hooks: IHooks(address(0))
        });

        manager = new BookManager(address(this), Constants.DEFAULT_PROVIDER, "baseUrl", "contractUrl", "name", "symbol");
        controller = new Controller(address(manager));
        bookViewer = new BookViewer(manager);
        arbitrage = new Arbitrage(address(manager), address(this));
        arbitrage.setOperator(Constants.TAKER1, true);
        routerMock = new RouterMock();
        IController.OpenBookParams[] memory openBookParamsList = new IController.OpenBookParams[](1);
        openBookParamsList[0] = IController.OpenBookParams({key: key, hookData: ""});
        controller.open(openBookParamsList, uint64(block.timestamp));

        vm.deal(Constants.MAKER1, 1000 * 10 ** 18);

        mockErc20.mint(address(routerMock), 1000 * 10 ** 18);

        _makeOrder(Constants.PRICE_TICK, Constants.QUOTE_AMOUNT1, Constants.MAKER1);
    }

    function testArbitrage() public {
        IController.SpendOrderParams memory paramsList = IController.SpendOrderParams({
            id: key.toId(),
            limitPrice: 0,
            baseAmount: Constants.BASE_AMOUNT1,
            minQuoteAmount: 0,
            hookData: ""
        });
        (uint256 takenQuoteAmount, uint256 spentBaseAmount) = bookViewer.getExpectedOutput(paramsList);

        vm.startPrank(Constants.TAKER1);
        bytes memory data = abi.encodeWithSelector(
            routerMock.swap.selector,
            Currency.unwrap(key.quote),
            takenQuoteAmount - 50000,
            Currency.unwrap(key.base),
            Constants.BASE_AMOUNT1
        );
        arbitrage.arbitrage(key.toId(), address(routerMock), data);
        vm.stopPrank();

        assertEq(Constants.TAKER1.balance, 50000);
        assertEq(mockErc20.balanceOf(Constants.TAKER1), Constants.BASE_AMOUNT1 - spentBaseAmount);
    }
}
