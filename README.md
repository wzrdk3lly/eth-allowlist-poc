### Overview

This repository is a WIP of an POC for the ETH allowlist implementation, originally created by the yearn team.

### Objective

The objective is to create an allowlist POC for an protocol. In this scenario the fake protocol will be called InvestX. It is a simple dapp, that accepts Fake usd (FUSD) and deposits these tokens into a pool.

The Allowlist will need to verify the following rules:

- InvestX only allows approvals for the token FUSD
- InvestX only allows deposits into the FUSD-Pool address

### Installation

When you have foundry installed, clone this repo and run `forge build`.
