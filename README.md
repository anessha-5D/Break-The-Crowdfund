# Break the Crowdfund

A tiny proof-of-work project from **Devcon 8**, inspired by the BuidlGuidl
workshop *"Learning in the AI Era"* (Learning Lab + SpeedRun Ethereum).

> The tests pass in seconds. Taste takes years.

## The idea

AI can write a crowdfunding `refund()` that looks right and works. But does the
author *understand* why the order of the lines matters? This repo shows it by
breaking the contract on purpose.

| File | What it is |
|---|---|
| `src/Crowdfund.sol` | Safe version: updates the ledger **before** sending ETH |
| `src/CrowdfundVulnerable.sol` | Same contract, but sends ETH **before** updating the ledger |
| `src/Attacker.sol` | Contributes 1 ETH, then re-enters `refund()` to drain everyone |
| `test/Reentrancy.t.sol` | Proves: honest refund works, attack drains the vulnerable one, attack fails on the safe one |

## The bug in one picture

```
Vulnerable                         Safe
1. check amount owed               1. check amount owed
2. send ETH  --> attacker's        2. set ledger to 0   <-- moved up
   receive() calls refund()        3. send ETH
   again (ledger still not 0!)        attacker's second call sees 0
3. set ledger to 0 (too late)         and reverts
```

This is the **checks-effects-interactions** pattern.

## Run it

```bash
# needs Foundry: https://book.getfoundry.sh/getting-started/installation
git init
forge install foundry-rs/forge-std
forge test -vv
```

Expected: 3 tests pass.

## What I learned at Devcon 8

I got to learn a lot of things like the AI Learning Lab Ethereum. I also attended Vitalik's talk (Ethereum founder). I got great exposure to Blockchain, Web3, and Ethereum.I got to learn terms like decentralized social media, security and zero knowledge, smart contracts and volume trading etc. I attended the BuidlGuidl workshop based on AI and Ethereum. This project is a learning from the same workshop.


## Credits

Workshop by BuidlGuidl at Devcon 8. Learn more at https://lab.buidlguidl.com
and https://speedrunethereum.com
