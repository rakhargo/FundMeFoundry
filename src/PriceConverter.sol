// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint) {
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306 -- sepolia testnet
        // 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF -- zksync sepolia testnet
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint(answer * 1e10);
    }

    function getConversionRate(uint ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint) {
        uint ethPrice = getPrice(priceFeed);
        uint ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion(AggregatorV3Interface priceFeed) internal view returns (uint) {
        return priceFeed.version();
    }
}
