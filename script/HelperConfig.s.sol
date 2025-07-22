// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; // eth/usd
    }

    uint8 public constant DECIMALS = 8;
    int public constant INITIAL_PRICE = 2000e8; // 2000 USD per ETH

    constructor() {
        if (block.chainid == 11155111) { // Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 300) {
            activeNetworkConfig = getZKsyncEthConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getAnvilEthConfig();
            // revert("Anvil network not configured yet");
        } else {
            revert("Network not supported");
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia ETH/USD price feed
        });
        return sepoliaConfig;
    }

    function getZKsyncEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory zkSyncConfig = NetworkConfig({
            priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF // zkSync ETH/USD price feed
        });
        return zkSyncConfig;
    }

    function getAnvilEthConfig()  public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) { // get
            return activeNetworkConfig;
        }
        // or create
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) // Mock aggregator address
        });

        return anvilConfig;
    }
}