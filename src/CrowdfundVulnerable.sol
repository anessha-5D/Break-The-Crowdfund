// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Crowdfund} from "./Crowdfund.sol";

/// @notice VULNERABLE copy. The ONLY change: ETH is sent BEFORE the ledger
/// is zeroed. Never deploy this.
contract CrowdfundVulnerable is Crowdfund {
    constructor(uint256 goal, uint256 durationSeconds) Crowdfund(goal, durationSeconds) {}

    function refund() public override {
        require(block.timestamp >= deadline, "funding still open");
        require(address(this).balance < GOAL, "goal was reached");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "nothing to refund");

        // BUG: money goes out while the ledger still says "you are owed"
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "refund failed");

        contributions[msg.sender] = 0; // too late
        emit Refunded(msg.sender, amount);
    }
}
