// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint constant SEND_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 10 ether;

    // run 'forge test --match-test {functionTestName} -vvv' to run a specific function test

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); 
    }

    function testMinimumUsd() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18, "Minimum USD should be 5e18");
    }

    function testOwner() public view {
        assertEq(fundMe.i_owner(), msg.sender, "Owner should be the contract deployer");
    }

    function testPriceFeedVersion() public view {
        assertEq(uint(fundMe.getVersion()), 4, "Price feed version should be 4");
    }

    function testFundFails() public {
        vm.expectRevert();
        fundMe.fund(); // less than 5e18(minimum usd)
    }

    function testFundUpdates() public {
        vm.prank(USER); // simulate a different user
        fundMe.fund{value: SEND_VALUE}();

        // uint amountFunded = fundMe.getAddressToAmountFunded(address(this));
        uint amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should be updated to 0.1 ether");
    }
}