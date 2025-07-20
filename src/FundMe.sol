// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint;

    uint public constant MINIMUM_USD = 5e18;
    address[] funders;
    mapping(address funder => uint amountFunded) public addressToAmoundFunded;

    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmoundFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint funderIndex = 0; funderIndex < funders.length; funderIndex++) 
        {
            addressToAmoundFunded[funders[funderIndex]] = 0;
        }
        funders = new address[](0);

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool isSendSuccess = payable(msg.sender).send(address(this).balance);
        // require(isSendSuccess, "Send Failed");

        // call
        (bool isCallSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(isCallSuccess, "Call Failed");
    }

    function getVersion() external view returns (uint) {
        return PriceConverter.getVersion(s_priceFeed);
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not owner");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}