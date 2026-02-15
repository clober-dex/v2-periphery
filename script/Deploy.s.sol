// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {
    ERC1967Proxy
} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IBookManager} from "v2-core/interfaces/IBookManager.sol";

import {Controller} from "../src/Controller.sol";
import {BookViewer} from "../src/BookViewer.sol";

contract DeployScript is Script {
    uint256 internal constant BASE_CHAIN_ID = 8453;
    address internal constant BASE_OWNER_SAFE =
        0xfb976Bae0b3Ef71843F1c6c63da7Df2e44B3836d;
    address internal constant BASE_BOOK_MANAGER =
        0x8Ca3a6F4a6260661fcb9A25584c796a1Fa380112;

    uint256 internal constant ARBITRUM_CHAIN_ID = 42161;
    address internal constant ARBITRUM_OWNER_SAFE =
        0xfb976Bae0b3Ef71843F1c6c63da7Df2e44B3836d;
    address internal constant ARBITRUM_BOOK_MANAGER =
        0x74ffE45757DB60B24A7574b3B5948DAd368c2fdF;

    uint256 internal constant MONAD_MAINNET_CHAIN_ID = 143;
    address internal constant MONAD_MAINNET_OWNER_SAFE =
        0xfb976Bae0b3Ef71843F1c6c63da7Df2e44B3836d;
    address internal constant MONAD_MAINNET_BOOK_MANAGER =
        0x6657d192273731C3cAc646cc82D5F28D0CBE8CCC;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function deployController() public broadcast {
        address deployer = msg.sender;

        uint256 chainId = block.chainid;

        Controller controller = new Controller(_resolveBookManager(chainId));

        console.log("Controller deployed to:", address(controller));
    }

    function deployBookViewer() public broadcast {
        address deployer = msg.sender;
        uint256 chainId = block.chainid;

        // Determine owner based on chain
        address owner = _resolveOwner(chainId);

        // Deploy BookViewer implementation
        address bookManagerAddress = _resolveBookManager(chainId);
        BookViewer implementation = new BookViewer(
            IBookManager(bookManagerAddress)
        );
        console.log(
            "BookViewer implementation deployed to:",
            address(implementation)
        );

        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            BookViewer.__BookViewer_init.selector,
            owner
        );

        // Deploy ERC1967Proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );
        console.log("BookViewer proxy deployed to:", address(proxy));
    }

    function _resolveBookManager(
        uint256 chainId
    ) internal pure returns (address bookManager) {
        // Matches the intent of `deploy/BookManager.ts`.
        if (chainId == BASE_CHAIN_ID) {
            bookManager = BASE_BOOK_MANAGER;
        } else if (chainId == MONAD_MAINNET_CHAIN_ID) {
            bookManager = MONAD_MAINNET_BOOK_MANAGER;
        } else if (chainId == ARBITRUM_CHAIN_ID) {
            bookManager = ARBITRUM_BOOK_MANAGER;
        } else {
            revert("Unsupported chain");
        }
    }

    function _resolveOwner(
        uint256 chainId
    ) internal pure returns (address owner) {
        if (chainId == BASE_CHAIN_ID) {
            owner = BASE_OWNER_SAFE;
        } else if (chainId == ARBITRUM_CHAIN_ID) {
            owner = ARBITRUM_OWNER_SAFE;
        } else if (chainId == MONAD_MAINNET_CHAIN_ID) {
            owner = MONAD_MAINNET_OWNER_SAFE;
        } else {
            revert("Unsupported chain");
        }
    }
}
