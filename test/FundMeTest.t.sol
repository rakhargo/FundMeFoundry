// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // run 'forge test --match-test {functionTestName} -vvv' to run a specific function test

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
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
}