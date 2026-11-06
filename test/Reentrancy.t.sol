// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Crowdfund} from "../src/Crowdfund.sol";
import {CrowdfundVulnerable} from "../src/CrowdfundVulnerable.sol";
import {Attacker} from "../src/Attacker.sol";

contract ReentrancyTest is Test {
    uint256 constant GOAL = 10 ether; // goal is never reached in these tests
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    // Alice 3 + Bob 3 + attacker 1 = 7 ETH, below the 10 ETH goal
    function _fund(address crowdfund) internal returns (Attacker attacker) {
        vm.deal(alice, 3 ether);
        vm.deal(bob, 3 ether);
        vm.prank(alice);
        Crowdfund(crowdfund).contribute{value: 3 ether}();
        vm.prank(bob);
        Crowdfund(crowdfund).contribute{value: 3 ether}();

        attacker = new Attacker(crowdfund);
        attacker.deposit{value: 1 ether}();

        vm.warp(Crowdfund(crowdfund).deadline()); // deadline passes, goal missed
    }

    function test_HonestRefundWorks() public {
        Crowdfund c = new Crowdfund(GOAL, 1 days);
        _fund(address(c));
        vm.prank(alice);
        c.refund();
        assertEq(alice.balance, 3 ether);
    }

    function test_AttackDrainsVulnerable() public {
        CrowdfundVulnerable c = new CrowdfundVulnerable(GOAL, 1 days);
        Attacker attacker = _fund(address(c));

        attacker.attack();

        // Attacker put in 1 ETH and walked away with everything (7 ETH)
        assertEq(address(attacker).balance, 7 ether);
        assertEq(address(c).balance, 0);
    }

    function test_AttackFailsOnSafe() public {
        Crowdfund c = new Crowdfund(GOAL, 1 days);
        Attacker attacker = _fund(address(c));

        vm.expectRevert("refund failed");
        attacker.attack();

        // Everyone's money is still there
        assertEq(address(c).balance, 7 ether);
    }
}
