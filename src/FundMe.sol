// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint;

    address[] private s_funders;
    mapping(address funder => uint amountFunded) private s_addressToAmountFunded;

    uint public constant MINIMUM_USD = 5e18;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't send enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint funderIndex = 0; funderIndex < s_funders.length; funderIndex++) 
        {
            s_addressToAmountFunded[s_funders[funderIndex]] = 0;
        }
        s_funders = new address[](0);

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

    // getters
    function getAddressToAmountFunded(address funder) external view returns (uint) {
        return s_addressToAmountFunded[funder];
    }

    function getFunder(uint index) external view returns (address) {
        return s_funders[index];
    
    }
    function getOwner() external view returns (address) {
        return i_owner;
    }


}