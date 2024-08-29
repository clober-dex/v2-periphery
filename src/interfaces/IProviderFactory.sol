// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IBookManager} from "v2-core/interfaces/IBookManager.sol";

interface IProviderFactory {
    event DeployProvider(address indexed provider, address indexed broker, uint256 shareRatio);

    event SetTreasury(address indexed treasury);

    function bookManager() external returns (IBookManager);

    function treasury() external returns (address);

    function deployProvider(address broker) external returns (address);

    function deployProvider(address broker, uint256 shareRatio) external returns (address);

    function setTreasury(address newTreasury) external;

    /**
     * @notice Whitelists a provider
     * @param provider The provider address
     */
    function whitelist(address provider) external;

    /**
     * @notice Delists a provider
     * @param provider The provider address
     */
    function delist(address provider) external;

    /**
     * @notice Sets the default provider
     * @param newDefaultProvider The new default provider address
     */
    function setDefaultProvider(address newDefaultProvider) external;

    function transferBookManagerOwnership(address newOwner) external;
}
