// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint constant SEND_VALUE = 0.01 ether;
    uint constant STARTING_BALANCE = 10 ether;
    uint constant GAS_PRICE = 1;

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
        assertEq(fundMe.getOwner(), msg.sender, "Owner should be the contract deployer");
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

    function testAddFunder()  public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "Funder should be added to the funder list");
    }

    modifier funded {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
        
    }

    function testWithdrawOnlyOwner()  public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawSingleFunder()  public funded {
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        // uint gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint gasEnd = gasleft();
        // uint gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log("Gas used for withdrawal:", gasUsed);

        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0, "FundMe balance should be zero after withdrawal");
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance, "Owner's balance should increase by the FundMe balance");
    }

    function testWithdrawMultipleFunder()  public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingOwnerBalance + startingFundMeBalance);
    }
}