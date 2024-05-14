// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ProviderFactory.sol";
import "../mocks/MockBookManager.sol";
import "../Constants.sol";
import "../../src/interfaces/IProvider.sol";

contract ProviderTest is Test {
    ProviderFactory public providerFactory;
    address public bookManager;

    function setUp() public {
        bookManager = address(new MockBookManager(address(this)));
        vm.deal(bookManager, 10 ether);
        providerFactory = new ProviderFactory();
        Ownable2Step(bookManager).transferOwnership(address(providerFactory));
        providerFactory.__ProviderFactory_init(address(this), address(bookManager), Constants.TREASURY, 300000);
    }

    function testProvider() public {
        IProvider provider = IProvider(providerFactory.deployProvider(Constants.BROKER));
        Currency[] memory currencies = new Currency[](1);
        currencies[0] = CurrencyLibrary.NATIVE;
        provider.claim(currencies);

        assertEq(Constants.TREASURY.balance, 864197358026419735);
        assertEq(Constants.BROKER.balance, 370370296297037028);
    }
}
