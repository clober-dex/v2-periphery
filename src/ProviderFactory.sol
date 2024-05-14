// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IProviderFactory} from "./interfaces/IProviderFactory.sol";
import {IBookManager} from "v2-core/interfaces/IBookManager.sol";
import {Provider} from "./Provider.sol";

contract ProviderFactory is IProviderFactory, Ownable2Step, Initializable {
    uint256 public defaultBrokerShareRatio;
    IBookManager public bookManager;
    address public treasury;

    constructor() Ownable(msg.sender) {}

    function __ProviderFactory_init(
        address owner_, address bookManager_, address treasury_, uint256 defaultBrokerShareRatio_
    ) public initializer {
        _transferOwnership(owner_);
        Ownable2Step(bookManager_).acceptOwnership();
        bookManager = IBookManager(bookManager_);
        treasury = treasury_;
        defaultBrokerShareRatio = defaultBrokerShareRatio_;
    }

    function deployProvider(address broker) external returns (address) {
        return _deployProvider(broker, defaultBrokerShareRatio);
    }

    function deployProvider(address broker, uint256 shareRatio) public onlyOwner returns (address) {
        return _deployProvider(broker, shareRatio);
    }

    function _deployProvider(address broker, uint256 shareRatio) internal returns (address provider) {
        provider = address(new Provider(broker, shareRatio));
        bookManager.whitelist(provider);
        emit DeployProvider(provider, broker, shareRatio);
    }

    function setTreasury(address newTreasury) external onlyOwner {
        treasury = newTreasury;
        emit SetTreasury(newTreasury);
    }

    /**
     * @notice Whitelists a provider
     * @param provider The provider address
     */
    function whitelist(address provider) external onlyOwner {
        bookManager.whitelist(provider);
    }

    /**
     * @notice Delists a provider
     * @param provider The provider address
     */
    function delist(address provider) external onlyOwner {
        bookManager.delist(provider);
    }

    /**
     * @notice Sets the default provider
     * @param newDefaultProvider The new default provider address
     */
    function setDefaultProvider(address newDefaultProvider) external onlyOwner {
        bookManager.setDefaultProvider(newDefaultProvider);
    }

    function transferBookManagerOwnership(address newOwner) external onlyOwner {
        Ownable2Step(address(bookManager)).transferOwnership(newOwner);
    }
}
