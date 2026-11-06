// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice SAFE crowdfund. If the goal is not reached by the deadline,
/// every contributor can take their own money back.
contract Crowdfund {
    uint256 public immutable GOAL;
    uint256 public immutable deadline;
    mapping(address => uint256) public contributions; // who put in how much

    event Contributed(address indexed who, uint256 amount);
    event Refunded(address indexed who, uint256 amount);

    constructor(uint256 goal, uint256 durationSeconds) {
        GOAL = goal;
        deadline = block.timestamp + durationSeconds;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "funding closed");
        require(msg.value > 0, "send some ETH");
        contributions[msg.sender] += msg.value;
        emit Contributed(msg.sender, msg.value);
    }

    function refund() public virtual {
        // 1. CHECKS
        require(block.timestamp >= deadline, "funding still open");
        require(address(this).balance < GOAL, "goal was reached");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "nothing to refund");

        // 2. EFFECTS: update the ledger FIRST
        contributions[msg.sender] = 0;

        // 3. INTERACTIONS: send ETH LAST
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "refund failed");
        emit Refunded(msg.sender, amount);
    }
}
