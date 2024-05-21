// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ProviderFactory.sol";
import "../mocks/MockBookManager.sol";
import "../Constants.sol";
import "../../src/interfaces/IProvider.sol";
import "v2-core/BookManager.sol";

contract ProviderTest is Test {
    ProviderFactory public providerFactory;
    address public bookManager;

    function setUp() public {
        bookManager = address(new MockBookManager(address(this)));
        vm.deal(bookManager, 10 ether);
        providerFactory = new ProviderFactory();
        Ownable2Step(bookManager).transferOwnership(address(providerFactory));
        providerFactory.__ProviderFactory_init(address(this), address(bookManager), Constants.TREASURY, 700000);
    }

    function testSetTreasury() public {
        assertEq(providerFactory.treasury(), Constants.TREASURY);
        providerFactory.setTreasury(address(0x1234567));
        assertEq(providerFactory.treasury(), address(0x1234567));
    }

    function testWhitelist() public {
        assertFalse(IBookManager(bookManager).isWhitelisted(address(0x1234567)));
        providerFactory.whitelist(address(0x1234567));
        assertTrue(IBookManager(bookManager).isWhitelisted(address(0x1234567)));
        providerFactory.delist(address(0x1234567));
        assertFalse(IBookManager(bookManager).isWhitelisted(address(0x1234567)));
    }

    function testSetDefaultProvider() public {
        providerFactory.setDefaultProvider(address(0x1234567));
        assertEq(IBookManager(bookManager).defaultProvider(), address(0x1234567));
    }

    function testTransferOwnership() public {
        providerFactory.transferBookManagerOwnership(address(0x1234567));
        assertEq(Ownable2Step(bookManager).pendingOwner(), address(0x1234567));
        assertEq(Ownable2Step(bookManager).owner(), address(providerFactory));
        vm.expectRevert();
        Ownable2Step(bookManager).acceptOwnership();
        vm.prank(address(0x1234567));
        Ownable2Step(bookManager).acceptOwnership();
        assertEq(Ownable2Step(bookManager).owner(), address(0x1234567));
    }

    function testOnlyOwner() public {
        vm.startPrank(address(0x1234567));
        vm.expectRevert();
        providerFactory.setTreasury(address(0x987656));
        vm.expectRevert();
        providerFactory.deployProvider(address(0x987656), 1234);
        vm.expectRevert();
        providerFactory.whitelist(address(0x987656));
        vm.expectRevert();
        providerFactory.delist(address(0x987656));
        vm.expectRevert();
        providerFactory.setDefaultProvider(address(0x987656));
        vm.expectRevert();
        providerFactory.transferBookManagerOwnership(address(0x987656));
    }

    function testProvider() public {
        vm.prank(address(0x1234567));
        IProvider provider = IProvider(providerFactory.deployProvider(Constants.BROKER));
        Currency[] memory currencies = new Currency[](1);
        currencies[0] = CurrencyLibrary.NATIVE;
        provider.claim(currencies);

        assertEq(Constants.TREASURY.balance, 370370296297037029);
        assertEq(Constants.BROKER.balance, 864197358026419734);
    }

    function testCustomProvider() public {
        IProvider provider = IProvider(providerFactory.deployProvider(Constants.BROKER, 900000));
        Currency[] memory currencies = new Currency[](1);
        currencies[0] = CurrencyLibrary.NATIVE;
        provider.claim(currencies);

        assertEq(Constants.TREASURY.balance, 123456765432345677);
        assertEq(Constants.BROKER.balance, 1111110888891111086);
    }
}
